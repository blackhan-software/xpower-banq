#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v2.1");
const abi = require("./abi/lb-pair-v2.1.json");
/**
 * @see https://snowtrace.io/address/0x87EB2F90d7D0034571f343fb7429AE22C1Bd9F72
 */
const avax_usdt = new ethers.Contract(
    "0x87EB2F90d7D0034571f343fb7429AE22C1Bd9F72", abi, provider
);
quotes_of(argv.amount, avax_usdt, argv.flip).then(
    (data) => log_quote("AVAX/USDT", data, argv.flip)
);
