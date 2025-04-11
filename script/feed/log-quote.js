const { argv } = require("./cli-arguments");
/**
 * @param {string} symbol
 * @param {[number, number, number, Date]} data
 */
function log_quote(
    symbol, [mid, bid, ask, stamp], flip
) {
    const [mids, bids, asks, datetime] = [
        mid.toLocaleString("en-US", {
            minimumFractionDigits: argv["precision"],
            maximumFractionDigits: argv["precision"]
        }),
        bid.toLocaleString("en-US", {
            minimumFractionDigits: argv["precision"],
            maximumFractionDigits: argv["precision"]
        }),
        ask.toLocaleString("en-US", {
            minimumFractionDigits: argv["precision"],
            maximumFractionDigits: argv["precision"]
        }),
        (stamp ?? new Date()).toISOString().split("T")
    ];
    const args = [];
    if (argv["date"]) {
        args.push(datetime[0]);
    }
    if (argv["time"]) {
        args.push(datetime[1]);
    }
    if (args.length) {
        args.unshift("@");
    }
    if (argv["ask"] || argv["bid"]) {
        args.unshift(']');
        if (argv["ask"]) args.unshift(asks);
        args.unshift(':');
        if (argv["bid"]) args.unshift(bids);
        args.unshift('[');
    }
    console.log(
        flipped(symbol, flip), mids, ...args
    );
}
function flipped(symbol, flip) {
    if (flip) {
        return symbol.split("/").reverse().join("/");
    }
    return symbol;
}
module.exports = { log_quote };
