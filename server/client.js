/**
 * <script src="/socket.io/socket.io.js"></script> line injects the socket.io client library into the html file.
 * This is where io is defined.
 */

const createPicoSocketClient = () => {
    let player = {
        id: -1,
        token: "CURRENT_PLAYER_NAME",//crypto.randomUUID(),
        name: "",
        team: -1,
        roomId: -1,
        admin: false,
        ready: false,
    };
    const clientSocket = io.connect(SERVER_URL || "http://localhost:5000/",
        {
            auth: {
                token: player.token
            }
        });
    const serverCommandIndex = 0;
    const clientCommandIndex = 121;
    const serverRoomIdIndex = 1;
    const joinServerCommand = 1;
    const connectToServerResponse = 255;
    const updateTeamNamesServerResponse = 254;
    const startRoundCountdownServerResponse = 253;
    const updateRoundProgressServerResponse = 252;
    const audios = [
        new Audio('audio/chippi.mp3'),
    ];
    let currentAudio;

    const bytes2Word = (bytes) => {
        return (bytes[0] << 8) + bytes[1];
    }

    const word2Bytes = (word) => {
        return [word >> 8, word & 0xFF];
    }

    const team2Readiness = (team) => {
        let readinessByte = 0;

        for (let i = 0; i < team.length; ++i) {
            let playerReadiness = (team[i].ready ? 1 : 0) << i;
            readinessByte = readinessByte | playerReadiness;
        }

        return readinessByte;
    }

    const handleStartRoundCommand = () => {
        clientSocket.emit("START_ROUND_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team
        });
    }

    const handleUpdatePlayerScoreCommand = () => {
        clientSocket.volatile.emit("UPDATE_PLAYER_SCORE_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            score: bytes2Word(window.pico8_gpio.slice(clientCommandIndex + 1, clientCommandIndex + 3)),
            frame: bytes2Word(window.pico8_gpio.slice(clientCommandIndex + 3, clientCommandIndex + 5)),
        });
    }

    const handleSwapTeamCommand = () => {
        clientSocket.emit("SWAP_TEAM_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            newTeam: window.pico8_gpio[clientCommandIndex + 1],
        });
    }

    const handleUpdateReadinessCommand = () => {
        clientSocket.emit("UPDATE_READINESS_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            ready: window.pico8_gpio[clientCommandIndex + 1] > 0,
        });
    }

    const handlePlaySong = () => {

        if (currentAudio) {
            currentAudio.pause();
        }

        let songIndex = window.pico8_gpio[clientCommandIndex + 1];
        currentAudio = audios[songIndex];

        currentAudio.play();
    }

    const handleNoopCommand = () => {
    };

    const clientCommands = {
        1: handleNoopCommand,
        2: handleStartRoundCommand,
        3: handleUpdateReadinessCommand,
        4: handleSwapTeamCommand,
        5: handleUpdatePlayerScoreCommand,
        6: handlePlaySong,
    };

    const processPico8Command = () => {
        const command = window.pico8_gpio[clientCommandIndex];
//        console.log(command);

        if (command <= joinServerCommand) {
            return;
        }

        clientCommands[command]();
        window.pico8_gpio[clientCommandIndex] = 0;
    }

    const attachServerListeners = () => {
        clientSocket.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
//            console.log("Received round start command", roundId);

            window.pico8_gpio[serverCommandIndex] = startRoundCountdownServerResponse;
            window.pico8_gpio[serverRoomIdIndex] = player.roomId;
            window.pico8_gpio[2] = roundId;
        });

        clientSocket.on("UPDATE_TEAM_NAMES", ({adminPlayerName, team1Players, team2Players}) => {
//            console.log("Received update team names command", {adminPlayerName, team1Players, team2Players});
            let players = [...team1Players, ...team2Players];

            window.pico8_gpio[serverCommandIndex] = updateTeamNamesServerResponse;
            window.pico8_gpio[serverRoomIdIndex] = player.roomId;
            window.pico8_gpio[3] = team1Players.length;
            window.pico8_gpio[4] = team2Players.length;
            window.pico8_gpio[5] = team2Readiness(team1Players);
            window.pico8_gpio[6] = team2Readiness(team2Players);

            let index = 7;

            for (let p of players) {

                if (p.name === adminPlayerName) {
                    window.pico8_gpio[2] = p.id;
                }

                if (player.id === p.id) {
                    player.team = team1Players.includes(p) ? 1 : 2;
                    player.ready = p.ready;
                }

                window.pico8_gpio[index] = p.id;
                ++index;

                let nameLength = 0;
                for (let char of p.name) {
                    window.pico8_gpio[index] = char.charCodeAt(0);
                    ++index;
                    ++nameLength;
                }

                // 0 means end of name
                window.pico8_gpio[index] = 0;
                ++index;
            }
        });

        clientSocket.on("UPDATE_ROUND_PROGRESS_CMD", ({playerScores, winningTeam, clock, lastScoreUpdate}) => {
//            console.trace("Received update round progress command", {playerScores, winningTeam, clock, lastScoreUpdate});
            let clockBytes = word2Bytes(clock);
            let lastScoreUpdateBytes = word2Bytes(lastScoreUpdate);

            window.pico8_gpio[serverCommandIndex] = updateRoundProgressServerResponse;
            window.pico8_gpio[serverRoomIdIndex] = player.roomId;
            window.pico8_gpio[2] = clockBytes[0];
            window.pico8_gpio[3] = clockBytes[1];
            window.pico8_gpio[4] = lastScoreUpdateBytes[0];
            window.pico8_gpio[5] = lastScoreUpdateBytes[1];
            window.pico8_gpio[6] = winningTeam;
            window.pico8_gpio[7] = playerScores.length;

            let index = 8;

            for (let ps of playerScores) {
                let bytes = word2Bytes(ps.score);

                window.pico8_gpio[index] = ps.playerId;
                ++index;

                window.pico8_gpio[index] = bytes[0];
                ++index;

                window.pico8_gpio[index] = bytes[1];
                ++index;
            }
        });
    }

    const fps = 60;
    const timestep = 1000 / fps;
    let lastTimestamp = 0;

