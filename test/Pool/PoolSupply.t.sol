// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IRateLimited} from "../../source/contract/modifier/RateLimited.sol";
import {PowLimitedLib} from "../../source/library/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {SupplyPosition} from "../../source/contract/Position.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {Health} from "../../source/struct/Health.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolSupply_Only is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), ONE);
    }

    function test_supply_only() public {
        pool.supply(AVAX, ONE);
    }
}

contract PoolSupply_PoW is TestBase {
    using PowLimitedLib for bytes32;

    function setUp() public {
        AVAX.approve(address(pool), ONE);
    }

    function test_supply_pass_lt_1(uint256 nonce) public {
        bytes memory args = msg_data(address(AVAX), ONE - 1, nonce);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        if (key.zeros() > 0) {
            (bool ok, bytes memory data) = address(pool).call(args);
            uint256 assets = abi.decode(data, (uint256));
            assertEq(assets, 0.999999_999999_999998e18);
            assertTrue(ok);
        }
    }

    function test_supply_fail_lt_1() public {
        bytes memory args = msg_data(address(AVAX), ONE - 1);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        assertEq(args, MSG_DATA_9);
        assertEq(key.zeros(), 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPowLimited.PowLimited.selector, key, 1)
        );
        assertEq(pool.supply(AVAX, ONE - 1), 0);
    }

    function test_supply_fail_eq_0() public {
        bytes memory args = msg_data(address(AVAX), 0);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        assertEq(args, MSG_DATA_0);
        assertEq(key.zeros(), 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPowLimited.PowLimited.selector, key, 18)
        );
        assertEq(pool.supply(AVAX, 0), 0);
    }

    function msg_data(
        address token,
        uint256 amount,
        uint256 nonce
    ) private pure returns (bytes memory data) {
        data = abi.encodeWithSelector(
            bytes4(keccak256("supply(address,uint256)")),
            token,
            amount,
            nonce
        );
    }

    function msg_data(
        address token,
        uint256 amount
    ) private pure returns (bytes memory data) {
        data = abi.encodeWithSelector(
            bytes4(keccak256("supply(address,uint256)")),
            token,
            amount
        );
    }

    bytes MSG_DATA_9 =
        hex"f2b9fdb80000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0000000000000000000000000000000000000000000000000de0b6b3a763ffff";
    bytes MSG_DATA_0 =
        hex"f2b9fdb80000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0000000000000000000000000000000000000000000000000000000000000000";
}

contract PoolSupply_Capped is TestBase {
    function assert_cap(IERC20 token, uint256 cap) internal view {
        (uint256 c, ) = pool.capSupply(token);
        assertEq(c, cap);
    }

    function assert_cup(IERC20 token, uint256 cap, address user) internal view {
        (uint256 c, ) = pool.capSupplyOf(user, token);
        assertEq(c, cap);
    }

    function setUp() public {
        pool.capSupply(AVAX, 100 * ONE, 0);
        AVAX.transfer(caca, 100 * ONE);
        AVAX.transfer(dada, 100 * ONE);
        vm.prank(caca);
        AVAX.approve(address(pool), type(uint256).max);
        vm.prank(dada);
        AVAX.approve(address(pool), type(uint256).max);
    }

    function test_supply_capped_5025() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.supply(AVAX, 50 * ONE);
        assert_cup(AVAX, 25 * ONE, caca);
        assert_cup(AVAX, 25 * ONE, dada);
        assert_cup(AVAX, 25 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.supply(AVAX, 25 * ONE);
        assert_cup(AVAX, 11.111104_534546_161198e18, caca);
        assert_cup(AVAX, 22.237023_875138_383950e18, dada);
        assert_cup(AVAX, 8.338885_187652_675994e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 11.111104_534546_161198e18)
        );
        pool.supply(AVAX, 12 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 22.237023_875138_383950e18)
        );
        pool.supply(AVAX, 23 * ONE);
    }

    function test_supply_capped_3311() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.supply(AVAX, 33 * ONE);
        assert_cup(AVAX, 33.5e18, caca);
        assert_cup(AVAX, 33.5e18, dada);
        assert_cup(AVAX, 33.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.supply(AVAX, 11 * ONE);
        assert_cup(AVAX, 15.737560_737566_677164e18, caca);
        assert_cup(AVAX, 47.248091_724359_556534e18, dada);
        assert_cup(AVAX, 18.669414_605712_382380e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 15.737560_737566_677164e18)
        );
        pool.supply(AVAX, 16 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 47.248091_724359_556534e18)
        );
        pool.supply(AVAX, 48 * ONE);
    }

    function test_supply_capped_1133() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.supply(AVAX, 11 * ONE);
        assert_cup(AVAX, 44.5e18, caca);
        assert_cup(AVAX, 44.5e18, dada);
        assert_cup(AVAX, 44.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.supply(AVAX, 33 * ONE);
        assert_cup(AVAX, 47.259911_650226_954724e18, caca);
        assert_cup(AVAX, 15.757242_209379_837150e18, dada);
        assert_cup(AVAX, 18.669415_979338_498709e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 47.259911_650226_954724e18)
        );
        pool.supply(AVAX, 48 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 15.757242_209379_837150e18)
        );
        pool.supply(AVAX, 16 * ONE);
    }

    function test_supply_capped_2525() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.supply(AVAX, 25 * ONE);
        assert_cup(AVAX, 37.5e18, caca);
        assert_cup(AVAX, 37.5e18, dada);
        assert_cup(AVAX, 37.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.supply(AVAX, 25 * ONE);
        assert_cup(AVAX, 37.499992_973435_303610e18, caca);
        assert_cup(AVAX, 37.518742_969922_021262e18, dada);
        assert_cup(AVAX, 16.670831_251041_146094e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 37.499992_973435_303610e18)
        );
        pool.supply(AVAX, 38 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 37.518742_969922_021262e18)
        );
        pool.supply(AVAX, 38 * ONE);
    }

    function test_supply_capped_0101() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.supply(AVAX, 1 * ONE);
        assert_cup(AVAX, 49.5e18, caca);
        assert_cup(AVAX, 49.5e18, dada);
        assert_cup(AVAX, 49.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.supply(AVAX, 1 * ONE);
        assert_cup(AVAX, 73.481999_721186_006534e18, caca);
        assert_cup(AVAX, 73.518740_721046_599516e18, dada);
        assert_cup(AVAX, 32.666833_250041_645844e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 73.481999_721186_006534e18)
        );
        pool.supply(AVAX, 74 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 73.518740_721046_599516e18)
        );
        pool.supply(AVAX, 74 * ONE);
    }

    bytes4 immutable ABS_EXCEEDED = IPosition.AbsExceeded.selector;
    bytes4 immutable REL_EXCEEDED = IPosition.RelExceeded.selector;
}

