#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const abi = require("./abi/IERC20Metadata.json");
/**
 * Queries quotes of a (tokenX, tokenY) pair; with the
 * [mid, bid, ask] result in tokenY units.
 *
 * @param {Number} amount quoted in tokenX units.
 * @param {ethers.Contract} pair of (tokenX, tokenY)
 * @returns {Promise<[Number, Number, Number]>} [mid, bid, ask]
 */
async function quotes_of(amount, pair, flip) {
    const [bid, ask] = await unitsOf(pair, flip).then(
        ([ux, uy]) => Promise.all([
            bid_of(amount * ux, pair, flip).then((b) => b / uy),
            ask_of(amount * ux, pair, flip).then((a) => a / uy),
        ])
    );
    return [(bid + ask) / 2, bid, ask];
}
async function unitsOf(pair, flip) {
    const [token_x, token_y] = await Promise.all([
        pair.getTokenX(),
        pair.getTokenY(),
    ]);
    const [meta_x, meta_y] = [
        new ethers.Contract(token_x, abi, provider),
        new ethers.Contract(token_y, abi, provider),
    ];
    const [decimals_x, decimals_y] = await Promise.all([
        meta_x.decimals(),
        meta_y.decimals(),
    ]);
    return !flip ? [
        10 ** Number(decimals_x),
        10 ** Number(decimals_y),
    ] : [
        10 ** Number(decimals_y),
        10 ** Number(decimals_x),
    ];
}
async function bid_of(
    amount_in, pair, flip
) {
    const [left, bid] = await pair.getSwapOut(
        BigInt(amount_in), !flip
    );
    if (left > 0) {
        throw Error("insufficient liquidity");
    }
    return Number(bid);
}
async function ask_of(
    amount_out, pair, flip
) {
    const [ask, left] = await pair.getSwapIn(
        BigInt(amount_out), flip
    );
    if (left > 0) {
        throw Error("insufficient liquidity");
    }
    return Number(ask);
}
module.exports = { quotes_of };
