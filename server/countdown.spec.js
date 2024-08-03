import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe("multiple pony server", () => {
    const noPlayers = 10;
    let clientSockets = [];

    beforeEach(() => {
        return new Promise((resolve) => {
            let resetClientSocket = ioc.connect("http://localhost:5000/", {
                auth: {
                    token: "1234"
                }
            });
            resetClientSocket.emit("RESET");

            resetClientSocket.on("RESETED_ROOMS", () => {
                let connectedClients = 0;
                clientSockets = [];

                for (let i = 0; i < noPlayers; i++) {
                    clientSockets.push(ioc.connect("http://localhost:5000/", {
                        auth: {
                            token: `PLAYER${i}`
                        }
                    }));
                    clientSockets[i].emit("JOIN_SERVER_CMD", i.toString());

                    clientSockets[i].on("CONNECTED_TO_SERVER_RESP", (_) => {
                        ++connectedClients;

                        if (connectedClients === noPlayers) {
                            resetClientSocket.disconnect();
                            resolve();
                        }
                    });
                }
            });
        })
    });

    afterEach(() => {
        clientSockets.forEach((socket) => {
            socket.disconnect();
        });
    });

    it("should notify all 10 players about round countdown start", () => {
        return new Promise((resolve) => {
            let countdownsReceived = 0;

            clientSockets[0].emit("START_ROUND_CMD", {
                playerId: 0, roomId: 0, team: 1
            });

            clientSockets.forEach(s => {
                s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                    expect(roundId).toEqual(0);

                    ++countdownsReceived;
                    console.log("Received round ", roundId, " on countdownsReceived ", countdownsReceived);

                    if (countdownsReceived === noPlayers - 1) { // broadcast does not go to player which initiated it
                        resolve();
                    }
                });
            });
        });
    });
});