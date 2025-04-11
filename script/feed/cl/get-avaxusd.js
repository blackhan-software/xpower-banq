#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v3.0");
const abi = require("./abi/aggregator-v3.0.json");
/**
 * @see https://data.chain.link/feeds/avalanche/mainnet/avax-usd
 */
const avax_usd = new ethers.Contract(
    "0x0A77230d17318075983913bC2145DB16C7366156", abi, provider
);
quotes_of(argv.amount, avax_usd, argv.flip).then(
    (data) => log_quote("AVAX/USD", data, argv.flip)
);
