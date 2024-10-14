import {afterEach, beforeEach, describe, it, expect} from "vitest";
import {io as ioc} from "socket.io-client";

describe.sequential("multiple pony server", () => {
    const noPlayers = 10;
    let clientSockets = [];
    let playerInfo = [];
    let adminPlayerId = 0;
    let currentRoomId = 0;
    let adminPlayerTeam = 0;

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

                    clientSockets[i].on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {

                        if (admin) {
                            adminPlayerId = playerId;
                            currentRoomId = roomId;
                            adminPlayerTeam = team;
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

    it("should not countdown if players not ready", () => {
        return new Promise((resolve) => {
            clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                playerId: adminPlayerId, roomId: currentRoomId, team: adminPlayerTeam
            });

            ensureNoCountdown(resolve);
        });
    });

    it("should notify all 10 players about round countdown start", () => {
        return new Promise((resolve) => {
            markAllAsReady().then(() => {
                let countdownsReceived = 0;

                clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                    playerId: adminPlayerId, roomId: currentRoomId, team: adminPlayerTeam
                });

                clientSockets.forEach(s => {
                    s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                        expect(roundId).toEqual(0);

                        ++countdownsReceived;
                        console.log("Received round ", roundId, " on countdownsReceived ", countdownsReceived);

                        if (countdownsReceived === noPlayers - 1) { // broadcast does not go to player which initiated it
                            resolve();
                        }
                    });
                });
            });
        });
    });

    it("should not notify players if round countdown was started by non admin user", () => {
        return new Promise((resolve) => {
            markAllAsReady().then(() => {
                let allPlayerIds = [...Array(noPlayers).keys()];
                let nonAdminPlayerId = allPlayerIds.find(id => id !== adminPlayerId);

                clientSockets[nonAdminPlayerId].emit("START_ROUND_CMD", {
                    playerId: nonAdminPlayerId, roomId: currentRoomId, team: 2
                });

                ensureNoCountdown(resolve);
            });
        });
    });

    it("should allow countdown only once", () => {
        return new Promise((resolve) => {
            markAllAsReady().then(() => {
                let countdownsReceived = 0;
                console.log("countdownsReceived ", countdownsReceived);

                clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                    playerId: adminPlayerId, roomId: currentRoomId, team: adminPlayerTeam
                });

                // 2nd START_ROUND_CMD should be refused, as room state has changed to COUNTING_DOWN_TO_GAME_START
                clientSockets[adminPlayerId].emit("START_ROUND_CMD", {
                    playerId: adminPlayerId, roomId: currentRoomId, team: adminPlayerTeam
                });

                clientSockets.forEach(s => {
                    s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                        expect(roundId).toEqual(0);

                        ++countdownsReceived;
                        console.log("Received round ", roundId, " on countdownsReceived ", countdownsReceived);
                    });
                });

                setTimeout(() => {
                    expect(countdownsReceived, 'Each user should only be notified once').toEqual(noPlayers);
                    resolve();
                }, 250);
            });
        });
    });

    function ensureNoCountdown(resolve) {
        let countdownsReceived = 0;
        let playersChecked = 0;

        clientSockets.forEach(s => {
            s.on("START_ROUND_COUNTDOWN_CMD", ({roundId}) => {
                ++countdownsReceived;
            });

            setTimeout(() => {
                ++playersChecked;
                if (playersChecked === noPlayers) {
                    expect(countdownsReceived, 'Expected no users to be notified about round start').toEqual(0);
                    resolve();
                }
            }, 250);
        });
    }

    function markAllAsReady() {
        return new Promise((resolve) => {
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
});