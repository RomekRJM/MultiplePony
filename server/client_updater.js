CONNECTED_TO_ROOM_RESP = 1
UPDATE_TEAM_NAMES = 2
START_ROUND_COUNTDOWN_CMD = 3
UPDATE_ROUND_PROGRESS = 4

const SERVER_REQUESTS = {
    CONNECTED_TO_ROOM_RESP: notImplemented,
    UPDATE_TEAM_NAMES: notImplemented,
    START_ROUND_COUNTDOWN_CMD: notImplemented,
    UPDATE_ROUND_PROGRESS: notImplemented,
}

function notImplemented() {

}

function updateClient() {

}

function broadcast_to_room(socket, roomId, data, payload) {
    socket.to(roomId).volatile.emit("update_from_server", updatedData);
}