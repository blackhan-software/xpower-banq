// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {stdError} from "forge-std/Test.sol";

import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(MY_TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

    IERC20Metadata[] MY_TOKENS = [TOKENS[0], TOKENS[1], T18];
}

contract SupervisedEnlist is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
    }

    function test_enlisted() public view {
        assertEq(pool.enlisted(T18), true);
    }

    function test_unlisted() public view {
        assertEq(pool.unlisted(T18), false);
    }
}

contract SupervisedEnlist_Event is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
    }

    function test_enlist() public {
        vm.expectEmit();
        emit Enlist(T18);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
    }

    function test_enlist_oob() public {
        vm.expectRevert(stdError.indexOOBError);
        pool.enlist(3, VAULT0, WEIGHT, RATE_LIMIT);
    }

    event Enlist(IERC20 indexed t);
}

contract SupervisedEnlist_NotUnlisted is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
        acma.revokeRole(acma.POOL_ENLIST_ROLE(), self);
    }

    function test_enlist() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotUnlisted.selector, T18)
        );
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
    }

    function test_enlisted() public view {
        assertEq(pool.enlisted(T18), true);
    }

    function test_unlisted() public view {
        assertEq(pool.unlisted(T18), false);
    }
}

contract SupervisedEnlist_Unauthorized is TestBase {
    function test_enlist() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
    }

    function test_enlisted() public view {
        assertEq(pool.enlisted(T18), false);
    }

    function test_unlisted() public view {
        assertEq(pool.unlisted(T18), true);
    }
}
