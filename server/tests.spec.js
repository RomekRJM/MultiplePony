import {afterAll, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe("multiple pony server", () => {
    let io;

    beforeEach(() => {
        return new Promise((resolve) => {
            let clientSocket = ioc.connect("http://localhost:5000/", {
                auth: {
                    token: "1234"
                }
            });
            clientSocket.emit("RESET");
            clientSocket.on("RESETED_ROOMS", () => {
                resolve();
                clientSocket.disconnect();
            });
        });
    });

    afterAll(() => {
        io.close();
    });

    it("should allow player to connect", () => {
        return new Promise((resolve) => {
            let clientSocket = ioc.connect("http://localhost:5000/",
                {
                    auth: {
                        token: "1234"
                    }
                });
            let p1Name = 'PLAYER1';
            clientSocket.emit("JOIN_SERVER_CMD", p1Name);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId}) => {
                expect(playerId).toEqual(0);
                expect(roomId).toEqual(0);
                clientSocket.disconnect();
                resolve();
            });
        });
    });

    it("should update player on team changes with 1 player", () => {
        return connectPlayers(1, [], {team1Players: ['0'], team2Players: []});
    });

    it("should update player on team changes with 5 players", () => {
        return connectPlayers(4, [], {team1Players: ['0', '2', '4'], team2Players: ['1', '3']});
    });

    it("should update player on team changes with 5 players, when player 3 leaves", () => {
        return connectPlayers(4, [2], {team1Players: ['0', '4'], team2Players: ['1', '3']});
    });

    const connectPlayers = (noPlayers, playersToLeave, expectedTeamNamesResponse) => {
        return new Promise((resolve) => {
            let clientSockets = [];
            for (let i = 0; i < noPlayers; i++) {
                clientSockets.push(ioc.connect("http://localhost:5000/",
                    {
                        auth: {
                            token: `PLAYER${i}`
                        }
                    }));
                clientSockets[i].emit("JOIN_SERVER_CMD", i.toString());

                clientSockets[i].on("UPDATE_TEAM_NAMES", (teams) => {

                    if (playersToLeave.includes(i)) {
                        clientSockets[i].disconnect();
                    }

                    if (i === expectedTeamNamesResponse) {
                        expect(teams).toEqual(expectedTeamNamesResponse);
                    }

                    clientSockets[i].disconnect();
                    resolve();
                });
            }
        });
    }
});