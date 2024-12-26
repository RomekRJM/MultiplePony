importScripts("../socket.io/socket.io.js");

const clientSocket = io.connect(SERVER_URL || "http://localhost:5000/",
{
    auth: {
        token: "CURRENT_PLAYER_NAME"
    }
});

self.addEventListener("message", function(e) {
    clientSocket.emit(e.data.message, e.data.payload);
});

clientSocket.on("CONNECTED_TO_SERVER_RESP", ({roomId, playerId, team, admin}) => {
    postMessage({command: "CONNECTED_TO_SERVER_RESP", payload: {roomId, playerId, team, admin}});
});

clientSocket.on("UPDATE_ROUND_PROGRESS_CMD", ({playerScores, winningTeam, clock, lastScoreUpdate}) => {
    postMessage({command: "UPDATE_ROUND_PROGRESS_CMD", payload: {playerScores, winningTeam, clock, lastScoreUpdate}});
});

clientSocket.on("UPDATE_TEAM_NAMES", ({adminPlayerName, team1Players, team2Players}) => {
    postMessage({command: "UPDATE_TEAM_NAMES", payload: {adminPlayerName, team1Players, team2Players}});
});

clientSocket.on("START_ROUND_COUNTDOWN_CMD", ({roundId, countdown}) => {
    postMessage({command: "START_ROUND_COUNTDOWN_CMD", payload: {roundId, countdown}});
});
