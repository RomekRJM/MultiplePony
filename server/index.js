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

const handleConnection = (data) => {
    const roomId = data[0];

    if (roomId !== 0) {
        return;
    }

    console.log(String.fromCharCode(data.slice(1)));

};

const maxPlayersInTeam = 5;
const maxPlayersInRoom = 2 * maxPlayersInTeam;
const payloadDataStart = 3;

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

const assignToRoomAndTeam = (playerId) => {
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
    let teamToJoin;

    if (roomToJoin.team1Players.length > roomToJoin.team2Players.length) {
        teamToJoin = 2;
        roomToJoin.team2Players.push(playerId);
    } else {
        teamToJoin = 1;
        roomToJoin.team1Players.push(playerId);
    }

    return {
        roomId: roomIdToJoin,
        team: teamToJoin,
    };
}

// replace default logic
io.removeAllListeners("connection");

io.on("connection", (socket) => {
    // save a `roomId` variable for this socket connection
    // when sending / recieving data, it will only go to people in the same room
    let roomId;
    socket.on("disconnect", () => {
    });
    // attach a room id to the socket connection
    socket.on("room_join", (evtData) => {
        let buffer = new Uint8Array(evtData);
        console.log(buffer);
        let playerName = Buffer.from(buffer, payloadDataStart).toString();
        let playerAssignment = assignToRoomAndTeam(playerName);
        handleConnection(evtData);
        roomId = playerAssignment.roomId;
        socket.join(roomId);

        // if DEBUG=true, log when clients join
        if (process.env.DEBUG) {
            console.log(playerName, " joined room: ", playerAssignment.roomId, ", team: ", playerAssignment.team);
        }
    });

    socket.on("update", (payload) => {
        dispatch_request(socket, payload);

        if (process.env.DEBUG) {
            console.log(`${roomId}: `, logData(payload));
        }
    });
});