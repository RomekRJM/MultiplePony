import { beforeAll, afterAll, describe, it, expect } from "vitest";
import { io as ioc } from "socket.io-client";

describe.sequential("multiple pony server", () => {
    let io, clientSocket;

    beforeAll(() => {
        return new Promise((resolve) => {
            clientSocket = ioc.connect("http://localhost:5000/");
            resolve();
        });
    });

    afterAll(() => {
        io.close();
        clientSocket.disconnect();
    });

    it("should allow player to connect", () => {
        return new Promise((resolve) => {
            clientSocket.emit("RESET");
            clientSocket.on("RESETED_ROOMS", () => {
                let p1Name = 'PLAYER1';
                clientSocket.emit("JOIN_SERVER_CMD", p1Name);

                clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId}) => {
                    expect(playerId).toEqual(0);
                    expect(roomId).toEqual(0);
                    resolve();
                });
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
            clientSocket.emit("RESET");
            clientSocket.on("RESETED_ROOMS", () => {
                let count = 0;
                for (let i = 0; i < noPlayers; i++) {
                    clientSocket.emit("JOIN_SERVER_CMD", i.toString());
                    console.log(i);
                }

                clientSocket.on("UPDATE_TEAM_NAMES", (teams) => {
                    count += 1;

                    if (count === noPlayers) {
                        expect(teams).toEqual(expectedTeamNamesResponse);
                        resolve();
                    }
                });
            });
        });
    }
});