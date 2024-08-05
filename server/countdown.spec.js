import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe("multiple pony server", () => {
    const noPlayers = 10;
    let clientSockets = [];
    let adminPlayerId = 0;
    let currentRoomId = 0;

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

                    clientSockets[i].on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, admin}) => {

                        if (admin) {
                            adminPlayerId = playerId;
                            currentRoomId = roomId;
                        }

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

            clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                playerId: adminPlayerId, roomId: currentRoomId, team: 1
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

    it("should not notify players if round countdown was started by non admin user", () => {
        return new Promise((resolve) => {
            let countdownsReceived = 0;
            let playersChecked = 0;
            let allPlayerIds = [...Array(noPlayers).keys()];
            let nonAdminPlayerId = allPlayerIds.find(id => id !== adminPlayerId);

            clientSockets[nonAdminPlayerId].emit("START_ROUND_CMD", {
                playerId: nonAdminPlayerId, roomId: currentRoomId, team: 2
            });

            clientSockets.forEach(s => {
                s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                    ++countdownsReceived;
                });

                setTimeout(() => {
                    ++playersChecked;
                    if (playersChecked === noPlayers) {
                        expect(countdownsReceived, 'Expected no users to be notified about round start').toEqual(0);
                        resolve();
                    }
                }, 250);
            });
        });
    });

    it("should allow countdown only once", () => {
        return new Promise((resolve) => {
            let countdownsReceived = 0;
            console.log("countdownsReceived ", countdownsReceived);

            clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                playerId: adminPlayerId, roomId: currentRoomId, team: 1
            });

            // 2nd START_ROUND_CMD should be refused, as room state has changed to COUNTING_DOWN_TO_GAME_START
            clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                playerId: adminPlayerId, roomId: currentRoomId, team: 1
            });

            clientSockets.forEach(s => {
                s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                    expect(roundId).toEqual(0);

                    ++countdownsReceived;
                    console.log("Received round ", roundId, " on countdownsReceived ", countdownsReceived);
                });
            });

            setTimeout(() => {
                expect(countdownsReceived, 'Each user should only be notified once').toEqual(noPlayers - 1);
                resolve();
            }, 250);
        });
    });
});