contract PoolSupply_Limited is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
    }

    function test_supply2_7x() public {
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
        pool.supply(AVAX, ONE);
    }

    function test_supply2_8x() public {
        pool.supply(AVAX, ONE + 1);
        pool.supply(AVAX, ONE + 2);
        pool.supply(AVAX, ONE + 3);
        pool.supply(AVAX, ONE + 4);
        pool.supply(AVAX, ONE + 5);
        pool.supply(AVAX, ONE + 6);
        pool.supply(AVAX, ONE + 7);
        vm.expectPartialRevert(IRateLimited.RateLimited.selector);
        pool.supply(AVAX, ONE + 8);
    }

    function test_supply3_7x() public {
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
        pool.supply(AVAX, ONE, false);
    }

    function test_supply3_8x() public {
        pool.supply(AVAX, ONE + 1, false);
        pool.supply(AVAX, ONE + 2, false);
        pool.supply(AVAX, ONE + 3, false);
        pool.supply(AVAX, ONE + 4, false);
        pool.supply(AVAX, ONE + 5, false);
        pool.supply(AVAX, ONE + 6, false);
        pool.supply(AVAX, ONE + 7, false);
        vm.expectPartialRevert(IRateLimited.RateLimited.selector);
        pool.supply(AVAX, ONE + 8, false);
    }

    error Limited(bytes32 key, uint256 duration);
}

contract PoolSupply_General is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
    }

    function test_supply() public {
        AVAX.approve(address(pool), ONE);
        pool.supply(AVAX, ONE);
    }

    function test_balance_of_vault() public view {
        assertEq(AVAX.balanceOf(address(vAVAX)), 100 * ONE);
    }

    function test_balance_of_pool() public view {
        uint256 vavax = 99.841891_367049_525570_147444813e27;
        assertEq(vAVAX.balanceOf(address(pool)), vavax);
    }

    function test_balance_of_self() public view {
        assertEq(AVAX.balanceOf(self), 900 * ONE);
    }

    function test_vault_of_self() public view {
        assertEq(vAVAX.balanceOf(self), 0);
    }

    function test_supply_of_self() public view {
        uint256 savax = 99.964608_489003_001244e18;
        assertEq(sAVAX.balanceOf(self), savax);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
    }

    function test_health_of_self() public view {
        uint256 supply = 8_496.991721_565255_105740e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, 0);
    }
}

contract PoolSupply_Event is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
    }

    function test_supply() public {
        vm.expectEmit();
        emit Supply(self, AVAX, 100 * ONE, false);
        uint256 assets = pool.supply(AVAX, 100 * ONE);
        assertEq(assets, 99.999999_999999_999999e18);
    }

    event Supply(address indexed, IERC20 indexed, uint256, bool);
}

contract PoolSupply_NotEnlisted is TestBase {
    function test_supply() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.supply(T18, ONE);
    }
}