//    const onFrameUpdate = (timestamp) => {
//        window.requestIdleCallback(() => {
//            window.requestAnimationFrame(onFrameUpdate);
//
//            if (timestamp - lastTimestamp < timestep) {
//                return;
//            }
//
//            processPico8Command();
//
//            lastTimestamp = timestamp;
//        });
//    }

    const onFrameUpdate = (timestamp) => {
        setTimeout(() => {
            window.requestAnimationFrame(onFrameUpdate);
        }, 0);

        setTimeout(() => {
            processPico8Command();
        }, 0);

        // https://dev.to/localazy/how-to-pass-function-to-web-workers-4ee1 - invoke worker function, maybe processPico8Command should be handled like this
    }

    const connectToRoomInterval = setInterval(() => {
        const command = window.pico8_gpio[clientCommandIndex];

        if (command === joinServerCommand) {
            player.name = window.pico8_gpio.slice(1, 12).reduce((a, c) => a + String.fromCharCode(c), "");
            clearInterval(connectToRoomInterval);
            clientSocket.emit("JOIN_SERVER_CMD", player.name);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
//                console.log("Connected to server", {roomId, playerId, team, admin});
                player.roomId = roomId;
                player.id = playerId;
                player.team = team;
                player.admin = admin;

                window.pico8_gpio[serverCommandIndex] = connectToServerResponse;
                window.pico8_gpio[serverRoomIdIndex] = player.roomId;
                window.pico8_gpio[2] = player.id;
                window.pico8_gpio[3] = player.admin ? 1 : 0;
                window.pico8_gpio[4] = player.team;

                clearInterval(connectToRoomInterval);
                attachServerListeners();

                window.requestAnimationFrame(onFrameUpdate);
            });
        }
    }, 250);
};

export default createPicoSocketClient;
