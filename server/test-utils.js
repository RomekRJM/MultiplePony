import {expect} from "vitest";

export function markAllAsReady(resolve, noPlayers, clientSockets, playerInfo) {
    return new Promise(() => {
        let testsFinished = 0;
        let numberOfExpectedUpdates = noPlayers * noPlayers;
        let updatesReceived = 0;
        let readiness = true;

        clientSockets.forEach((s, i) => {
            s.emit("UPDATE_READINESS_CMD", {
                playerId: playerInfo[i].playerId,
                roomId: playerInfo[i].roomId,
                team: playerInfo[i].team,
                ready: true,
            });

            s.on("UPDATE_TEAM_NAMES", ({_adminPlayerName, team1Players, team2Players}) => {
                ++updatesReceived;

                if (updatesReceived === numberOfExpectedUpdates) {
                    readiness = team1Players.reduce((acc, p) => {
                        acc = p.ready && acc;
                        return acc;
                    }, true);

                    readiness = team2Players.reduce((acc, p) => {
                        acc = p.ready && acc;
                        return acc;
                    }, readiness);
                }
            })

            setTimeout(() => {
                expect(updatesReceived, 'Each user should only be notified once').toEqual(numberOfExpectedUpdates);
                expect(readiness, 'Each user should be ready').toEqual(true);

                ++testsFinished;
                if (testsFinished === noPlayers) {
                    resolve();
                }
            }, 250);
        });
    });
}