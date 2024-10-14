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
        admin: false
    };
    const clientSocket = io.connect("http://localhost:5000/",
        {
            auth: {
                token: player.token
            }
        });
    const commandIndex = 0;
    const roomIdIndex = 1;
    const joinServerCommand = 1;
    const connectToServerResponse = 255;
    const updateTeamNamesServerResponse = 254;
    const startRoundCountdownServerResponse = 253;

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
        clientSocket.emit("UPDATE_PLAYER_SCORE_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            score: bytes2Word(window.pico8_gpio.slice(4, 6)),
        });
    }

    const handleSwapTeamCommand = () => {
        clientSocket.emit("SWAP_TEAM_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            newTeam: window.pico8_gpio[1],
        });
    }

    const handleUpdateReadinessCommand = () => {
        clientSocket.emit("UPDATE_READINESS_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            ready: window.pico8_gpio[1] === 1,
        });
    }

    const clientCommands = {
        2: handleStartRoundCommand,
        3: handleUpdateReadinessCommand,
        4: handleSwapTeamCommand,
        5: handleUpdatePlayerScoreCommand,
    };

    const processPico8Command = () => {
        const command = window.pico8_gpio[commandIndex];

        if (command >= 128) {
            return;
        }

        return clientCommands[command]();
    }

    const attachServerListeners = () => {
        // this listener moved from handleStartRoundCommand, check if it is fine
        clientSocket.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
            console.log("Received round start command", roundId);

            window.pico8_gpio[commandIndex] = startRoundCountdownServerResponse;
            window.pico8_gpio[roomIdIndex] = player.roomId;
            window.pico8_gpio[3] = roundId;
        });

        clientSocket.on("UPDATE_TEAM_NAMES", ({adminPlayerName, team1Players, team2Players}) => {
            console.log("Received update team names command", {adminPlayerName, team1Players, team2Players});
            let players = [...team1Players, ...team2Players];

            window.pico8_gpio[commandIndex] = updateTeamNamesServerResponse;
            window.pico8_gpio[roomIdIndex] = player.roomId;
            window.pico8_gpio[3] = team1Players.length;
            window.pico8_gpio[4] = team2Players.length;
            window.pico8_gpio[5] = team2Readiness(team1Players);
            window.pico8_gpio[6] = team2Readiness(team2Players);

            let index = 7;

            for (let player of players) {

                if (player.name === adminPlayerName) {
                    window.pico8_gpio[2] = player.id;
                }

                window.pico8_gpio[index] = player.id;
                ++index;

                let nameLength = 0;
                for (let char of player.name) {
                    window.pico8_gpio[index] = char.charCodeAt(0);
                    ++index;
                    ++nameLength;
                }

                // 0 means end of name
                window.pico8_gpio[index] = 0;
                ++index;
            }
        });
    }

    const onFrameUpdate = () => {
        processPico8Command()
    }

    const connectToRoomInterval = setInterval(() => {
        const command = window.pico8_gpio[commandIndex];

        if (command === joinServerCommand) {
            player.name = window.pico8_gpio.slice(1, 12).reduce((a, c) => a + String.fromCharCode(c), "");
            clearInterval(connectToRoomInterval);
            clientSocket.emit("JOIN_SERVER_CMD", player.name);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
                console.log("Connected to server", {roomId, playerId, team, admin});
                player.roomId = roomId;
                player.id = playerId;
                player.team = team;
                player.admin = admin;

                window.pico8_gpio[commandIndex] = connectToServerResponse;
                window.pico8_gpio[roomIdIndex] = player.roomId;
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
