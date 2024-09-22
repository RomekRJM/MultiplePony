/**
 * <script src="/socket.io/socket.io.js"></script> line injects the socket.io client library into the html file.
 * This is where io is defined.
 */

const createPicoSocketClient = () => {
    let player = {
        id: -1,
        token: "4567",
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
    const startRoundCountdownServerResponse = 253;

    const bytes2Word = (bytes) => {
        return (bytes[0] << 8) + bytes[1];
    }

    const word2Bytes = (word) => {
        return [word >> 8, word & 0xFF];
    }

    const handleStartRoundCommand = () => {
        clientSocket.emit("START_ROUND_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team
        });

        clientSocket.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
            console.log("Received round start command", roundId);

            window.pico8_gpio[commandIndex] = startRoundCountdownServerResponse;
            window.pico8_gpio[roomIdIndex] = player.roomId;
            window.pico8_gpio[3] = roundId;
        });
    }

    const handleUpdatePlayerScoreCommand = () => {
        clientSocket.emit("UPDATE_PLAYER_SCORE_CMD", {
            playerId: player.id,
            roomId: player.roomId,
            team: player.team,
            score: bytes2Word(window.pico8_gpio.slice(4, 6))
        });
    }

    const clientCommands = {
        2: handleStartRoundCommand,
        3: handleUpdatePlayerScoreCommand,
    };

    const onFrameUpdate = () => {
        const command = window.pico8_gpio[commandIndex];

        if (command >= 128) {
            return;
        }

        return clientCommands[command]();
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

                window.requestAnimationFrame(onFrameUpdate);
            });
        }
    }, 250);
};

export default createPicoSocketClient;
