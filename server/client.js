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

    const connectToRoomInterval = setInterval(() => {
        const command = window.pico8_gpio[commandIndex];

        if (command === joinServerCommand) {
            player.name = window.pico8_gpio.slice(1,12).reduce((a, c) => a + String.fromCharCode(c), "");
            clearInterval(connectToRoomInterval);
            clientSocket.emit("JOIN_SERVER_CMD", player.name);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
                console.log("Connected to server", {roomId, playerId, team, admin});
                player.roomId = roomId;
                player.team = team;
                player.admin = admin;

                window.pico8_gpio[commandIndex] = connectToServerResponse;
                window.pico8_gpio[roomIdIndex] = player.roomId;
                window.pico8_gpio[2] = player.id;
                window.pico8_gpio[3] = player.admin ? 1 : 0;
                window.pico8_gpio[4] = player.team;
            });
            // window.requestAnimationFrame(onFrameUpdate);
        }
    }, 250);
};

export default createPicoSocketClient;
