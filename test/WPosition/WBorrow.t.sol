// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC4626, ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IWPosition} from "../../source/interface/WPosition.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {BaseTest} from "./Base.t.sol";

contract WBorrow is BaseTest {
    uint256 constant TOTAL = 1.105170_918075_647624e18;
    address internal immutable wborrow_a;

    constructor() BaseTest(VAULT_NIL, IR_MODEL) {
        wborrow_a = address(wborrow);
    }

    function setUp() public virtual {
        supply.cap(type(uint224).max, 0);
        borrow.cap(type(uint224).max, 0);
        ///
        vm.prank(self);
        supply.mint(papa, ONE, false);
        vm.prank(self);
        borrow.mint(papa, 0.9e18, false);
    }

    function maxWithdraw(address account) internal view returns (uint256) {
        return wborrow.maxWithdraw(account);
    }

    function maxRedeem(address account) internal view returns (uint256) {
        return wborrow.maxRedeem(account);
    }
}

contract WBorrow_Metadata is WBorrow {
    function test_name() public view {
        IERC20Metadata meta = IERC20Metadata(wborrow_a);
        assertEq(meta.name(), "Wrapped ABCToken Borrow");
    }

    function test_symbol() public view {
        IERC20Metadata meta = IERC20Metadata(wborrow_a);
        assertEq(meta.symbol(), "wbABC:XYZ");
    }

    function test_token() public view {
        assertEq(address(wborrow.asset()), address(borrow));
    }
}

contract WBorrow_Deposit is WBorrow {
    function test_deposit() public {
        vm.prank(papa);
        borrow.approve(wborrow_a, ONE);
        vm.prank(papa);
        vm.expectRevert(
            abi.encodeWithSelector(FORBIDDEN_TRANSFER, papa, address(wborrow))
        );
        wborrow.deposit(ONE, papa);
    }

    bytes4 FORBIDDEN_TRANSFER = IPosition.ForbiddenTransfer.selector;
}

contract WBorrow_Mint is WBorrow {
    function test_mint() public {
        vm.prank(papa);
        borrow.approve(wborrow_a, ONE);
        vm.prank(papa);
        vm.expectRevert(
            abi.encodeWithSelector(FORBIDDEN_TRANSFER, papa, address(wborrow))
        );
        wborrow.mint(ONE, papa);
    }

    bytes4 FORBIDDEN_TRANSFER = IPosition.ForbiddenTransfer.selector;
}

contract WBorrow_Withdraw is WBorrow {
    function test_withdraw() public {
        vm.prank(papa);
        vm.expectRevert(
            abi.encodeWithSelector(MAX_WITHDRAW, papa, ONE, maxWithdraw(papa))
        );
        wborrow.withdraw(ONE, papa, papa);
    }

    bytes4 MAX_WITHDRAW = ERC4626.ERC4626ExceededMaxWithdraw.selector;
}

contract WBorrow_Redeem is WBorrow {
    function test_redeem() public {
        vm.prank(papa);
        vm.expectRevert(
            abi.encodeWithSelector(MAX_REDEEM, papa, ONE, maxRedeem(papa))
        );
        wborrow.redeem(ONE, papa, papa);
    }

    bytes4 MAX_REDEEM = ERC4626.ERC4626ExceededMaxRedeem.selector;
}
