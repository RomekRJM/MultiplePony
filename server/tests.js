const { test} = require('node:test');
let io = require("socket.io-client");
let assert = require('assert');


function sendMessage(payload){
    let socket = io.connect("http://localhost:5000/");
    socket.emit("JOIN_SERVER_CMD", payload);
    // send data to server (volatile means unsent data can be dropped)

    socket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId}) => {
        console.log("I", playerId, "have joined room:", roomId);
    });

    socket.on("UPDATE_TEAM_NAMES", ({roomId}) => {
        console.log("Received ping in ", roomId);
    });
}

function send(uniqueId) {
    let bufferArray = new ArrayBuffer(128);
    let buffer = new Uint8Array(bufferArray);
    buffer[0] = 0; // room id
    buffer[1] = 0; // command
    buffer[2] = 0; // player id
    buffer[3] = 'A'.charCodeAt(0);
    buffer[4] = 'Z'.charCodeAt(0);
    buffer[5] = 'L'.charCodeAt(0);
    buffer[3] = uniqueId.charCodeAt(0);
    buffer[4] = uniqueId.charCodeAt(1);
    buffer[5] = uniqueId.charCodeAt(2);
    sendMessage(bufferArray, uniqueId);
}

test('connect and send data', t => {
    send('PKC');
});
