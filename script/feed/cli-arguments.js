const argv = require('minimist')(process.argv.slice(2), {
    default: {
        "rpc-url": "https://api.avax.network/ext/bc/C/rpc",
        "date": false, "ask": false, "flip": false,
        "time": false, "bid": false,
        "precision": 2,
        "amount": 1,
    },
    alias: {
        u: "rpc-url",
        d: "date", a: "ask", f: "flip",
        t: "time", b: "bid",
        p: "precision",
        n: "amount",
    },
});
module.exports = { argv };
