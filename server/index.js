const { createPicoSocketServer } = require("pico-socket");

const {app, server, io} = createPicoSocketServer({
  assetFilesPath: ".",
  htmlGameFilePath: "./game.html",

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

// replace default logic
io.removeAllListeners("connection")

io.on("connection", (socket) => {
  // save a `roomId` variable for this socket connection
  // when sending / recieving data, it will only go to people in the same room
  let roomId;
  socket.on("disconnect", () => {});
  // attach a room id to the socket connection
  socket.on("room_join", (evtData) => {
    handleConnection(data);
    socket.join(evtData.roomId);
    roomId = evtData.roomId;

    // if DEBUG=true, log when clients join
    if (process.env.DEBUG) {
      console.log("pony joined room: ", roomId);
    }
  });
  // when the server recives an update from the client, send it to every client with the same room id
  socket.on("update", (updatedData) => {
    socket.to(roomId).volatile.emit("update_from_server", updatedData);

    // if DEBUG=true, log the data we get
    if (process.env.DEBUG) {
      console.log(`${roomId}: `, logData(updatedData));
    }
  });
});