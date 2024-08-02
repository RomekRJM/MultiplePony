function updateTeamNames(socket, roomId, roomData) {
    socket.to(roomId.toString()).emit("UPDATE_TEAM_NAMES", {
        team1Players: roomData[roomId].team1Players.map((p) => {p.name, p.isAdmin}),
        team2Players: roomData[roomId].team2Players.map((p) => {p.name, p.isAdmin}),
    });
}

module.exports = {updateTeamNames};