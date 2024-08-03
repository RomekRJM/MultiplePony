const {createPicoSocketServer} = require("pico-socket");
const {updateTeamNames} = require("./client_updater");

const {app, server, io} = createPicoSocketServer({
    assetFilesPath: ".",
    htmlGameFilePath: "./server/game.html",

    clientConfig: {
        roomIdIndex: 0, // ROOM_ID

        // index to determine the player id
        playerIdIndex: 1, // PLAYER_ID

        // each player has: score_delta, timestamp
        playerDataIndicies: [
            [2, 3], // PLAYER_0
            [3, 4], // PLAYER_1
        ],
    },
});

const maxPlayersInTeam = 5;
const maxPlayersInRoom = 2 * maxPlayersInTeam;

class Player {
    constructor(name, id, roomId, team) {
        this.name = name;
        this.id = id;
        this.roomId = roomId;
        this.team = team;
        this.score = 0;
    }

    get resetScore() {
        this.score = 0;
    }
}

const RoomStatus = Object.freeze({
    ACCEPTING_PLAYERS:   Symbol("ACCEPTING_PLAYERS"),
    COUNTING_DOWN_TO_GAME_START:  Symbol("COUNTING_DOWN_TO_GAME_START"),
    IN_GAME: Symbol("IN_GAME")
});

const roomData = [
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
    },
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
    },
    {
        team1Players: [],
        team2Players: [],
        status: RoomStatus.ACCEPTING_PLAYERS,
        adminPlayerName: null,
    },
];

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
        return roomData[roomId].team1Players[playerId];
    } else if (team === 2) {
        return roomData[roomId].team2Players[playerId];
    }

    return null;
}

const createPlayerAndAssignToARoom = (playerName) => {
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

    if (roomToJoin.team1Players.length > roomToJoin.team2Players.length) {
        player = new Player(playerName, playerId, roomIdToJoin, 1);
        roomToJoin.team2Players.push(player);
    } else {
        player = new Player(playerName, playerId, roomIdToJoin, 2);
        roomToJoin.team1Players.push(player);
    }

    tryElectingAdmin(roomToJoin);

    return player;
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

// replace default logic
io.removeAllListeners("connection");

io.on("connection", (socket) => {
    let playerName = socket.handshake.auth.token;

    socket.on("disconnecting", (_reason) => {
        let player = findPlayerInRooms(playerName);

        if (!player) {
            return;
        }

        console.log("Disconnecting player ", playerName);

        for (const room of socket.rooms) {
            if (roomData[player.roomId].adminPlayerName === playerName) {
                roomData[player.roomId].adminPlayerName = null;
                tryElectingAdmin(roomData[player.roomId]);
            }

            if (room !== socket.id) {
                updateTeamNames(socket, player.roomId, roomData);
            }
        }

        console.log("Player ", playerName, " disconnected from room ", player.roomId, " and team ", player.team);
    });

    socket.on("RESET", () => {
        // hack until disconnection is properly handled
        roomData.forEach((room) => {
            room.team1Players = [];
            room.team2Players = [];
            room.status = RoomStatus.ACCEPTING_PLAYERS;
        });
        console.log("RESET received, rooms now empty");

        socket.emit("RESETED_ROOMS");
    })
    // attach a room id to the socket connection
    socket.on("JOIN_SERVER_CMD", () => {
        let player = createPlayerAndAssignToARoom(playerName);
        socket.join(player.roomId.toString());
        socket.emit("CONNECTED_TO_SERVER_RESP", {
            roomId: player.roomId,
            playerId: player.id,
            admin: player.name === roomData[player.roomId].adminPlayerName
        });
        setTimeout(() => {
            updateTeamNames(socket, player.roomId, roomData);
        }, 1000);

        // if DEBUG=true, log when clients join
        console.log(playerName, " joined server, redirected to room: ", player.roomId, ", team: ", player.team);
    });

    socket.on("START_ROUND_CMD", ({playerId, roomId, team}) => {
        console.log("START_ROUND_CMD received", playerId, roomId, team);
        let player = getPlayer(playerId, roomId, team);
        roomData[player.roomId].status = RoomStatus.COUNTING_DOWN_TO_GAME_START;

        socket.to(player.roomId.toString()).emit("START_ROUND_COUNTDOWN_CMD", {
            roundId: 0,
        });

        console.log(playerName, " started round in room: ", player.roomId);
    });
});