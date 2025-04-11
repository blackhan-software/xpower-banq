#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v2.1");
const abi = require("./abi/lb-pair-v2.1.json");
/**
 * @see https://snowtrace.io/address/0xD446eb1660F766d533BeCeEf890Df7A69d26f7d1
 */
const avax_usdc = new ethers.Contract(
    "0xD446eb1660F766d533BeCeEf890Df7A69d26f7d1", abi, provider
);
quotes_of(argv.amount, avax_usdc, argv.flip).then(
    (data) => log_quote("AVAX/USDC", data, argv.flip)
);
