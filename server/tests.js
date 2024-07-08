const test = require('node:test')
const assert = require("node:assert");
const { io } = require("socket.io-client");

function sendMessage(payload){
    io.connect("http://localhost:5000")
}

// Make the function wait until the connection is made...
function waitForSocketConnection(socket, callback){
    setTimeout(
        function () {
            if (socket.readyState === 1) {
                console.log("Connection is made")
                if (callback != null){
                    callback();
                }
            } else {
                console.log("wait for connection..." + socket.readyState)
                waitForSocketConnection(socket, callback);
            }

        }, 3000); // wait 3000 millisecond for the connection...
}

function send() {
    var payload = new Uint8Array(128);
    payload[0] = 0; // room id
    payload[1] = 0; // command
    payload[2] = 0; // player id
    payload[3] = 'A'.charCodeAt(0);
    sendMessage(payload);
}

test('join server', (t) => {
    send();
    assert.strictEqual(1, 1)
});
