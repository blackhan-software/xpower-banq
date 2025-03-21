// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IOracle} from "../../source/interface/Oracle.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {Health} from "../../source/struct/Health.sol";
import {Pool} from "../../source/contract/Pool.sol";

import {PoolTest} from "./Pool.t.sol";
import {Token} from "./Base.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolCtor is TestBase {
    function test_oracle() public view {
        assertEq(address(pool.oracle()), address(DELPHI));
    }

    function test_tokens() public view {
        IERC20Metadata[] memory tokens = pool.tokens();
        assertEq(tokens.length, 2);
    }

    function test_tokens_0() public view {
        IERC20Metadata[] memory tokens = pool.tokens();
        assertEq(address(tokens[0]), address(AVAX));
    }

    function test_tokens_1() public view {
        IERC20Metadata[] memory tokens = pool.tokens();
        assertEq(address(tokens[1]), address(USDC));
    }

    function test_vault() public view {
        assertNotEq(address(vAVAX), address(0));
        assertNotEq(address(vUSDC), address(0));
    }

    function test_supply() public view {
        assertNotEq(address(sAVAX), address(0));
        assertNotEq(address(sUSDC), address(0));
    }

    function test_borrow() public view {
        assertNotEq(address(bAVAX), address(0));
        assertNotEq(address(bUSDC), address(0));
    }

    function test_capSupply() public view {
        (uint256 avax_cap, uint256 avax_dt) = pool.capSupply(AVAX);
        (uint256 usdc_cap, uint256 usdc_dt) = pool.capSupply(USDC);
        assertEq(avax_cap, type(uint224).max);
        assertEq(usdc_cap, type(uint224).max);
        assertEq(avax_dt, 0);
        assertEq(usdc_dt, 0);
    }

    function test_capBorrow() public view {
        (uint256 avax_cap, uint256 avax_dt) = pool.capBorrow(AVAX);
        (uint256 usdc_cap, uint256 usdc_dt) = pool.capBorrow(USDC);
        assertEq(avax_cap, type(uint224).max);
        assertEq(usdc_cap, type(uint224).max);
        assertEq(avax_dt, 0);
        assertEq(usdc_dt, 0);
    }

    function test_health() public view {
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 0);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolCtor_EmptyTokens is TestBase {
    function test_ctor() public {
        vm.expectRevert(abi.encodeWithSelector(INVALID_TOKENS, _tokens));
        new Pool(_tokens, oracle, acma);
    }

    bytes4 INVALID_TOKENS = IPool.InvalidTokens.selector;
    IERC20Metadata[] _tokens;
}

contract PoolCtor_InvalidTokens is TestBase {
    function test_ctor() public {
        vm.expectRevert(abi.encodeWithSelector(INVALID_TOKENS, _tokens));
        new Pool(_tokens, oracle, acma);
    }

    bytes4 INVALID_TOKENS = IPool.InvalidTokens.selector;
    IERC20Metadata[] _tokens;
}

contract PoolCtor_InvalidToken is TestBase {
    function setUp() public {
        Token T2 = new Token(ONE, "T2", 5);
        _tokens.push(T2);
        Token T3 = new Token(ONE, "T3", 18);
        _tokens.push(T3);
    }

    function test_ctor() public {
        vm.expectRevert(abi.encodeWithSelector(INVALID_TOKEN, _tokens[0]));
        new Pool(_tokens, oracle, acma);
    }

    bytes4 INVALID_TOKEN = IPool.InvalidToken.selector;
    IERC20Metadata[] _tokens;
}

contract PoolCtor_InvalidOracle is TestBase {
    function test_ctor() public {
        vm.expectRevert(abi.encodeWithSelector(INVALID_ORACLE, address(0)));
        new Pool(tokens, _oracle, acma);
    }

    bytes4 INVALID_ORACLE = IPool.InvalidOracle.selector;
    IOracle _oracle = IOracle(address(0));
}
