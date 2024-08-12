/**
 * createPicoSocketClient - function to interact with the
 * GPIO pins of Pico-8 and send them to the server via socket-io
 *
 * Note, this logic does not need to be called directly - it is automatically
 * embedded by createPicoSocketServer - however you can import and call this
 * code in your own implementation!
 */
import {io as ioc} from "socket.io-client";

const createPicoSocketClient = ({
                                    roomIdIndex,
                                    playerIdIndex,
                                    playerDataIndicies,
                                    debug,
                                }) => {
    const clientSocket = ioc.connect("http://localhost:5000/",
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

module.exports = createPicoSocketClient;