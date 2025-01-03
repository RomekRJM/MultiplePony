import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";
import getCountdownDuration from "./constants";
import {markAllAsReady} from "./test-utils.js";

describe.sequential("multiple pony server", () => {
    const noPlayers = 4;
    let clientSockets = [];
    let adminPlayerIndex = 0;
    let playerInfo = [];

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

                    clientSockets[i].on("CONNECTED_TO_SERVER_RESP", ({
                                                                         roomId,
                                                                         playerId,
                                                                         team,
                                                                         admin
                                                                     }) => {

                        if (admin) {
                            adminPlayerIndex = i;
                        }

                        playerInfo[i] = ({playerId, roomId, team, admin});

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
            markAllAsReady(resolve, noPlayers, clientSockets, playerInfo).then(() => {
                let updatedClients = 0;

                clientSockets[adminPlayerIndex].emit("START_ROUND_CMD", {
                    playerId: playerInfo[adminPlayerIndex].playerId,
                    roomId: playerInfo[adminPlayerIndex].roomId,
                    team: playerInfo[adminPlayerIndex].team
                });

                setTimeout(() => {
                    clientSockets[0].emit("UPDATE_PLAYER_SCORE_CMD", {
                        playerId: playerInfo[0].playerId,
                        roomId: playerInfo[0].roomId,
                        team: playerInfo[0].team,
                        score: 600
                    });
                    clientSockets[1].emit("UPDATE_PLAYER_SCORE_CMD", {
                        playerId: playerInfo[1].playerId,
                        roomId: playerInfo[1].roomId,
                        team: playerInfo[1].team,
                        score: 10000
                    });
                }, getCountdownDuration() + 17);

                setTimeout(() => {
                    clientSockets.forEach((s, i) => {
                        s.on("UPDATE_ROUND_PROGRESS_CMD", ({playerScores, winningTeam, clock, lastScoreUpdate}) => {
                            [
                                {playerId: 0, score: 600},
                                {playerId: 2, score: 0},
                                {playerId: 1, score: 10000},
                                {playerId: 3, score: 0}
                            ].forEach(e => {
                                expect(playerScores.map(s => JSON.stringify(s))).toContain(JSON.stringify(e));
                            })
                            expect(playerScores.length).equals(4);

                            console.log(JSON.stringify(playerInfo[i]));

                            expect(winningTeam).toEqual(playerInfo[1].team);
                            expect(clock).toBeGreaterThan(0);
                            expect(lastScoreUpdate).toBeGreaterThan(0);

                            s.disconnect();

                            ++updatedClients;

                            if (updatedClients === noPlayers) {
                                resolve();
                            }
                        });
                    });
                }, getCountdownDuration() + 20);
            });
        });
    });
});