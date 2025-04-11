#!/usr/bin/env node
const { ethers } = require("ethers");
const { provider } = require("../provider");
const { argv } = require("../cli-arguments");
const { log_quote } = require("../log-quote");
const { quotes_of } = require("./quotes-v1.0");
const abi = require("./abi/joe-pair-v1.0.json");
/**
 * @see https://snowtrace.io/address/0x2eFC75dE53c18f891A2bd2130e3bF166c4150e3e
 */
const apow_usdc = new ethers.Contract(
    "0x2eFC75dE53c18f891A2bd2130e3bF166c4150e3e", abi, provider
);
quotes_of(argv.amount, apow_usdc, argv.flip).then(
    (data) => log_quote("APOW/USDC", data, argv.flip)
);
