const { createPicoSocketServer } = require("pico-socket");

createPicoSocketServer({
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