// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {BaseTest} from "./Base.t.sol";

contract Borrow_RelExceeded is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public {
        borrow.cap(0, 0);
    }

    function test_mint_0() public {
        borrow.mint(self, 0, false);
    }

    function test_mint_1() public {
        vm.expectRevert(abi.encodeWithSelector(ABS_EXCEEDED, 0));
        borrow.mint(self, 1, false);
    }

    bytes4 immutable ABS_EXCEEDED = IPosition.AbsExceeded.selector;
}

contract Base is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function assert_cap(uint256 cap, uint256 dt) internal view {
        (uint256 all_cap, uint256 all_dt) = borrow.cap();
        assertEq(all_cap, cap);
        assertEq(all_dt, dt);
    }

    function assert_cup(uint256 cup, uint256 dt) internal view {
        (uint256 own_cup, uint256 own_dt) = borrow.capOf(self);
        assertEq(own_cup, cup);
        assertEq(own_dt, dt);
    }

    function expect_err(uint256 cap, uint256 dt) internal {
        vm.expectRevert(abi.encodeWithSelector(CAP_CONSTANT, cap, dt));
    }

    bytes4 immutable CAP_CONSTANT = IPosition.CapConstant.selector;
    bytes4 immutable TOO_LARGE = IParameterized.TooLarge.selector;
    uint256 constant MAX_256 = type(uint256).max;
    uint224 constant MAX_224 = type(uint224).max;
}

contract Borrow_Cap is Base {
    function test_cap(uint224 cap, uint256 dt) public {
        borrow.cap(cap, dt);
    }

    function test_cap_later(uint224 cap, uint256 dt, uint256 timestamp) public {
        borrow.cap(cap, dt);
        vm.warp(timestamp);
        borrow.cap();
    }
}

contract Borrow_CapTooLarge is Base {
    function test_cap(uint256 cap, uint256 dt) public {
        cap = bound(cap, MAX_224 + uint256(1), MAX_256);
        vm.expectRevert(
            abi.encodeWithSelector(TOO_LARGE, borrow.CAP_ID(), cap, MAX_224)
        );
        borrow.cap(cap, dt);
    }
}

contract Borrow_CapConstant_INF is Base {
    function setUp() public {
        borrow.cap(1.0e18, MAX_256);
    }

    function test_cap() public view {
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup() public view {
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_idempotent() public {
        borrow.cap(1.0e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_idempotent() public {
        borrow.cap(1.0e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_increase() public {
        borrow.cap(2.0e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
        vm.warp(block.timestamp + 1);
        assert_cap(2.0e18, MAX_256 - 2);
        // increase cap again
        borrow.cap(4.0e18, MAX_256);
        assert_cap(2.0e18, MAX_256 - 2);
        vm.warp(block.timestamp + 1);
        assert_cap(3.0e18, MAX_256 - 3);
        // increase cap again
        borrow.cap(8.0e18, MAX_256);
        assert_cap(3.0e18, MAX_256 - 3);
        vm.warp(MAX_256); // end-of-time
        assert_cap(8.0e18, 0);
    }

    function test_cup_increase() public {
        borrow.cap(2.0e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
        vm.warp(block.timestamp + 1);
        assert_cup(2.0e18, MAX_256 - 2);
        // increase cap again
        borrow.cap(4.0e18, MAX_256);
        assert_cup(2.0e18, MAX_256 - 2);
        vm.warp(block.timestamp + 1);
        assert_cup(3.0e18, MAX_256 - 3);
        // increase cap again
        borrow.cap(8.0e18, MAX_256);
        assert_cup(3.0e18, MAX_256 - 3);
        vm.warp(MAX_256); // end-of-time
        assert_cup(8.0e18, 0);
    }

    function test_cap_decrease() public {
        expect_err(1.0e18, MAX_256);
        borrow.cap(0.5e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_decrease() public {
        expect_err(1.0e18, MAX_256);
        borrow.cap(0.5e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_extend() public {
        borrow.cap(1.0e18, MAX_256); // [na]
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_extend() public {
        borrow.cap(1.0e18, MAX_256); // [na]
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_reduce() public {
        expect_err(1.0e18, MAX_256);
        borrow.cap(1.0e18, MAX_256 * 0);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_reduce() public {
        expect_err(1.0e18, MAX_256);
        borrow.cap(1.0e18, MAX_256 * 0);
        assert_cup(1.0e18, MAX_256 - 1);
    }
}

contract Borrow_CapConstant_24M is Base {
    function setUp() public {
        borrow.cap(1.0e18, 24 * MONTH);
    }

    function test_cap() public view {
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup() public view {
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cap_idempotent() public {
        borrow.cap(1.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_idempotent() public {
        borrow.cap(1.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }

    function test_cap_increase() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_increase() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }

    function test_cap_decrease() public {
        borrow.cap(0.5e18, 24 * MONTH); // [ok]
        assert_cap(0.5e18, 24 * MONTH);
    }

    function test_cup_decrease() public {
        borrow.cap(0.5e18, 24 * MONTH); // [ok]
        assert_cup(0.5e18, 24 * MONTH);
    }

    function test_cap_extend() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 48 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        borrow.cap(1.0e18, 48 * MONTH); // [ok]
        assert_cap(1.0e18, 48 * MONTH);
        borrow.cap(0.5e18, 48 * MONTH); // [ok]
        assert_cap(0.5e18, 48 * MONTH);
    }

    function test_cup_extend() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 48 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        borrow.cap(1.0e18, 48 * MONTH); // [ok]
        assert_cup(1.0e18, 48 * MONTH);
        borrow.cap(0.5e18, 48 * MONTH); // [ok]
        assert_cup(0.5e18, 48 * MONTH);
    }

    function test_cap_reduce() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(1.0e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(0.5e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_reduce() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(1.0e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(0.5e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }
}

contract Borrow_CapConstant_24M_Later is Base {
    function setUp() public {
        borrow.cap(1.0e18, 24 * MONTH);
    }

    function test_cap() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        skip(12 * MONTH);
        assert_cap(1.0e18, 12 * MONTH);
        ///
        expect_err(1.0e18, 12 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 12 * MONTH);
        skip(12 * MONTH);
        assert_cap(1.0e18, 0);
        ///
        borrow.cap(2.0e18, 48 * MONTH); // [ok]
        assert_cap(1.0e18, 48 * MONTH);
        borrow.cap(2.0e18, 96 * MONTH); // [ok]
        assert_cap(1.0e18, 96 * MONTH);
    }

    function test_cup() public {
        expect_err(1.0e18, 24 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        skip(12 * MONTH);
        assert_cup(1.0e18, 12 * MONTH);
        ///
        expect_err(1.0e18, 12 * MONTH);
        borrow.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 12 * MONTH);
        skip(12 * MONTH);
        assert_cup(1.0e18, 0);
        ///
        borrow.cap(2.0e18, 48 * MONTH); // [ok]
        assert_cup(1.0e18, 48 * MONTH);
        borrow.cap(2.0e18, 96 * MONTH); // [ok]
        assert_cup(1.0e18, 96 * MONTH);
    }
}
