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
    postMessage({message: "CONNECTED_TO_SERVER_RESP", payload: {roomId, playerId, team, admin}});
});

clientSocket.on("UPDATE_ROUND_PROGRESS_CMD", ({playerScores, winningTeam, clock, lastScoreUpdate}) => {
    postMessage({message: "UPDATE_ROUND_PROGRESS_CMD", payload: {playerScores, winningTeam, clock, lastScoreUpdate}});
});

clientSocket.on("UPDATE_TEAM_NAMES", ({team1Name, team2Name}) => {
    postMessage({message: "UPDATE_TEAM_NAMES", payload: {team1Name, team2Name}});
});

clientSocket.on("START_ROUND_COUNTDOWN_CMD", ({roundId, countdown}) => {
    postMessage({message: "START_ROUND_COUNTDOWN_CMD", payload: {roundId, countdown}});
});
