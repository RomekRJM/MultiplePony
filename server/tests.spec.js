import { beforeAll, afterAll, describe, it, expect } from "vitest";
import { io as ioc } from "socket.io-client";

describe("multiple pony server", () => {
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
            let p1Name = 'PLAYER1';
            clientSocket.emit("JOIN_SERVER_CMD", p1Name);

            clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId}) => {
                expect(playerId).toEqual(0);
                expect(roomId).toEqual(0);
                resolve();
            });
        });
    });

    it("should update player on team changes", () => {
        return new Promise((resolve) => {
            let p1Name = 'PLAYER1';
            let p2Name = 'PLAYER2';
            clientSocket.emit("JOIN_SERVER_CMD", p1Name);
            clientSocket.emit("JOIN_SERVER_CMD", p2Name);

            clientSocket.on("UPDATE_TEAM_NAMES", (teams) => {
                expect(teams).toEqual({team1Players: [p1Name], team2Players: [p2Name]});
                resolve();
            });
        });
    });
});