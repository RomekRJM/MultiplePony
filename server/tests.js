const { test} = require('node:test');
let io = require("socket.io-client");
let assert = require('assert');


function sendMessage(payload){
    let socket = io.connect("http://localhost:5000/");
    socket.emit("room_join", payload);
    // send data to server (volatile means unsent data can be dropped)
    socket.emit("update", payload);
}

function send() {
    let bufferArray = new ArrayBuffer(128);
    let buffer = new Uint8Array(bufferArray);
    buffer[0] = 0; // room id
    buffer[1] = 0; // command
    buffer[2] = 0; // player id
    buffer[3] = 'A'.charCodeAt(0);
    buffer[4] = 'Z'.charCodeAt(0);
    buffer[5] = 'L'.charCodeAt(0);
    sendMessage(bufferArray);
}

test('connect and send data', t => {
    send();
});
