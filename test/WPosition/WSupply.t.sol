// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IWPosition} from "../../source/interface/WPosition.sol";
import {BaseTest} from "./Base.t.sol";

contract WSupply is BaseTest {
    uint256 constant TOTAL = 1.105170_918075_647624e18;
    address internal immutable wsupply_a;

    constructor() BaseTest(VAULT_NIL, IR_MODEL) {
        wsupply_a = address(wsupply);
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
        return wsupply.maxWithdraw(account);
    }

    function maxRedeem(address account) internal view returns (uint256) {
        return wsupply.maxRedeem(account);
    }
}

contract WSupply_Metadata is WSupply {
    function test_name() public view {
        IERC20Metadata meta = IERC20Metadata(wsupply_a);
        assertEq(meta.name(), "Wrapped ABCToken Supply");
    }

    function test_symbol() public view {
        IERC20Metadata meta = IERC20Metadata(wsupply_a);
        assertEq(meta.symbol(), "wsABC:XYZ");
    }

    function test_token() public view {
        assertEq(address(wsupply.asset()), address(supply));
    }
}

contract WSupply_Deposit is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.deposit(ONE, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), ONE);
        assertEq(supply.balanceOf(papa), 0);
    }

    function test_totalOfPapa() public {
        assertEq(supply.totalOf(papa), 0);
        skip(12 * MONTH);
        assertEq(supply.totalOf(papa), 0);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), ONE);
    }

    function test_totalOfWrap() public {
        assertEq(supply.totalOf(wsupply_a), ONE);
        skip(12 * MONTH);
        assertEq(supply.totalOf(wsupply_a), TOTAL);
    }

    function test_totalAssets() public {
        assertEq(wsupply.totalAssets(), ONE);
        skip(12 * MONTH);
        assertEq(wsupply.totalAssets(), TOTAL);
    }
}

contract WSupply_Mint is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.mint(ONE, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), ONE);
        assertEq(supply.balanceOf(papa), 0);
    }

    function test_totalOfPapa() public {
        assertEq(supply.totalOf(papa), 0);
        skip(12 * MONTH);
        assertEq(supply.totalOf(papa), 0);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), ONE);
    }

    function test_totalOfWrap() public {
        assertEq(supply.totalOf(wsupply_a), ONE);
        skip(12 * MONTH);
        assertEq(supply.totalOf(wsupply_a), TOTAL);
    }

    function test_totalAssets() public {
        assertEq(wsupply.totalAssets(), ONE);
        skip(12 * MONTH);
        assertEq(wsupply.totalAssets(), TOTAL);
    }
}

contract WSupply_Withdraw is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.deposit(ONE, papa);
        vm.stopPrank();
        ///
        vm.startPrank(papa);
        wsupply.withdraw(maxWithdraw(papa), papa, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), 0);
        assertEq(supply.balanceOf(papa), ONE);
    }

    function test_totalOfPapa() public view {
        assertEq(supply.totalOf(papa), ONE);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), 0);
    }

    function test_totalOfWrap() public view {
        assertEq(supply.totalOf(wsupply_a), 0);
    }

    function test_totalAssets() public view {
        assertEq(wsupply.totalAssets(), 0);
    }
}

contract WSupply_Withdraw_12M is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.deposit(ONE, papa);
        vm.stopPrank();
        ///
        skip(12 * MONTH);
        ///
        vm.startPrank(papa);
        wsupply.withdraw(maxWithdraw(papa), papa, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), 0);
        assertEq(supply.balanceOf(papa), TOTAL - 1);
    }

    function test_totalOfPapa() public view {
        assertEq(supply.totalOf(papa), TOTAL - 1);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), 1);
    }

    function test_totalOfWrap() public view {
        assertEq(supply.totalOf(wsupply_a), 1);
    }

    function test_totalAssets() public view {
        assertEq(wsupply.totalAssets(), 1);
    }
}

contract WSupply_Redeem is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.mint(ONE, papa);
        vm.stopPrank();
        ///
        vm.startPrank(papa);
        wsupply.redeem(maxRedeem(papa), papa, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), 0);
        assertEq(supply.balanceOf(papa), ONE);
    }

    function test_totalOfPapa() public view {
        assertEq(supply.totalOf(papa), ONE);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), 0);
    }

    function test_totalOfWrap() public view {
        assertEq(supply.totalOf(wsupply_a), 0);
    }

    function test_totalAssets() public view {
        assertEq(wsupply.totalAssets(), 0);
    }
}

contract WSupply_Redeem_12M is WSupply {
    function setUp() public override {
        super.setUp();
        ///
        vm.startPrank(papa);
        supply.approve(wsupply_a, ONE);
        wsupply.mint(ONE, papa);
        vm.stopPrank();
        ///
        skip(12 * MONTH);
        ///
        vm.startPrank(papa);
        wsupply.redeem(maxRedeem(papa), papa, papa);
        vm.stopPrank();
    }

    function test_balanceOfPapa() public view {
        assertEq(wsupply.balanceOf(papa), 0);
        assertEq(supply.balanceOf(papa), TOTAL - 1);
    }

    function test_totalOfPapa() public view {
        assertEq(supply.totalOf(papa), TOTAL - 1);
    }

    function test_balanceOfWrap() public view {
        assertEq(supply.balanceOf(wsupply_a), 1);
    }

    function test_totalOfWrap() public view {
        assertEq(supply.totalOf(wsupply_a), 1);
    }

    function test_totalAssets() public view {
        assertEq(wsupply.totalAssets(), 1);
    }
}
