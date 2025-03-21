// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {stdError} from "forge-std/Test.sol";

import {IWPosition} from "../../source/interface/WPosition.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(MY_TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

    IERC20Metadata[] MY_TOKENS = [TOKENS[0], TOKENS[1], T18];
    IWPosition W18 = IWPosition(address(0x18));
}

contract SupervisedEnwrap is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
        acma.grantRole(acma.POOL_ENWRAP_ROLE(), self, 0);
        pool.enwrap(2, W18);
    }

    function test_wrapper() public view {
        assertEq(address(pool.wrapperOf(T18)), address(W18));
    }
}

contract SupervisedEnwrap_Event is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
        acma.grantRole(acma.POOL_ENWRAP_ROLE(), self, 0);
    }

    function test_enwrap() public {
        vm.expectEmit();
        emit Enwrap(T18);
        pool.enwrap(2, W18);
    }

    function test_enwrap_oob() public {
        vm.expectRevert(stdError.indexOOBError);
        pool.enwrap(3, W18);
    }

    event Enwrap(IERC20 indexed t);
}

contract SupervisedEnwrap_NotEnlisted is TestBase {
    function test_enwrap() public {
        acma.grantRole(acma.POOL_ENWRAP_ROLE(), self, 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.enwrap(2, W18);
    }

    function test_wrapper() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        assertEq(address(pool.wrapperOf(T18)), address(0));
    }
}

contract SupervisedEnwrap_Unauthorized is TestBase {
    function setUp() public {
        acma.grantRole(acma.POOL_ENLIST_ROLE(), self, 0);
        pool.enlist(2, VAULT0, WEIGHT, RATE_LIMIT);
    }

    function test_enwrap() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        pool.enwrap(2, W18);
    }

    function test_wrapper() public view {
        assertEq(address(pool.wrapperOf(T18)), address(0));
    }
}
