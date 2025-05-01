// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {BorrowPosition} from "../../source/contract/Position.sol";
import {ILimited} from "../../source/contract/modifier/Limited.sol";
import {IWPosition} from "../../source/interface/WPosition.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {WPosition} from "../../source/contract/WPosition.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {Health} from "../../source/struct/Health.sol";
import {BaseTest} from "./Base.t.sol";

contract BorrowTest is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public virtual {
        borrow.cap(type(uint224).max, 0);
    }

    bytes4 immutable FORBIDDEN_TRANSFER = IPosition.ForbiddenTransfer.selector;
}

contract Borrow is BorrowTest {
    function test_mint(uint256 amount) public {
        amount = bound(amount, 0, type(uint224).max);
        ///
        assertEq(borrow.balanceOf(self), 0);
        borrow.mint(self, amount, false);
        assertEq(borrow.balanceOf(self), amount);
    }

    function test_burn(uint256 amount) public {
        amount = bound(amount, 0, type(uint224).max);
        ///
        assertEq(borrow.balanceOf(self), 0);
        borrow.mint(self, amount, false);
        assertEq(borrow.balanceOf(self), amount);
        borrow.burn(self, amount, false);
        assertEq(borrow.balanceOf(self), 0);
    }

    function test_model() public view {
        IRModel memory irm = borrow.model();
        assertEq(irm.util, 90 * PCT);
        assertEq(irm.rate, 10 * PCT);
        assertEq(irm.spread, 0);
    }

    function test_totalOf() public view {
        assertEq(borrow.totalOf(self), 0);
    }

    function test_asset() public view {
        assertEq(address(borrow.asset()), address(token));
    }
}

contract Borrow_Index is BorrowTest {
    function setUp() public override {
        supply.cap(type(uint224).max, 0);
        borrow.cap(type(uint224).max, 0);
        supply.mint(self, 1.0e18, false);
        borrow.mint(self, 0.9e18, false);
    }

    function test_reindex() public {
        borrow.reindex();
    }

    function test_reindex_event() public {
        vm.warp(block.timestamp + 24 hours);
        borrow.reindex();
        vm.warp(block.timestamp + 24 hours);
        vm.expectEmit();
        emit Reindex(1.000547_720101_332089e18, 48 hours + 1, 9e17);
        borrow.reindex();
    }

    function test_reindex_limit() public {
        borrow.reindex();
        vm.expectRevert(
            abi.encodeWithSelector(
                ILimited.Limited.selector,
                keccak256(abi.encodePacked(borrow.reindex.selector)),
                24 hours
            )
        );
        borrow.reindex();
    }

    function test_index() public {
        (uint256 value0, uint256 dt0) = borrow.index();
        assertEq(value0, 1.000000_000000_000000e18);
        assertEq(dt0, 0);
        vm.warp(block.timestamp + 24 hours);
        {
            borrow.reindex();
        }
        (uint256 value1, uint256 dt1) = borrow.index();
        assertEq(value1, 1.000273_822561_268515e18);
        assertEq(dt1, 0);
        vm.warp(block.timestamp + 24 hours);
        (uint256 value2, uint256 dt2) = borrow.index();
        assertEq(value2, 1.000547_720101_332089e18);
        assertEq(dt2, 86400);
        {
            borrow.reindex();
        }
        (uint256 value3, uint256 dt3) = borrow.index();
        assertEq(value3, 1.000547_720101_332089e18);
        assertEq(dt3, 0);
        vm.warp(block.timestamp + 24 hours);
        (uint256 value4, uint256 dt4) = borrow.index();
        assertEq(value4, 1.000821_692640_721609e18);
        assertEq(dt4, 86400);
    }

    event Reindex(uint256, uint256, uint256);
}

