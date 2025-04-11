#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v3.0");
const abi = require("./abi/aggregator-v3.0.json");
/**
 * @see https://data.chain.link/feeds/avalanche/mainnet/usdt-usd
 */
const usdt_usd = new ethers.Contract(
    "0xEBE676ee90Fe1112671f19b6B7459bC678B67e8a", abi, provider
);
quotes_of(argv.amount, usdt_usd, argv.flip).then(
    (data) => log_quote("USDT/USD", data, argv.flip)
);
