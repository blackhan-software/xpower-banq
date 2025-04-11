// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import {ISupplyPosition} from "../../source/interface/Position.sol";
import {IBorrowPosition} from "../../source/interface/Position.sol";
import {IVault} from "../../source/interface/Vault.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {IAcma} from "../../source/interface/Acma.sol";

import {Selector} from "../../source/library/Selector.sol";
import {String} from "../../source/library/String.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    using SupplyInit for ISupplyPosition;
    using BorrowInit for IBorrowPosition;
    using VaultInit for IVault;

    function run(uint256 pool_index, string memory symbol) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IERC20Metadata token = tokenOf(symbol);
        vm.startBroadcast();
        acma.grantRole(acma.ACMA_RELATE_ADMIN_ROLE(), msg.sender, 0);
        acma.grantRole(acma.ACMA_RELATE_ROLE(), msg.sender, 0);
        pool.supplyOf(token).enroll(acma);
        pool.borrowOf(token).enroll(acma);
        pool.vaultOf(token).enroll(acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), msg.sender);
        acma.revokeRole(acma.ACMA_RELATE_ADMIN_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}

library SupplyInit {
    function enroll(ISupplyPosition sp, IAcma acma) internal {
        assert(address(sp) != address(0));
        acma.relate(
            address(sp),
            Selector.SET_TARGET,
            acma.SUPPLY_SET_TARGET_ROLE()
        );
    }
}

library BorrowInit {
    function enroll(IBorrowPosition bp, IAcma acma) internal {
        assert(address(bp) != address(0));
        acma.relate(
            address(bp),
            Selector.SET_TARGET,
            acma.BORROW_SET_TARGET_ROLE()
        );
    }
}

library VaultInit {
    function enroll(IVault vt, IAcma acma) internal {
        assert(address(vt) != address(0));
        acma.relate(
            address(vt),
            Selector.SET_TARGET,
            acma.VAULT_SET_TARGET_ROLE()
        );
    }
}
