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

const logData = (data) => {
    const emptyArray = new Array(data.length);
    data.forEach((element, index) => {
        if (element !== null) {
            emptyArray[index] = element;
        }
    });
    return emptyArray;
};

const maxPlayersInTeam = 5;
const maxPlayersInRoom = 2 * maxPlayersInTeam;

class Player {
    constructor(name, id, roomId, team, isAdmin) {
        this.name = name;
        this.id = id;
        this.roomId = roomId;
        this.team = team;
        this.isAdmin = isAdmin;
        this.score = 0;
    }
}

const roomData = [
    {
        team1Players: [],
        team2Players: [],
        gameInProgress: false,
    },
    {
        team1Players: [],
        team2Players: [],
        gameInProgress: false,
    },
    {
        team1Players: [],
        team2Players: [],
        gameInProgress: false,
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

const createPlayerAndAssignToARoom = (playerName) => {
    let roomIdToJoin = roomData.findIndex((room) => {
        if (room.gameInProgress) {
            return false;
        }

        return room.team1Players.length + room.team2Players.length < maxPlayersInRoom;
    });

    if (roomIdToJoin === -1) {
        return null;
    }

    let roomToJoin = roomData[roomIdToJoin];
    let playerId = roomToJoin.team1Players.length + roomToJoin.team2Players.length;
    let isAdmin = playerId === 0;
    let player;

    if (roomToJoin.team1Players.length > roomToJoin.team2Players.length) {
        player = new Player(playerName, playerId, roomIdToJoin, 1, isAdmin);
        roomToJoin.team2Players.push(player);
    } else {
        player = new Player(playerName, playerId, roomIdToJoin, 2, isAdmin);
        roomToJoin.team1Players.push(player);
    }

    return player;
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
            room.gameInProgress = false;
        });
        console.log("RESET received, rooms now empty");

        socket.emit("RESETED_ROOMS");
    })
    // attach a room id to the socket connection
    socket.on("JOIN_SERVER_CMD", () => {
        let player = createPlayerAndAssignToARoom(playerName);
        socket.join(player.roomId.toString());
        socket.emit("CONNECTED_TO_SERVER_RESP", {roomId: player.roomId, playerId: player.id});
        setTimeout(() => {
            updateTeamNames(socket, player.roomId, roomData);
        }, 1000)

        // if DEBUG=true, log when clients join
        console.log(playerName, " joined server, redirected to room: ", player.roomId, ", team: ", player.team);
    });
});