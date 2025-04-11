// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {String} from "../../source/library/String.sol";
import {Token} from "../../source/library/Token.sol";
import {Quote} from "../../source/struct/Quote.sol";
import {console} from "forge-std/console.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        string memory oracle_name,
        string memory source_symbol,
        string memory target_symbol
    ) external view {
        IOracle oracle = IOracle(addressOf(oracle_name));
        IERC20 source = tokenOf(source_symbol);
        IERC20 target = tokenOf(target_symbol);
        console_log(oracle, source, target);
    }

    function console_log(
        IOracle oracle,
        IERC20 source,
        IERC20 target
    ) internal view {
        (uint256 bid, uint256 ask) = oracle.getQuotes(
            Token.unitOf(source),
            source,
            target
        );
        string memory symbol = String.join(
            Token.symbolOf(source),
            Token.symbolOf(target)
        );
        console.log(symbol, bid, ask);
    }
}
