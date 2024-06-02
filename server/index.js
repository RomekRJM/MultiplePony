const { createPicoSocketServer } = require("pico-socket");

createPicoSocketServer({
  assetFilesPath: ".",
//  htmlGameFilePath: "./sample.html",

  clientConfig: {
    roomIdIndex: 0, // ROOM_ID

    // index to determine the player id
    playerIdIndex: 1, // PLAYER_ID

    // indicies that contain player specific data
    playerDataIndicies: [
      [2], // PLAYER_0_Y
      [3], // PLAYER_1_Y
    ],
  },
});