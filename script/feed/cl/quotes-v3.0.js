/**
 * @param {number} amount
 * @param {ethers.Contract} pair
 * @returns {Promise<[number, number, number, Date]>} [mid, bid, ask, timestamp]
 */
async function quotes_of(amount, pair, flip) {
    const data = await pair.latestRoundData();
    return quotestamp(amount, data, flip);
}
function quotestamp(
    amount, [round_id, answer, started_at, updated_at], flip
) {
    const stamp = new Date(Number(updated_at) * 1e3);
    const quote = Number(answer) / 1e8;
    return flip ? [
        (quote * amount) ** (-1), // mid
        (quote * amount) ** (-1), // bid
        (quote * amount) ** (-1), // ask
        stamp
    ] : [
        (quote * amount) ** (+1), // mid
        (quote * amount) ** (+1), // bid
        (quote * amount) ** (+1), // ask
        stamp
    ];
}
module.exports = { quotes_of };
