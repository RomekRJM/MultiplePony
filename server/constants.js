const getCountdownDuration = () => {
    return process.env.IS_PROD ? 3000 : 30;
}

module.exports = {
    getCountdownDuration
}