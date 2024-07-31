const {createPicoSocketServer} = require("pico-socket");
const {dispatch_request} = require("./request_dispatcher");

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

const assignToRoomAndTeam = (playerName) => {
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
    let teamToJoin;

    if (roomToJoin.team1Players.length > roomToJoin.team2Players.length) {
        teamToJoin = 2;
        roomToJoin.team2Players.push(playerName);
    } else {
        teamToJoin = 1;
        roomToJoin.team1Players.push(playerName);
    }

    return {
        roomId: roomIdToJoin,
        team: teamToJoin,
        playerId: playerId,
    };
}

// replace default logic
io.removeAllListeners("connection");

io.on("connection", (socket) => {
    let playerName = socket.handshake.auth.token;

    socket.on("disconnecting", (_reason) => {
        let roomId = 0;
        let teamId = 0;

        for (const room of roomData) {
            if (room.team1Players.includes(playerName)) {
                room.team1Players.splice(room.team1Players.indexOf(playerName), 1);
                teamId = 1;
                break;
            } else if (room.team2Players.includes(playerName)) {
                room.team2Players.splice(room.team2Players.indexOf(playerName), 1);
                teamId = 2;
                break;
            }

            ++roomId;
        }

        for (const room of socket.rooms) {
            if (room !== socket.id) {
                socket.to(roomId.toString()).emit("UPDATE_TEAM_NAMES", {
                    team1Players: roomData[roomId].team1Players,
                    team2Players: roomData[roomId].team2Players,
                });
            }
        }

        console.log("Player ", playerName, " disconnected from room ", roomId, " and team ", teamId);
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
        let playerAssignment = assignToRoomAndTeam(playerName);
        let roomId = playerAssignment.roomId;
        let playerId = playerAssignment.playerId;
        socket.join(roomId.toString());
        socket.emit("CONNECTED_TO_SERVER_RESP", {roomId, playerId});
        setTimeout(() => {
            console.log("Updated team names");
            io.to(roomId.toString()).emit("UPDATE_TEAM_NAMES", {
                team1Players: roomData[roomId].team1Players,
                team2Players: roomData[roomId].team2Players,
            });
        }, 1000)

        // if DEBUG=true, log when clients join
        console.log(playerName, " joined server, redirected to room: ", playerAssignment.roomId, ", team: ", playerAssignment.team);
    });
});