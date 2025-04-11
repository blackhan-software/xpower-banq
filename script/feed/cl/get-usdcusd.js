#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v3.0");
const abi = require("./abi/aggregator-v3.0.json");
/**
 * @see https://data.chain.link/feeds/avalanche/mainnet/usdc-usd
 */
const usdc_usd = new ethers.Contract(
    "0xF096872672F44d6EBA71458D74fe67F9a77a23B9", abi, provider
);
quotes_of(argv.amount, usdc_usd, argv.flip).then(
    (data) => log_quote("USDC/USD", data, argv.flip)
);
