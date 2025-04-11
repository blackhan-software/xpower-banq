// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {String} from "../../source/library/String.sol";

contract MockToken is ERC20 {
    constructor(
        uint256 supply,
        string memory symbol
    ) ERC20(String.join(symbol, " ", "Token"), symbol) {
        _mint(msg.sender, supply);
    }
}
