#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0xE41b1699c36d2fBDE1A7eB2529758753f97617b0
 */
const xpow_usdc = new ethers.Contract(
    "0xE41b1699c36d2fBDE1A7eB2529758753f97617b0", abi, provider
);
quotes_of(argv.amount, xpow_usdc, argv.flip).then(
    (data) => log_quote("XPOW/USDC", data, argv.flip)
);
