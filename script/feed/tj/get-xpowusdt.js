#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0xBCba353C3bba23ad3fC6d6f24349caF209A7Cbbe
 */
const xpow_usdt = new ethers.Contract(
    "0xBCba353C3bba23ad3fC6d6f24349caF209A7Cbbe", abi, provider
);
quotes_of(argv.amount, xpow_usdt, argv.flip).then(
    (data) => log_quote("XPOW/USDT", data, argv.flip)
);
