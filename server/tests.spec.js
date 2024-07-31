import {afterAll, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe("multiple pony server", () => {
    let io, clientSocket;

    beforeEach(() => {
        return new Promise((resolve) => {
            let clientSocket = ioc.connect("http://localhost:5000/");
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
            let clientSocket = ioc.connect("http://localhost:5000/");
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
        return connectPlayers(1, {team1Players: ['0'], team2Players: []});
    });

    it("should update player on team changes with 4 player(s)", () => {
        return connectPlayers(4, {team1Players: ['0', '2'], team2Players: ['1', '3']});
    });

    const connectPlayers = (noPlayers, expectedTeamNamesResponse) => {
        return new Promise((resolve) => {
            let clientSockets = [];
            for (let i = 0; i < noPlayers; i++) {
                clientSockets.push(ioc.connect("http://localhost:5000/"));
                clientSockets[i].emit("JOIN_SERVER_CMD", i.toString());

                clientSockets[i].on("UPDATE_TEAM_NAMES", (teams) => {

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