function getCountdownDuration() {
    return process.env.IS_PROD ? 3000 : 30;
}

export default getCountdownDuration;