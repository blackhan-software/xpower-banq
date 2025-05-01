// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {ILimited} from "../../source/contract/modifier/Limited.sol";
import {IWPosition} from "../../source/interface/WPosition.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {WPosition} from "../../source/contract/WPosition.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {Health} from "../../source/struct/Health.sol";
import {BaseTest} from "./Base.t.sol";

contract SupplyTest is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public virtual {
        supply.cap(type(uint224).max, 0);
    }
}

contract Supply is SupplyTest {
    function test_mint(uint256 amount) public {
        amount = bound(amount, 0, type(uint224).max);
        ///
        assertEq(supply.balanceOf(self), 0);
        supply.mint(self, amount, false);
        assertEq(supply.balanceOf(self), amount);
    }

    function test_burn(uint256 amount) public {
        amount = bound(amount, 0, type(uint224).max);
        ///
        assertEq(supply.balanceOf(self), 0);
        supply.mint(self, amount, false);
        assertEq(supply.balanceOf(self), amount);
        supply.burn(self, amount, false);
        assertEq(supply.balanceOf(self), 0);
    }

    function test_model() public view {
        IRModel memory irm = supply.model();
        assertEq(irm.util, 90 * PCT);
        assertEq(irm.rate, 10 * PCT);
        assertEq(irm.spread, 0);
    }

    function test_totalOf() public view {
        assertEq(supply.totalOf(self), 0);
    }

    function test_asset() public view {
        assertEq(address(supply.asset()), address(token));
    }
}

contract Supply_Index is SupplyTest {
    function setUp() public override {
        supply.cap(type(uint224).max, 0);
        borrow.cap(type(uint224).max, 0);
        supply.mint(self, 1.0e18, false);
        borrow.mint(self, 0.9e18, false);
    }

    function test_reindex() public {
        supply.reindex();
    }

    function test_reindex_event() public {
        vm.warp(block.timestamp + 24 hours);
        supply.reindex();
        vm.warp(block.timestamp + 24 hours);
        vm.expectEmit();
        emit Reindex(1.000547_720101_332089e18, 48 hours + 1, 9e17);
        supply.reindex();
    }

    function test_reindex_limit() public {
        supply.reindex();
        vm.expectRevert(
            abi.encodeWithSelector(
                ILimited.Limited.selector,
                keccak256(abi.encodePacked(supply.reindex.selector)),
                24 hours
            )
        );
        supply.reindex();
    }

    function test_index() public {
        (uint256 value0, uint256 dt0) = supply.index();
        assertEq(value0, 1.000000_000000_000000e18);
        assertEq(dt0, 0);
        vm.warp(block.timestamp + 24 hours);
        {
            supply.reindex();
        }
        (uint256 value1, uint256 dt1) = supply.index();
        assertEq(value1, 1.000273_822561_268515e18);
        assertEq(dt1, 0);
        vm.warp(block.timestamp + 24 hours);
        (uint256 value2, uint256 dt2) = supply.index();
        assertEq(value2, 1.000547_720101_332089e18);
        assertEq(dt2, 86400);
        {
            supply.reindex();
        }
        (uint256 value3, uint256 dt3) = supply.index();
        assertEq(value3, 1.000547_720101_332089e18);
        assertEq(dt3, 0);
        vm.warp(block.timestamp + 24 hours);
        (uint256 value4, uint256 dt4) = supply.index();
        assertEq(value4, 1.000821_692640_721609e18);
        assertEq(dt4, 86400);
    }

    event Reindex(uint256, uint256, uint256);
}

