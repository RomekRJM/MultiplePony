import getCountdownDuration from "./constants.js";
import createPicoSocketServer from "./server.js";

const maxPlayersInTeam = 5;
const maxPlayersInRoom = 2 * maxPlayersInTeam;
const countdownDuration = getCountdownDuration();
const pointsToWin = 10000;
const clockCycle = 250;

class Player {
    constructor(name, id, roomId, team) {
        this.name = name;
        this.id = id;
        this.roomId = roomId;
        this.team = team;
        this.score = 0;
        this.ready = false;
        this.lastFrameUpdate = 0;
    }

    resetPlayer() {
        this.score = 0;
        this.lastFrameUpdate = 0;
        this.ready = false;
    }
}

const RoomStatus = Object.freeze({
    ACCEPTING_PLAYERS: Symbol("ACCEPTING_PLAYERS"),
    COUNTING_DOWN_TO_GAME_START: Symbol("COUNTING_DOWN_TO_GAME_START"),
    IN_GAME: Symbol("IN_GAME"),
    GAME_FINISHED: Symbol("GAME_FINISHED"),
});

const roomData = [
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
        clock: 0,
        lastScoreUpdate: 0,
        socket: null,
        roomId: 0,
    },
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
        clock: 0,
        lastScoreUpdate: 0,
        socket: null,
        roomId: 1,
    },
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
        clock: 0,
        lastScoreUpdate: 0,
        socket: null,
        roomId: 2,
    },
];

const checkWinningTeam = (room) => {
    let team1Score = room.team1Players.reduce((acc, player) => acc + player.score, 0);
    let team2Score = room.team2Players.reduce((acc, player) => acc + player.score, 0);

    if (team1Score >= pointsToWin) {
        return 1;
    }

    if (team2Score >= pointsToWin) {
        return 2;
    }

    return 0;
}

const findPlayerInRooms = (playerName) => {
    let player = null;

    for (const room of roomData) {
        player = [
            room.team1Players.find((player) => player.name === playerName),
            room.team2Players.find((player) => player.name === playerName),
        ].find((player) => player);

        if (player) {
            return player;
        }
    }

    return null;
}

const getPlayer = (playerId, roomId, team) => {

    if (team === 1) {
        return roomData[roomId].team1Players.find((player) => player.id === playerId);
    } else if (team === 2) {
        return roomData[roomId].team2Players.find((player) => player.id === playerId);
    }

    return null;
}

const createPlayerAndAssignToARoom = (playerName) => {
    let existingPlayer = findPlayerInRooms(playerName);

    if (existingPlayer) {
        return existingPlayer;
    }

    let roomIdToJoin = roomData.findIndex((room) => {
        if (room.status !== RoomStatus.ACCEPTING_PLAYERS) {
            return false;
        }

        return room.team1Players.length + room.team2Players.length < maxPlayersInRoom;
    });

    if (roomIdToJoin === -1) {
        return null;
    }

    let roomToJoin = roomData[roomIdToJoin];
    let playerId = roomToJoin.team1Players.length + roomToJoin.team2Players.length;
    let player;

    if (roomToJoin.team1Players.length >= roomToJoin.team2Players.length) {
        player = new Player(playerName, playerId, roomIdToJoin, 2);
        roomToJoin.team2Players.push(player);
    } else {
        player = new Player(playerName, playerId, roomIdToJoin, 1);
        roomToJoin.team1Players.push(player);
    }

    tryElectingAdmin(roomToJoin);

    return player;
}

const changeTeam = (player, newTeam) => {
    let room = roomData[player.roomId];

    if (player.team === newTeam) {
        return;
    }

    if (newTeam === 1) {
        if (room.team1Players.length >= maxPlayersInTeam) {
            return;
        }

        player.team = 1;
        room.team2Players = room.team2Players.filter((p) => p.id !== player.id);
        room.team1Players.push(player);
    } else {
        if (room.team2Players.length >= maxPlayersInTeam) {
            return;
        }

        player.team = 2;
        room.team1Players = room.team1Players.filter((p) => p.id !== player.id);
        room.team2Players.push(player);
    }
}

