// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {SupplyPosition} from "../../source/contract/Position.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {BaseTest} from "./Base.t.sol";

contract Supply_RelExceeded is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public {
        supply.cap(0, 0);
    }

    function test_mint_0() public {
        supply.mint(self, 0, false);
    }

    function test_mint_1() public {
        vm.expectRevert(abi.encodeWithSelector(ABS_EXCEEDED, 0));
        supply.mint(self, 1, false);
    }

    bytes4 immutable ABS_EXCEEDED = IPosition.AbsExceeded.selector;
}

contract Base is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function assert_cap(uint256 cap, uint256 dt) internal view {
        (uint256 all_cap, uint256 all_dt) = supply.cap();
        assertEq(all_cap, cap);
        assertEq(all_dt, dt);
    }

    function assert_cup(uint256 cup, uint256 dt) internal view {
        (uint256 own_cup, uint256 own_dt) = supply.capOf(self);
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

contract Supply_Cap is Base {
    function test_cap(uint224 cap, uint256 dt) public {
        supply.cap(cap, dt);
    }

    function test_cap_later(uint224 cap, uint256 dt, uint256 timestamp) public {
        supply.cap(cap, dt);
        vm.warp(timestamp);
        supply.cap();
    }
}

contract Supply_CapTooLarge is Base {
    function test_cap(uint256 cap, uint256 dt) public {
        cap = bound(cap, MAX_224 + uint256(1), MAX_256);
        vm.expectRevert(
            abi.encodeWithSelector(TOO_LARGE, supply.CAP_ID(), cap, MAX_224)
        );
        supply.cap(cap, dt);
    }
}

contract Supply_CapConstant_INF is Base {
    function setUp() public {
        supply.cap(1.0e18, MAX_256);
    }

    function test_cap() public view {
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup() public view {
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_idempotent() public {
        supply.cap(1.0e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_idempotent() public {
        supply.cap(1.0e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_increase() public {
        supply.cap(2.0e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
        vm.warp(block.timestamp + 1);
        assert_cap(2.0e18, MAX_256 - 2);
        // increase cap again
        supply.cap(4.0e18, MAX_256);
        assert_cap(2.0e18, MAX_256 - 2);
        vm.warp(block.timestamp + 1);
        assert_cap(3.0e18, MAX_256 - 3);
        // increase cap again
        supply.cap(8.0e18, MAX_256);
        assert_cap(3.0e18, MAX_256 - 3);
        vm.warp(MAX_256); // end-of-time
        assert_cap(8.0e18, 0);
    }

    function test_cup_increase() public {
        supply.cap(2.0e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
        vm.warp(block.timestamp + 1);
        assert_cup(2.0e18, MAX_256 - 2);
        // increase cap again
        supply.cap(4.0e18, MAX_256);
        assert_cup(2.0e18, MAX_256 - 2);
        vm.warp(block.timestamp + 1);
        assert_cup(3.0e18, MAX_256 - 3);
        // increase cap again
        supply.cap(8.0e18, MAX_256);
        assert_cup(3.0e18, MAX_256 - 3);
        vm.warp(MAX_256); // end-of-time
        assert_cup(8.0e18, 0);
    }

    function test_cap_decrease() public {
        expect_err(1.0e18, MAX_256);
        supply.cap(0.5e18, MAX_256);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_decrease() public {
        expect_err(1.0e18, MAX_256);
        supply.cap(0.5e18, MAX_256);
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_extend() public {
        supply.cap(1.0e18, MAX_256); // [na]
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_extend() public {
        supply.cap(1.0e18, MAX_256); // [na]
        assert_cup(1.0e18, MAX_256 - 1);
    }

    function test_cap_reduce() public {
        expect_err(1.0e18, MAX_256);
        supply.cap(1.0e18, MAX_256 * 0);
        assert_cap(1.0e18, MAX_256 - 1);
    }

    function test_cup_reduce() public {
        expect_err(1.0e18, MAX_256);
        supply.cap(1.0e18, MAX_256 * 0);
        assert_cup(1.0e18, MAX_256 - 1);
    }
}

contract Supply_CapConstant_24M is Base {
    function setUp() public {
        supply.cap(1.0e18, 24 * MONTH);
    }

    function test_cap() public view {
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup() public view {
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cap_idempotent() public {
        supply.cap(1.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_idempotent() public {
        supply.cap(1.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }

    function test_cap_increase() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_increase() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }

    function test_cap_decrease() public {
        supply.cap(0.5e18, 24 * MONTH); // [ok]
        assert_cap(0.5e18, 24 * MONTH);
    }

    function test_cup_decrease() public {
        supply.cap(0.5e18, 24 * MONTH); // [ok]
        assert_cup(0.5e18, 24 * MONTH);
    }

    function test_cap_extend() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 48 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        supply.cap(1.0e18, 48 * MONTH); // [ok]
        assert_cap(1.0e18, 48 * MONTH);
        supply.cap(0.5e18, 48 * MONTH); // [ok]
        assert_cap(0.5e18, 48 * MONTH);
    }

    function test_cup_extend() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 48 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        supply.cap(1.0e18, 48 * MONTH); // [ok]
        assert_cup(1.0e18, 48 * MONTH);
        supply.cap(0.5e18, 48 * MONTH); // [ok]
        assert_cup(0.5e18, 48 * MONTH);
    }

    function test_cap_reduce() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(1.0e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(0.5e18, 12 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
    }

    function test_cup_reduce() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(1.0e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(0.5e18, 12 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
    }
}

contract Supply_CapConstant_24M_Later is Base {
    function setUp() public {
        supply.cap(1.0e18, 24 * MONTH);
    }

    function test_cap() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 24 * MONTH);
        skip(12 * MONTH);
        assert_cap(1.0e18, 12 * MONTH);
        ///
        expect_err(1.0e18, 12 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cap(1.0e18, 12 * MONTH);
        skip(12 * MONTH);
        assert_cap(1.0e18, 0);
        ///
        supply.cap(2.0e18, 48 * MONTH); // [ok]
        assert_cap(1.0e18, 48 * MONTH);
        supply.cap(2.0e18, 96 * MONTH); // [ok]
        assert_cap(1.0e18, 96 * MONTH);
    }

    function test_cup() public {
        expect_err(1.0e18, 24 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 24 * MONTH);
        skip(12 * MONTH);
        assert_cup(1.0e18, 12 * MONTH);
        ///
        expect_err(1.0e18, 12 * MONTH);
        supply.cap(2.0e18, 24 * MONTH);
        assert_cup(1.0e18, 12 * MONTH);
        skip(12 * MONTH);
        assert_cup(1.0e18, 0);
        ///
        supply.cap(2.0e18, 48 * MONTH); // [ok]
        assert_cup(1.0e18, 48 * MONTH);
        supply.cap(2.0e18, 96 * MONTH); // [ok]
        assert_cup(1.0e18, 96 * MONTH);
    }
}