contract Supply_Holders is SupplyTest {
    function test_totalHolders_eqz(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 0, 0);
        b = bound(b, 0, 0);
        c = bound(c, 0, 0);
        ///
        assertEq(supply.totalHolders(), 0);
        assertEq(supply.balanceOf(address(0xa)), 0);
        supply.mint(address(0xa), a, false);
        assertEq(supply.balanceOf(address(0xa)), 0);
        assertEq(supply.totalHolders(), 0);
        assertEq(supply.balanceOf(address(0xb)), 0);
        supply.mint(address(0xb), b, false);
        supply.burn(address(0xb), b, false);
        supply.mint(address(0xb), b, false);
        assertEq(supply.balanceOf(address(0xb)), 0);
        assertEq(supply.totalHolders(), 0);
        assertEq(supply.balanceOf(address(0xc)), 0);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        assertEq(supply.balanceOf(address(0xc)), 0);
        assertEq(supply.totalHolders(), 0);
    }

    function test_totalHolders_gtz(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 1, type(uint104).max);
        b = bound(b, 1, type(uint104).max);
        c = bound(c, 1, type(uint104).max);
        ///
        assertEq(supply.totalHolders(), 0);
        assertEq(supply.balanceOf(address(0xa)), 0);
        supply.mint(address(0xa), a, false);
        assertEq(supply.balanceOf(address(0xa)), a);
        assertEq(supply.totalHolders(), 1);
        assertEq(supply.balanceOf(address(0xb)), 0);
        supply.mint(address(0xb), b, false);
        supply.burn(address(0xb), b, false);
        supply.mint(address(0xb), b, false);
        assertEq(supply.balanceOf(address(0xb)), b);
        assertEq(supply.totalHolders(), 2);
        assertEq(supply.balanceOf(address(0xc)), 0);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        assertEq(supply.balanceOf(address(0xc)), c);
        assertEq(supply.totalHolders(), 3);
    }

    function test_totalHolders_ge1(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 1e18, type(uint104).max);
        b = bound(b, 1e18, type(uint104).max);
        c = bound(c, 1e18, type(uint104).max);
        ///
        assertEq(supply.totalHolders(), 0);
        assertEq(supply.balanceOf(address(0xa)), 0);
        supply.mint(address(0xa), a, false);
        assertEq(supply.balanceOf(address(0xa)), a);
        assertEq(supply.totalHolders(), 1);
        assertEq(supply.balanceOf(address(0xb)), 0);
        supply.mint(address(0xb), b, false);
        supply.burn(address(0xb), b, false);
        supply.mint(address(0xb), b, false);
        assertEq(supply.balanceOf(address(0xb)), b);
        assertEq(supply.totalHolders(), 2);
        assertEq(supply.balanceOf(address(0xc)), 0);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        supply.burn(address(0xc), c, false);
        supply.mint(address(0xc), c, false);
        assertEq(supply.balanceOf(address(0xc)), c);
        assertEq(supply.totalHolders(), 3);
    }
}

contract Supply_Wrap is SupplyTest {
    function setUp() public override {
        super.setUp();
        ws = new WPosition(supply);
    }

    function test_wrap(uint256 amount) public returns (uint256 shares) {
        amount = bound(amount, 0, type(uint224).max);
        ///
        assertEq(supply.balanceOf(papa), 0);
        supply.mint(papa, amount, false);
        assertEq(supply.balanceOf(papa), amount);
        vm.prank(papa);
        supply.approve(address(ws), amount);
        vm.prank(papa);
        assertEq(shares = ws.deposit(amount, papa), amount);
        assertEq(supply.balanceOf(papa), 0);
    }

    function test_unwrap(uint256 amount) public {
        amount = bound(amount, 0, type(uint224).max);
        uint256 shares = test_wrap(amount);
        ///
        vm.prank(papa);
        assertEq(ws.redeem(shares, papa, papa), amount);
        assertEq(supply.balanceOf(papa), amount);
    }

    IWPosition ws;
}

contract Supply_InsufficientHealth is SupplyTest {
    function setUp() public override {
        super.setUp();
        ///
        supply.mint(self, 1e18, false);
        _setHealth(Health({wnav_supply: 1e18, wnav_borrow: 0}));
    }

    function test_transfer(uint256 amount) public {
        amount = bound(amount, 1, 5e17);
        supply.transfer(papa, amount);
        ///
        _setHealth(Health({wnav_supply: 1e18 - amount, wnav_borrow: 1e18}));
        vm.expectRevert(
            abi.encodeWithSelector(INSUFFICIENT_HEALTH, 1e18 - amount, 1e18)
        );
        vm.prank(papa);
        supply.transfer(papa, amount);
    }

    function test_transferFrom(uint256 amount) public {
        amount = bound(amount, 1, 5e17);
        supply.approve(self, amount);
        supply.transferFrom(self, papa, amount);
        ///
        supply.approve(papa, amount);
        _setHealth(Health({wnav_supply: 1e18 - amount, wnav_borrow: 1e18}));
        vm.expectRevert(
            abi.encodeWithSelector(INSUFFICIENT_HEALTH, 1e18 - amount, 1e18)
        );
        vm.prank(papa);
        supply.transferFrom(self, papa, amount);
    }

    bytes4 immutable INSUFFICIENT_HEALTH =
        IPosition.InsufficientHealth.selector;
}