const tryElectingAdmin = (room) => {
    if (room.adminPlayerName) {
        return;
    }

    if (room.team1Players.length > 0) {
        room.adminPlayerName = room.team1Players.find((player) => player).name;
    } else if (room.team2Players.length > 0) {
        room.adminPlayerName = room.team2Players.find((player) => player).name;
    }
}

const allPlayersInTheRoomReady = (room) => {

    return [...room.team1Players, ...room.team2Players]
        .map((p) => { return p.ready; })
        .reduce(
            (readiness, playerReadiness) => readiness & playerReadiness,
            true
    );
}

const resetRoom = (room) => {
    room.team1Players = [];
    room.team2Players = [];
    room.status = RoomStatus.ACCEPTING_PLAYERS;
    room.lastScoreUpdate = 0;
    room.clock = 0;
    room.adminPlayerName = null;

    if (room.socket) {
        room.socket.disconnect();
        room.socket = null;
    }
}

function updateTeamNames(io, roomId, roomData) {
    console.log(JSON.stringify(roomData[roomId].team1Players));
    io.in(roomId.toString()).emit("UPDATE_TEAM_NAMES", {
        adminPlayerName: roomData[roomId].adminPlayerName,
        team1Players: roomData[roomId].team1Players.map((p) => {
            return {
                id: p.id,
                name: p.name,
                ready: p.ready,
            };
        }),
        team2Players: roomData[roomId].team2Players.map((p) => {
            return {
                id: p.id,
                name: p.name,
                ready: p.ready,
            };
        }),
    });
}

const htmlGameFilePath = "public/game.html";
const workerFilePath = "web_socket_worker.js";
const assetFilesPath = "public";

const {app, server, io} = createPicoSocketServer({assetFilesPath, htmlGameFilePath, workerFilePath});

