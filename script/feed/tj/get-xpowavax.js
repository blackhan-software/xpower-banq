#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0x0283750aef70b1481bbb7b31a96212bb3c440fed
 */
const xpow_avax = new ethers.Contract(
    "0x0283750aef70b1481bbb7b31a96212bb3c440fed", abi, provider
);
quotes_of(argv.amount, xpow_avax, argv.flip).then(
    (data) => log_quote("XPOW/AVAX", data, argv.flip)
);
