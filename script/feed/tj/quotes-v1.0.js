const { ethers } = require("ethers");
const { provider } = require("../provider");
const abi = require("./abi/IERC20Metadata.json");
/**
 * Queries quotes of a (token0, token1) pair; with the
 * [mid, bid, ask] results in token1 units.
 *
 * @param {number} amount quoted in token0 units.
 * @param {ethers.Contract} pair of (token0, token1)
 * @returns {Promise<[number, number, number, Date]>} [mid, bid, ask, timestamp]
 */
async function quotes_of(amount, pair, flip) {
    const [[u0, u1], reserves] = await Promise.all([
        unitsOf(pair, flip), pair.getReserves(),
    ]);
    const [quotes, timestamp] = quotestamp(
        amount * u0, reserves, flip
    );
    return [...quotes.map((q) => q / u1), timestamp];
}
async function unitsOf(pair, flip) {
    const [token_0, token_1] = await Promise.all([
        pair.token0(),
        pair.token1(),
    ]);
    const [meta_0, meta_1] = [
        new ethers.Contract(token_0, abi, provider),
        new ethers.Contract(token_1, abi, provider),
    ];
    const [decimals_0, decimals_1] = await Promise.all([
        meta_0.decimals(),
        meta_1.decimals(),
    ]);
    return [
        10 ** Number(!flip ? decimals_0 : decimals_1),
        10 ** Number(!flip ? decimals_1 : decimals_0),
    ];
}
function quotestamp(
    amount, [lhs, rhs, timestamp], flip
) {
    const stamp = new Date(Number(timestamp) * 1e3);
    const [lhz, rhz] = !flip
        ? [Number(lhs), Number(rhs)]
        : [Number(rhs), Number(lhs)];
    //
    // bid-quote incl. slippage
    //
    let bid;
    if (lhz <= Number.MAX_VALUE - amount) {
        bid = amount * rhz / (lhz + amount);
    } else {
        throw Error("arithmetic overflow");
    }
    //
    // ask-quote incl. slippage
    //
    let ask;
    if (lhz > amount) {
        ask = amount * rhz / (lhz - amount);
    } else {
        throw Error("insufficient liquidity");
    }
    return [[(bid + ask) / 2, bid, ask], stamp];
}
module.exports = { quotes_of };
