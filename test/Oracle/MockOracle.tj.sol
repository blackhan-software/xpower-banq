// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {MockFeed_V1, MockPrice} from "../Feed/traderjoe/MockFeed-v1.0.sol";
import {Oracle} from "../../source/contract/Oracle.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {Token} from "../../source/library/Token.sol";

contract TJMockOracle is Oracle {
    function name() external pure override returns (string memory) {
        return "TJ/Mock Oracle";
    }

    constructor(
        MockPrice[] memory prices,
        IAcma acma
    ) Oracle(DECAY_12HL, 1 hours, 14 days, acma) {
        _mock = new MockFeed_V1(prices);
        _feed[bidToken()][askToken()] = _mock;
    }

    function bidToken() public view returns (IERC20) {
        return IERC20(_mock.getBidToken());
    }

    function askToken() public view returns (IERC20) {
        return IERC20(_mock.getAskToken());
    }

    MockFeed_V1 immutable _mock;
}
