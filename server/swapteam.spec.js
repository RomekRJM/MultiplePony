import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe.sequential("multiple pony server", () => {
    const noPlayers = 8;
    let clientSockets = [];
    let team1 = [];
    let team2 = [];
    let expectedResponse = {};

    beforeEach(() => {
        return new Promise((resolve) => {
            let resetClientSocket = ioc.connect("http://localhost:5000/", {
                auth: {
                    token: "1234"
                }
            });
            resetClientSocket.emit("RESET");

            expectedResponse = {
                adminPlayerName: "",
                team1Players: [],
                team2Players: [],
            };

            resetClientSocket.on("RESETED_ROOMS", () => {
                let connectedClients = 0;
                clientSockets = [];

                for (let i = 0; i < noPlayers; i++) {
                    let playerName = `PLAYER${i}`;
                    clientSockets.push(ioc.connect("http://localhost:5000/", {
                        auth: {
                            token: playerName
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
                            expectedResponse.adminPlayerName = playerName;
                        }

                        if (team === 1) {
                            team1.push(
                                {
                                    playerId: playerId,
                                    clientIndex: i,
                                    roomId: roomId,
                                }
                            );
                            expectedResponse.team1Players.push(
                                {
                                    id: playerId,
                                    name: playerName,
                                    ready: false,
                                }
                            );
                        } else {
                            team2.push(
                                {
                                    playerId: playerId,
                                    clientIndex: i,
                                    roomId: roomId,
                                }
                            );
                            expectedResponse.team2Players.push(
                                {
                                    id: playerId,
                                    name: playerName,
                                    ready: false,
                                }
                            );
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

    it("should allow players to swap team1 to team2 if team2 is not maxed", () => {
        return new Promise((resolve) => {

            let firstPlayerOnTeam1 = team1[0];
            let secondPlayerOnTeam1 = team1[1];

            let swappedPlayer = expectedResponse.team1Players.find((p) => p.id === firstPlayerOnTeam1.playerId);
            expectedResponse.team1Players = expectedResponse.team1Players.filter((p) => p.id !== firstPlayerOnTeam1.playerId);
            expectedResponse.team2Players.push(swappedPlayer);

            clientSockets[firstPlayerOnTeam1.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: firstPlayerOnTeam1.playerId,
                    roomId: firstPlayerOnTeam1.roomId,
                    team: 1,
                    newTeam: 2,
                }
            );

            clientSockets[secondPlayerOnTeam1.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: secondPlayerOnTeam1.playerId,
                    roomId: secondPlayerOnTeam1.roomId,
                    team: 1,
                    newTeam: 2,
                }
            );

            let responses = 0;

            clientSockets.forEach((s) => {
                s.on("UPDATE_TEAM_NAMES", (response) => {

                    ++responses;

                    if (responses <= noPlayers) {
                        return;
                    }

                    expect(response).toEqual(expectedResponse);

                    s.disconnect();
                    resolve();
                });
            });
        });
    });

    it("should allow players to swap team2 to team1 if team1 is not maxed", () => {
        return new Promise((resolve) => {

            let firstPlayerOnTeam2 = team2[0];
            let secondPlayerOnTeam2 = team2[1];

            let swappedPlayer = expectedResponse.team2Players.find((p) => p.id === firstPlayerOnTeam2.playerId);
            expectedResponse.team2Players = expectedResponse.team2Players.filter((p) => p.id !== firstPlayerOnTeam2.playerId);
            expectedResponse.team1Players.push(swappedPlayer);

            clientSockets[firstPlayerOnTeam2.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: firstPlayerOnTeam2.playerId,
                    roomId: firstPlayerOnTeam2.roomId,
                    team: 2,
                    newTeam: 1,
                }
            );

            clientSockets[secondPlayerOnTeam2.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: secondPlayerOnTeam2.playerId,
                    roomId: secondPlayerOnTeam2.roomId,
                    team: 2,
                    newTeam: 1,
                }
            );

            let responses = 0;

            clientSockets.forEach((s) => {
                s.on("UPDATE_TEAM_NAMES", (response) => {

                    ++responses;

                    if (responses <= noPlayers) {
                        return;
                    }

                    expect(response).toEqual(expectedResponse);

                    s.disconnect();
                    resolve();
                });
            });
        });
    });

});