contract Borrow_Holders is BorrowTest {
    function test_totalHolders_eqz(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 0, 0);
        b = bound(b, 0, 0);
        c = bound(c, 0, 0);
        ///
        assertEq(borrow.totalHolders(), 0);
        assertEq(borrow.balanceOf(address(0xa)), 0);
        borrow.mint(address(0xa), a, false);
        assertEq(borrow.balanceOf(address(0xa)), 0);
        assertEq(borrow.totalHolders(), 0);
        assertEq(borrow.balanceOf(address(0xb)), 0);
        borrow.mint(address(0xb), b, false);
        borrow.burn(address(0xb), b, false);
        borrow.mint(address(0xb), b, false);
        assertEq(borrow.balanceOf(address(0xb)), 0);
        assertEq(borrow.totalHolders(), 0);
        assertEq(borrow.balanceOf(address(0xc)), 0);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        assertEq(borrow.balanceOf(address(0xc)), 0);
        assertEq(borrow.totalHolders(), 0);
    }

    function test_totalHolders_gtz(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 1, type(uint104).max);
        b = bound(b, 1, type(uint104).max);
        c = bound(c, 1, type(uint104).max);
        ///
        assertEq(borrow.totalHolders(), 0);
        assertEq(borrow.balanceOf(address(0xa)), 0);
        borrow.mint(address(0xa), a, false);
        assertEq(borrow.balanceOf(address(0xa)), a);
        assertEq(borrow.totalHolders(), 1);
        assertEq(borrow.balanceOf(address(0xb)), 0);
        borrow.mint(address(0xb), b, false);
        borrow.burn(address(0xb), b, false);
        borrow.mint(address(0xb), b, false);
        assertEq(borrow.balanceOf(address(0xb)), b);
        assertEq(borrow.totalHolders(), 2);
        assertEq(borrow.balanceOf(address(0xc)), 0);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        assertEq(borrow.balanceOf(address(0xc)), c);
        assertEq(borrow.totalHolders(), 3);
    }

    function test_totalHolders_ge1(uint256 a, uint256 b, uint256 c) public {
        a = bound(a, 1e18, type(uint104).max);
        b = bound(b, 1e18, type(uint104).max);
        c = bound(c, 1e18, type(uint104).max);
        ///
        assertEq(borrow.totalHolders(), 0);
        assertEq(borrow.balanceOf(address(0xa)), 0);
        borrow.mint(address(0xa), a, false);
        assertEq(borrow.balanceOf(address(0xa)), a);
        assertEq(borrow.totalHolders(), 1);
        assertEq(borrow.balanceOf(address(0xb)), 0);
        borrow.mint(address(0xb), b, false);
        borrow.burn(address(0xb), b, false);
        borrow.mint(address(0xb), b, false);
        assertEq(borrow.balanceOf(address(0xb)), b);
        assertEq(borrow.totalHolders(), 2);
        assertEq(borrow.balanceOf(address(0xc)), 0);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        borrow.burn(address(0xc), c, false);
        borrow.mint(address(0xc), c, false);
        assertEq(borrow.balanceOf(address(0xc)), c);
        assertEq(borrow.totalHolders(), 3);
    }
}

contract Borrow_ForbiddenTransfer is BorrowTest {
    function setUp() public override {
        super.setUp();
        ///
        borrow.mint(self, 1e18, false);
        borrow.mint(self, 1e18, false);
        _setHealth(Health({wnav_supply: 1e18, wnav_borrow: 1e18}));
    }

    function test_transfer(uint256 amount) public {
        vm.expectRevert(abi.encodeWithSelector(FORBIDDEN_TRANSFER, self, papa));
        borrow.transfer(papa, bound(amount, 1, 1e18));
    }

    function test_transferFrom(uint256 amount) public {
        borrow.approve(self, bound(amount, 1, 1e18));
        vm.expectRevert(abi.encodeWithSelector(FORBIDDEN_TRANSFER, self, papa));
        borrow.transferFrom(self, papa, bound(amount, 1, 1e18));
    }
}

contract Borrow_Wrap is BorrowTest {
    function setUp() public override {
        super.setUp();
        wb = new WPosition(borrow);
    }

    function test_wrap(uint256 amount) public returns (uint256 shares) {
        amount = bound(amount, 1, type(uint224).max);
        ///
        assertEq(borrow.balanceOf(papa), 0);
        borrow.mint(papa, amount, false);
        assertEq(borrow.balanceOf(papa), amount);
        vm.prank(papa);
        borrow.approve(address(wb), amount);
        vm.prank(papa);
        vm.expectRevert(
            abi.encodeWithSelector(FORBIDDEN_TRANSFER, papa, address(wb))
        );
        assertEq(shares = wb.deposit(amount, papa), 0);
        assertEq(borrow.balanceOf(papa), amount);
    }

    function test_unwrap() public {
        vm.expectPartialRevert(FORBIDDEN_TRANSFER);
        wb.redeem(0, papa, papa);
    }

    IWPosition wb;
}
