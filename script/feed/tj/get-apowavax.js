#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0x2F32f5224669e48B3bB34691C3D9Ab974d776C09
 */
const apow_avax = new ethers.Contract(
    "0x2F32f5224669e48B3bB34691C3D9Ab974d776C09", abi, provider
);
quotes_of(argv.amount, apow_avax, argv.flip).then(
    (data) => log_quote("APOW/AVAX", data, argv.flip)
);
