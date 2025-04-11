// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {WPosition} from "../../source/contract/WPosition.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        uint256 pool_index,
        string memory symbol,
        uint256 index
    ) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IERC20Metadata token = tokenOf(symbol);
        IPosition sp = pool.supplyOf(token);
        assert(sp != IPosition(address(0)));
        vm.startBroadcast();
        acma.grantRole(acma.POOL_ENWRAP_ADMIN_ROLE(), msg.sender, 0);
        acma.grantRole(acma.POOL_ENWRAP_ROLE(), msg.sender, 0);
        pool.enwrap(index, new WPosition(sp));
        acma.revokeRole(acma.POOL_ENWRAP_ROLE(), msg.sender);
        acma.revokeRole(acma.POOL_ENWRAP_ADMIN_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}
