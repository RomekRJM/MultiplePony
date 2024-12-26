/**
 * <script src="/socket.io/socket.io.js"></script> line injects the socket.io client library into the html file.
 * This is where io is defined.
 */

const createPicoSocketClient = () => {
    let player = {
        id: -1,
        name: "",
        team: -1,
        roomId: -1,
        admin: false,
        ready: false,
    };

    let worker;

    if (typeof (Worker) !== "undefined") {
        if (typeof (worker) == "undefined") {
            worker = new Worker("web_socket_worker.js");
        }
        worker.onmessage = function (event) {
            document.getElementById("for-worker").innerHTML = event.data;
        };
    }

    function stopWorker() {
	  worker.terminate();
	  worker = undefined;
	}

	window.onbeforeunload = stopWorker;

    const serverCommandIndex = 0;
    const clientCommandIndex = 121;
    const serverRoomIdIndex = 1;
    const joinServerCommand = 1;
    const connectToServerResponse = 255;
    const updateTeamNamesServerResponse = 254;
    const startRoundCountdownServerResponse = 253;
    const updateRoundProgressServerResponse = 252;
    const audios = [
        new Audio('public/audio/chippi.ogg'),
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
        worker.postMessage({
            message: "START_ROUND_CMD",
            payload: {
                playerId: player.id,
                roomId: player.roomId,
                team: player.team,
            }
        });
    }

    const handleUpdatePlayerScoreCommand = () => {
        worker.postMessage({
            message: "UPDATE_PLAYER_SCORE_CMD",
            payload: {
                playerId: player.id,
                roomId: player.roomId,
                team: player.team,
                score: bytes2Word(window.pico8_gpio.slice(clientCommandIndex + 1, clientCommandIndex + 3)),
                frame: bytes2Word(window.pico8_gpio.slice(clientCommandIndex + 3, clientCommandIndex + 5))
            }
        });
    }

    const handleSwapTeamCommand = () => {
        worker.postMessage({
            message: "SWAP_TEAM_CMD",
            payload: {
                playerId: player.id,
                roomId: player.roomId,
                team: player.team,
                newTeam: window.pico8_gpio[clientCommandIndex + 1],
            }
        });
    }

    const handleUpdateReadinessCommand = () => {
        worker.postMessage({
            message: "UPDATE_READINESS_CMD",
            payload: {
                playerId: player.id,
                roomId: player.roomId,
                team: player.team,
                ready: window.pico8_gpio[clientCommandIndex + 1] > 0,
            }
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

    const handleStartRoundServerCommand = ({roundId}) => {
//            console.log("Received round start command", roundId);

        window.pico8_gpio[serverCommandIndex] = startRoundCountdownServerResponse;
        window.pico8_gpio[serverRoomIdIndex] = player.roomId;
        window.pico8_gpio[2] = roundId;
    }

    const handleUpdateTeamNamesServerCommand = ({adminPlayerName, team1Players, team2Players}) => {
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
    }

    const handleUpdateRoundProgressServerCommand = ({playerScores, winningTeam, clock, lastScoreUpdate}) => {
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
    }

    const handleConnectedToServerResponse = ({roomId, playerId, team, admin}) => {
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

        window.requestAnimationFrame(onFrameUpdate);
    }

    const serverCommands = {
        'START_ROUND_COUNTDOWN_CMD': handleStartRoundServerCommand,
        'UPDATE_TEAM_NAMES': handleUpdateTeamNamesServerCommand,
        'UPDATE_ROUND_PROGRESS_CMD': handleUpdateRoundProgressServerCommand,
        'CONNECTED_TO_SERVER_RESP': handleConnectedToServerResponse,
    }

    const processPico8Command = () => {
        const command = window.pico8_gpio[clientCommandIndex];
//        console.log(command);

        if (command <= joinServerCommand) {
            return;
        }

        clientCommands[command]();
        window.pico8_gpio[clientCommandIndex] = 0;
    }

    const onFrameUpdate = (timestamp) => {
        setTimeout(() => {
            processPico8Command();
            window.requestAnimationFrame(onFrameUpdate);
        }, 0);
    }

    const connectToRoomInterval = setInterval(() => {
        const command = window.pico8_gpio[clientCommandIndex];

        if (command === joinServerCommand) {
            player.name = window.pico8_gpio.slice(1, 12).reduce((a, c) => a + String.fromCharCode(c), "");

            worker.postMessage({
                message: "JOIN_SERVER_CMD",
                payload: player.name,
            });
        }
    }, 250);

    worker.onmessage = (e) => {
        serverCommands[e.data.command](e.data.payload);
    }
};

export default createPicoSocketClient;
