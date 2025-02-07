import {afterAll, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe.sequential("multiple pony server", () => {
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

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
                expect(playerId).toEqual(0);
                expect(roomId).toEqual(0);
                expect(team).toEqual(2);
                expect(admin).toEqual(true);
                clientSocket.disconnect();
                resolve();
            });
        });
    });

    it("should only allow player to connect once", () => {
        return new Promise((resolve) => {
            let clientSocket = ioc.connect("http://localhost:5000/",
                {
                    auth: {
                        token: "1234"
                    }
                });
            let p1Name = 'PLAYER1';
            let connectionCount = 10;

            for (let i = 0; i < connectionCount; i++) {
                clientSocket.emit("JOIN_SERVER_CMD", p1Name);
            }

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
                connectionCount--;

                expect(playerId).toEqual(0);
                expect(roomId).toEqual(0);
                expect(team).toEqual(2);
                expect(admin).toEqual(true);

                if (connectionCount === 0) {
                    clientSocket.disconnect();
                    resolve();
                }
            });
        });
    });

    it("should update player on team changes with 1 player", () => {
        return connectPlayers(1, [], {team1Players: [0], team2Players: []});
    });

    it("should update player on team changes with 5 players", () => {
        return connectPlayers(4, [], {team1Players: [0, 2, 4], team2Players: [1, 3]});
    });

    it("should update player on team changes with 5 players, when player 3 leaves", () => {
        return connectPlayers(4, [2], {team1Players: [0, 4], team2Players: [1, 3]});
    });

    const connectPlayers = (noPlayers, playersToLeave, expectedTeams) => {
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

                clientSockets[i].on("UPDATE_TEAM_NAMES", (response) => {

                    if (playersToLeave.includes(i)) {
                        clientSockets[i].disconnect();
                    }

                    if (i === expectedTeams) {
                        expect(response.team1Players).toEqual(
                            expectedTeams.team1Players.map((p) => {
                                return {id: p, name: `PLAYER${p}`};
                            })
                        );

                        expect(response.team2Players).toEqual(
                            expectedTeams.team2Players.map((p) => {
                                return {id: p, name: `PLAYER${p}`};
                            })
                        );
                    }

                    clientSockets[i].disconnect();
                    resolve();
                });
            }
        });
    }
});