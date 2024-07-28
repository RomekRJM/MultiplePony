const { test} = require('node:test');
let io = require("socket.io-client");
let assert = require('assert');


function sendMessage(name){
    let socket = io.connect("http://localhost:5000/");
    socket.emit("JOIN_SERVER_CMD", name);
    // send data to server (volatile means unsent data can be dropped)

    socket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId}) => {
        console.log("I", playerId, "have joined room:", roomId);
    });

    socket.on("UPDATE_TEAM_NAMES", (teams) => {
        console.log("Received ping in ", JSON.stringify(teams));
    });
}

test('connect and send data', t => {
    sendMessage('PKC');
});
