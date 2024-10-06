import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe.sequential("multiple pony server", () => {
    const noPlayers = 8;
    let clientSockets = [];
    let currentRoomId = 0;
    let team1 = [];
    let team2 = [];
    let expectedTeamResponses = {};

    beforeEach(() => {
        return new Promise((resolve) => {
            let resetClientSocket = ioc.connect("http://localhost:5000/", {
                auth: {
                    token: "1234"
                }
            });
            resetClientSocket.emit("RESET");

            expectedTeamResponses = {
                team1Players: [],
                team2Players: [],
            };

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

                    clientSockets[i].on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {

                        if (team === 1) {
                            team1.push(
                                {
                                    playerId: playerId,
                                    clientIndex: i,
                                    roomId: roomId,
                                }
                            );
                            expectedTeamResponses.team1Players.push(playerId);
                        } else {
                            team2.push(
                                {
                                    playerId: playerId,
                                    clientIndex: i,
                                    roomId: roomId,
                                }
                            );
                            expectedTeamResponses.team2Players.push(playerId);
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

            let removedIndex = expectedTeamResponses.team1.indexOf(firstPlayerOnTeam1.playerId);
            expectedTeamResponses.team1.slice(removedIndex, 1);
            expectedTeamResponses.team2.push(firstPlayerOnTeam1.playerId);

            clientSockets[firstPlayerOnTeam1.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: firstPlayerOnTeam1.playerId,
                    roomId: firstPlayerOnTeam1.roomId,
                    newTeam: 2
                }
            );

            clientSockets[secondPlayerOnTeam1.clientIndex].emit("SWAP_TEAM_CMD",
                {
                    playerId: secondPlayerOnTeam1.playerId,
                    roomId: secondPlayerOnTeam1.roomId,
                    newTeam: 2
                }
            );

            let responses = 0;

            clientSockets[i].on("UPDATE_TEAM_NAMES", (teams) => {

                ++responses;

                if (responses <= noPlayers) {
                    return;
                }

                expect(teams).toEqual(expectedTeamResponses);

                clientSockets[i].disconnect();
                resolve();
            });
        });
    });

});