const { argv } = require("./cli-arguments");
const { ethers } = require("ethers");
module.exports = {
    provider: new ethers.JsonRpcProvider(
        argv["rpc-url"]
    )
};