io.on("connection", (socket) => {
    let playerName = socket.handshake.auth.token;
    console.log("Player ", playerName, " connected");

    socket.on("disconnecting", (_reason) => {
        let player = findPlayerInRooms(playerName);

        if (!player) {
            return;
        }

        console.log("Disconnecting player ", playerName);

        let removedIndex = -1;
        let teamArray = null;

        if (player.team === 1) {
            teamArray = roomData[player.roomId].team1Players;
            removedIndex = roomData[player.roomId].team1Players.indexOf(player);
        } else {
            teamArray = roomData[player.roomId].team2Players;
            removedIndex = roomData[player.roomId].team2Players.indexOf(player);
        }

        if (removedIndex > -1) {
            teamArray.splice(removedIndex, 1);
        }

        for (const room of roomData) {
            if (roomData[player.roomId].adminPlayerName === playerName) {
                roomData[player.roomId].adminPlayerName = null;
                tryElectingAdmin(roomData[player.roomId]);
            }

            if (room !== socket.id) {
                updateTeamNames(io, player.roomId, roomData);
            }
        }

        console.log("Player ", playerName, " disconnected from room ", player.roomId, " and team ", player.team);
    });

    socket.on("RESET", () => {
        // hack until disconnection is properly handled
        roomData.forEach(resetRoom);
        console.log("RESET received, rooms now empty");

        socket.emit("RESETED_ROOMS");
    })
    // attach a room id to the socket connection
    socket.on("JOIN_SERVER_CMD", () => {
        let player = createPlayerAndAssignToARoom(playerName);

        if (!roomData[player.roomId].socket) {
            roomData[player.roomId].socket = socket;
        }

        socket.join(player.roomId.toString());
        socket.emit("CONNECTED_TO_SERVER_RESP", {
            roomId: player.roomId,
            playerId: player.id,
            team: player.team,
            admin: player.name === roomData[player.roomId].adminPlayerName
        });
        setTimeout(() => {
            updateTeamNames(io, player.roomId, roomData);
        }, 1000);

        // if DEBUG=true, log when clients join
        console.log(playerName, " joined server, redirected to room: ", player.roomId, ", team: ", player.team, " playerId: ", player.id, " admin in that room: ", roomData[player.roomId].adminPlayerName);
    });

    socket.on("START_ROUND_CMD", ({playerId, roomId, team}) => {
        console.log("START_ROUND_CMD received playerId: ", playerId, " roomId: ", roomId, " team: ", team);
        let player = getPlayer(playerId, roomId, team);
        let room = roomData[roomId];

        if (player.name !== room.adminPlayerName) {
            console.log("Refusing countdown. Player ", playerName, " is not an admin in room ", roomId);
            return;
        }

        if (room.status !== RoomStatus.ACCEPTING_PLAYERS) {
            console.log("Refusing countdown. Room ", roomId, " is not in ACCEPTING_PLAYERS status");
            return;
        }

        if (!allPlayersInTheRoomReady(room)) {
            console.log("Refusing countdown. Nota all players in the room ", roomId, " are ready.");
            return;
        }

        room.status = RoomStatus.COUNTING_DOWN_TO_GAME_START;

        io.in(roomId.toString()).emit("START_ROUND_COUNTDOWN_CMD", {
            roundId: 0,
        });

        console.log(playerId, " started round in room: ", roomId);

        setTimeout(() => {
            room.status = RoomStatus.IN_GAME;
            console.log("Game started in room ", roomId);
        }, countdownDuration)
    });

    socket.on("UPDATE_PLAYER_SCORE_CMD", ({playerId, roomId, team, score, frame}) => {
        let player = getPlayer(playerId, roomId, team);

        if (!player) {
            console.log("UPS Player not found ", playerId, roomId, team);
            return;
        }

        if ( frame > player.lastFrameUpdate ) {
            player.score = score;
            roomData[roomId].lastScoreUpdate = roomData[roomId].clock;
        }

        console.log("Player", playerId, "score updated to", player.score, "at frame", frame);
    });

    socket.on("SWAP_TEAM_CMD", ({playerId, roomId, team, newTeam}) => {
        let player = getPlayer(playerId, roomId, team);

        if (!player) {
            console.log("ST Player not found ", playerId, roomId, team);
            return;
        }

        changeTeam(player, newTeam);

        console.log("Player ", playerId, " team changed from ", team, " to ", player.team);

        updateTeamNames(io, player.roomId, roomData);
    });

    socket.on("UPDATE_READINESS_CMD", ({playerId, roomId, team, ready}) => {
        let player = getPlayer(playerId, roomId, team);

        if (!player) {
            console.log("UR Player not found ", playerId, roomId, team);
            return;
        }

        let previousReady = player.ready;
        player.ready = ready;

        console.log("Player ", playerId, " readiness changed from ", previousReady, " to ", player.ready);

        updateTeamNames(io, player.roomId, roomData);
    });

});

setInterval(
    () => {
        roomData.forEach((room, roomId) => {

            if (room.status !== RoomStatus.IN_GAME) {
                return;
            }

            if (room.team1Players.length + room.team2Players.length === 0) {
                console.log(`All players left room ${room.roomId}, resetting it.`);
                resetRoom(room);
            }

            let playerScores = roomData[roomId].team1Players.concat(roomData[roomId].team2Players).map((p) => {
                return {
                    playerId: p.id,
                    score: p.score,
                };
            });
            let winningTeam = checkWinningTeam(room);

            if (room.socket) {

                if (winningTeam === 0) {
                    io.volatile.in(roomId.toString()).emit("UPDATE_ROUND_PROGRESS_CMD", {
                        playerScores: playerScores,
                        winningTeam: winningTeam,
                        clock: room.clock,
                        lastScoreUpdate: room.lastScoreUpdate,
                    });
                } else {
                    room.status = RoomStatus.GAME_FINISHED;
                    room.lastScoreUpdate += 1;
                    console.log("Game finished in room ", roomId, " with winning team ", winningTeam);

                    io.in(roomId.toString()).emit("UPDATE_ROUND_PROGRESS_CMD", {
                        playerScores: playerScores,
                        winningTeam: winningTeam,
                        clock: room.clock,
                        lastScoreUpdate: room.lastScoreUpdate,
                    });

                    resetRoom(room);
                }
            }

            ++room.clock;
        });
    },
    clockCycle
);
