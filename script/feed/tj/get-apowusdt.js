#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0x507041280Dce58C15FADB1De57eb8618163Cb7C6
 */
const apow_usdt = new ethers.Contract(
    "0x507041280Dce58C15FADB1De57eb8618163Cb7C6", abi, provider
);
quotes_of(argv.amount, apow_usdt, argv.flip).then(
    (data) => log_quote("APOW/USDT", data, argv.flip)
);
