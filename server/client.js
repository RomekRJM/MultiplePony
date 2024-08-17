/**
 * <script src="/socket.io/socket.io.js"></script> line injects the socket.io client library into the html file.
 * This is where io is defined.
 */

const createPicoSocketClient = () => {
    const clientSocket = io.connect("http://localhost:5000/",
        {
            auth: {
                token: "4567"
            }
        })
    const commandIndex = 0;
    const joinServerCommand = 255;

    const connectToRoomInterval = setInterval(() => {
        const command = window.pico8_gpio[commandIndex];

        if (command === joinServerCommand) {
            const playerName = window.pico8_gpio.slice(1, 3).map((i) => String.fromCharCode(i)).join("");
            clearInterval(connectToRoomInterval);
            clientSocket.emit("JOIN_SERVER_CMD", playerName);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
                console.log("Connected to server", {roomId, playerId, team, admin});
            });
            // window.requestAnimationFrame(onFrameUpdate);
        }
    }, 250);
};

export default createPicoSocketClient;
