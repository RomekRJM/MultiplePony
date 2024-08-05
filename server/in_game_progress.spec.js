import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe("multiple pony server", () => {
    const noPlayers = 4;
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

    it("should notify all players about in game progress", () => {
        return new Promise((resolve) => {
            let updatedClients = 0;

            clientSockets[0].emit("START_ROUND_CMD", {
                playerId: 0, roomId: 0, team: 1
            });

            setTimeout(() => {
                clientSockets[0].emit("UPDATE_PLAYER_SCORE_CMD", {
                    playerId: 0, roomId: 0, team: 1, score: 600
                });
                clientSockets[1].emit("UPDATE_PLAYER_SCORE_CMD", {
                    playerId: 1, roomId: 0, team: 2, score: 10000
                });
            }, 3017);

            setTimeout(() => {
                clientSockets.forEach(s => {
                    s.on("UPDATE_ROUND_PROGRESS_CMD", ({playerScores, winningTeam, clock}) => {
                        console.log("UPDATE_ROUND_PROGRESS_CMD ", playerScores, winningTeam, clock);

                        expect(playerScores).toEqual([
                            {playerName: 'PLAYER0', score: 600},
                            {playerName: 'PLAYER2', score: 0},
                            {playerName: 'PLAYER1', score: 10000},
                            {playerName: 'PLAYER3', score: 0}
                        ]);
                        expect(winningTeam).toEqual(2);
                        expect(clock).toBeGreaterThan(0);

                        s.disconnect();

                        ++updatedClients;

                        if (updatedClients === noPlayers - 1) {
                            resolve();
                        }
                    });
                });
            }, 3020);
        });
    });
});