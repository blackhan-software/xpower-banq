#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0xB40eA51B243bEc143236B2E54AF5E156C9ac45Af
 */
const xpow_apow = new ethers.Contract(
    "0xB40eA51B243bEc143236B2E54AF5E156C9ac45Af", abi, provider
);
quotes_of(argv.amount, xpow_apow, argv.flip).then(
    (data) => log_quote("XPOW/APOW", data, argv.flip)
);
