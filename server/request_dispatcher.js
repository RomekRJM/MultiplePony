JOIN_SERVER_CMD = 0
START_ROUND_CMD = 1
UPDATE_PLAYER_SCORE_CMD = 2
LEAVE_SERVER_CMD = 8

const CLIENT_REQUESTS_HANDLERS = {
    JOIN_SERVER_CMD: unhandled,
    LEAVE_SERVER_CMD: unhandled,
    START_ROUND_CMD: unhandled,
    UPDATE_PLAYER_SCORE_CMD: unhandled,
}

function dispatch_request(socket, request_data) {
    const roomId = request_data[0];
    const command = request_data[1];
    const playerId = request_data[2];

    console.log("Request dispatcher");

    if (roomId === 0) {
        return unhandled(roomId, playerId);
    }

    return CLIENT_REQUESTS_HANDLERS[command](socket, roomId, playerId, request_data.slice(3));
}

function handle(socket, roomId, playerId, payload) {

}

function unhandled(socket, roomId, playerId) {

}

module.exports = {dispatch_request};