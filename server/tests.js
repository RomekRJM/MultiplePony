const { test} = require('node:test');
let io = require("socket.io-client");
let assert = require('assert');


function sendMessage(payload){
    let socket = io.connect("http://localhost:5000/");
    socket.emit("room_join", 1);
    // send data to server (volatile means unsent data can be dropped)
    socket.emit("update", payload);
}

function send() {
    var payload = new Uint8Array(128);
    payload[0] = 0; // room id
    payload[1] = 0; // command
    payload[2] = 0; // player id
    payload[3] = 'A'.charCodeAt(0);
    sendMessage(payload);
}

test('connect and send data', t => {
    send();
});
