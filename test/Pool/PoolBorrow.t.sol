// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Test} from "forge-std/Test.sol";

import {IRateLimited} from "../../source/contract/modifier/RateLimited.sol";
import {PowLimitedLib} from "../../source/library/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";
import {IPosition} from "../../source/interface/Position.sol";
import {IPool, IFlash} from "../../source/interface/Pool.sol";
import {Health} from "../../source/struct/Health.sol";
import {Weight} from "../../source/struct/Weight.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}
}

contract PoolBorrow_Only is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 3 * ONE);
        pool.supply(AVAX, 3 * ONE);
    }

    function test_borrow_only() public {
        pool.borrow(AVAX, 2 * ONE - 1);
    }
}

contract PoolBorrow_PoW is TestBase {
    using PowLimitedLib for bytes32;

    function setUp() public {
        AVAX.approve(address(pool), 3 * ONE);
        pool.supply(AVAX, 3 * ONE);
    }

    function test_borrow_pass_lt_1(uint256 nonce) public {
        bytes memory args = msg_data(address(AVAX), ONE - 1, nonce);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        if (key.zeros() > 0) {
            (bool ok, bytes memory data) = address(pool).call(args);
            uint256 amount = abi.decode(data, (uint256));
            assertEq(amount, 0.999000_999000_998999e18);
            assertTrue(ok);
        }
    }

    function test_borrow_fail_lt_1() public {
        bytes memory args = msg_data(address(AVAX), ONE - 1);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        assertEq(args, MSG_DATA_9);
        assertEq(key.zeros(), 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPowLimited.PowLimited.selector, key, 1)
        );
        assertEq(pool.borrow(AVAX, ONE - 1), 0);
    }

    function test_borrow_fail_eq_0() public {
        bytes memory args = msg_data(address(AVAX), 0);
        bytes32 key = pool.blockHash().key(tx.origin, args);
        assertEq(args, MSG_DATA_0);
        assertEq(key.zeros(), 0);
        vm.expectRevert(
            abi.encodeWithSelector(IPowLimited.PowLimited.selector, key, 18)
        );
        assertEq(pool.borrow(AVAX, 0), 0);
    }

    function msg_data(
        address token,
        uint256 amount,
        uint256 nonce
    ) private pure returns (bytes memory data) {
        data = abi.encodeWithSelector(
            bytes4(keccak256("borrow(address,uint256)")),
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
            bytes4(keccak256("borrow(address,uint256)")),
            token,
            amount
        );
    }

    bytes MSG_DATA_9 =
        hex"4b8a35290000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0000000000000000000000000000000000000000000000000de0b6b3a763ffff";
    bytes MSG_DATA_0 =
        hex"4b8a35290000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0000000000000000000000000000000000000000000000000000000000000000";
}

contract PoolBorrow_Capped is TestBase {
    function assert_cap(IERC20 token, uint256 cap) internal view {
        (uint256 c, ) = pool.capBorrow(token);
        assertEq(c, cap);
    }

    function assert_cup(IERC20 token, uint256 cap, address user) internal view {
        (uint256 c, ) = pool.capBorrowOf(user, token);
        assertEq(c, cap);
    }

    function setUp() public {
        pool.capBorrow(AVAX, 100 * ONE, 0);
        AVAX.transfer(caca, 150 * ONE);
        AVAX.transfer(dada, 150 * ONE);
        vm.prank(caca);
        AVAX.approve(address(pool), type(uint256).max);
        vm.prank(dada);
        AVAX.approve(address(pool), type(uint256).max);
        vm.prank(caca);
        pool.supply(AVAX, 100 * ONE);
        vm.prank(dada);
        pool.supply(AVAX, 100 * ONE);
    }

    function test_borrow_capped_5025() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 50 * ONE);
        assert_cup(AVAX, 25 * ONE, caca);
        assert_cup(AVAX, 25 * ONE, dada);
        assert_cup(AVAX, 25 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 25 * ONE);
        assert_cup(AVAX, 11.111111_111111_111106e18, caca);
        assert_cup(AVAX, 22.222222_222222_222218e18, dada);
        assert_cup(AVAX, 8.333333_333333_333333e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 11.111111_111111_111106e18)
        );
        pool.borrow(AVAX, 12 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 22.222222_222222_222218e18)
        );
        pool.borrow(AVAX, 23 * ONE);
    }

    function test_borrow_capped_2525() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 25 * ONE);
        assert_cup(AVAX, 37.5e18, caca);
        assert_cup(AVAX, 37.5e18, dada);
        assert_cup(AVAX, 37.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 25 * ONE);
        assert_cup(AVAX, 37.500000_000000_000000e18, caca);
        assert_cup(AVAX, 37.500000_000000_000000e18, dada);
        assert_cup(AVAX, 16.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 37.5e18));
        pool.borrow(AVAX, 38 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 37.5e18));
        pool.borrow(AVAX, 38 * ONE);
    }

    function test_borrow_capped_3311() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 33 * ONE);
        assert_cup(AVAX, 33.5e18, caca);
        assert_cup(AVAX, 33.5e18, dada);
        assert_cup(AVAX, 33.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 11 * ONE);
        assert_cup(AVAX, 15.750000_000000_000000e18, caca);
        assert_cup(AVAX, 47.250000_000000_000000e18, dada);
        assert_cup(AVAX, 18.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 15.75e18));
        pool.borrow(AVAX, 16 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 47.25e18));
        pool.borrow(AVAX, 48 * ONE);
    }

    function test_borrow_capped_1133() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 11 * ONE);
        assert_cup(AVAX, 44.5e18, caca);
        assert_cup(AVAX, 44.5e18, dada);
        assert_cup(AVAX, 44.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 33 * ONE);
        assert_cup(AVAX, 47.250000_000000_000000e18, caca);
        assert_cup(AVAX, 15.750000_000000_000000e18, dada);
        assert_cup(AVAX, 18.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 47.25e18));
        pool.borrow(AVAX, 48 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 15.75e18));
        pool.borrow(AVAX, 16 * ONE);
    }

    function test_borrow_capped_0101() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 49.5e18, caca);
        assert_cup(AVAX, 49.5e18, dada);
        assert_cup(AVAX, 49.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 73.500000_000000_000000e18, caca);
        assert_cup(AVAX, 73.500000_000000_000000e18, dada);
        assert_cup(AVAX, 32.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 73.5e18));
        pool.borrow(AVAX, 74 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(abi.encodeWithSelector(REL_EXCEEDED, 73.5e18));
        pool.borrow(AVAX, 74 * ONE);
    }

    function test_borrow_capped_5001() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 50 * ONE);
        assert_cup(AVAX, 25 * ONE, caca);
        assert_cup(AVAX, 25 * ONE, dada);
        assert_cup(AVAX, 25 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 0.110817_106542_732426e18, caca);
        assert_cup(AVAX, 5.540855_327136_621660e18, dada);
        assert_cup(AVAX, 16.333333_333333_333333e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 0.110817_106542_732426e18)
        );
        pool.borrow(AVAX, 1 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 5.540855_327136_621660e18)
        );
        pool.borrow(AVAX, 6 * ONE);
    }

    function test_borrow_capped_0150() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 49.5e18, caca);
        assert_cup(AVAX, 49.5e18, dada);
        assert_cup(AVAX, 49.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 49.5e18);
        assert_cup(AVAX, 5.650575_899664_272862e18, caca);
        assert_cup(AVAX, 0.114153_048478_066110e18, dada);
        assert_cup(AVAX, 16.50000_000000_000000e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 5.650575_899664_272862e18)
        );
        pool.borrow(AVAX, 6 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 0.114153_048478_066110e18)
        );
        pool.borrow(AVAX, 1 * ONE);
    }

    function test_borrow_capped_2501() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 25 * ONE);
        assert_cup(AVAX, 37.5e18, caca);
        assert_cup(AVAX, 37.5e18, dada);
        assert_cup(AVAX, 37.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 0.631543_013199_817932e18, caca);
        assert_cup(AVAX, 15.788575_329995_448336e18, dada);
        assert_cup(AVAX, 24.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 0.631543_013199_817932e18)
        );
        pool.borrow(AVAX, 1 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 15.788575_329995_448336e18)
        );
        pool.borrow(AVAX, 16 * ONE);
    }

    function test_borrow_capped_0125() public {
        assert_cup(AVAX, 100 * ONE, caca);
        assert_cup(AVAX, 100 * ONE, dada);
        assert_cup(AVAX, 100 * ONE, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        pool.borrow(AVAX, 1 * ONE);
        assert_cup(AVAX, 49.5e18, caca);
        assert_cup(AVAX, 49.5e18, dada);
        assert_cup(AVAX, 49.5e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(dada);
        pool.borrow(AVAX, 25 * ONE);
        assert_cup(AVAX, 15.788575_329995_448336e18, caca);
        assert_cup(AVAX, 0.631543_013199_817932e18, dada);
        assert_cup(AVAX, 24.666666_666666_666666e18, papa);
        assert_cap(AVAX, 100 * ONE);
        //
        vm.prank(caca);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 15.788575_329995_448336e18)
        );
        pool.borrow(AVAX, 16 * ONE);
        //
        vm.prank(dada);
        vm.expectRevert(
            abi.encodeWithSelector(REL_EXCEEDED, 0.631543_013199_817932e18)
        );
        pool.borrow(AVAX, 1 * ONE);
    }

    bytes4 immutable ABS_EXCEEDED = IPosition.AbsExceeded.selector;
    bytes4 immutable REL_EXCEEDED = IPosition.RelExceeded.selector;
}

contract PoolBorrow_Limited is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 100 * ONE);
    }

    function test_borrow2_7x() public {
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
        pool.borrow(AVAX, ONE);
    }

    function test_borrow2_8x() public {
        pool.borrow(AVAX, ONE + 1);
        pool.borrow(AVAX, ONE + 2);
        pool.borrow(AVAX, ONE + 3);
        pool.borrow(AVAX, ONE + 4);
        pool.borrow(AVAX, ONE + 5);
        pool.borrow(AVAX, ONE + 6);
        pool.borrow(AVAX, ONE + 7);
        vm.expectPartialRevert(IRateLimited.RateLimited.selector);
        pool.borrow(AVAX, ONE + 8);
    }

    function test_borrow5_7x() public {
        pool.borrow(AVAX, ONE, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE, false, IFlash(address(0)), "");
    }

    function test_borrow5_8x() public {
        pool.borrow(AVAX, ONE + 1, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 2, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 3, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 4, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 5, false, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 6, true, IFlash(address(0)), "");
        pool.borrow(AVAX, ONE + 7, false, IFlash(address(0)), "");
        vm.expectPartialRevert(IRateLimited.RateLimited.selector);
        pool.borrow(AVAX, ONE + 8, true, IFlash(address(0)), "");
    }

    error Limited(bytes32 key, uint256 duration);
}

contract PoolBorrow_General is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
        ///
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        pool.borrow(AVAX, supply);
    }

    function test_balance_of_vault() public view {
        uint256 avax = 33.423504_169828_171001e18;
        assertEq(AVAX.balanceOf(address(vAVAX)), avax);
    }

    function test_balance_of_pool() public view {
        uint256 vavax = 33.304187_491658_362446_676545194e27;
        assertEq(vAVAX.balanceOf(address(pool)), vavax);
    }

    function test_balance_of_self() public view {
        uint256 avax = 966.576495_830171_828999e18;
        assertEq(AVAX.balanceOf(self), avax);
    }

    function test_supply_of_self() public view {
        uint256 supply = 99.964608_489003_001244e18;
        assertEq(sAVAX.balanceOf(self), supply);
    }

    function test_borrow_of_self() public view {
        uint256 borrow = 66.643072_326002_000829e18;
        assertEq(bAVAX.balanceOf(self), borrow);
    }

    function test_health_of_self() public view {
        uint256 supply = 8_496.991721_565255_105740e18;
        uint256 borrow = 8_496.991721_565255_105697e18;
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, supply);
        assertEq(health.wnav_borrow, borrow);
    }
}

contract PoolBorrow_Event is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 50 * ONE);
        pool.supply(AVAX, 25 * ONE);
        pool.supply(AVAX, 25 * ONE);
    }

    function test_borrow() public {
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        vm.expectEmit();
        emit Borrow(self, AVAX, supply, false, IFlash(address(0)), "");
        uint256 amount = pool.borrow(AVAX, supply);
        assertEq(amount, 66.576495_830171_828999e18);
    }

    event Borrow(address indexed, IERC20 indexed, uint256, bool, IFlash, bytes);
}

contract PoolBorrow_Flash is TestBase {
    function setUp() public {
        AVAX.transfer(papa, 100 * AVAX_ONE);
        ///
        vm.startPrank(papa);
        AVAX.approve(address(pool), 100 * AVAX_ONE);
        pool.supply(AVAX, 100 * AVAX_ONE);
        vm.stopPrank();
        ///
        Flash flash = new Flash(self, pool);
        AVAX.approve(address(pool), 99 * AVAX_ONE);
        pool.borrow(AVAX, 99 * AVAX_ONE, false, flash, "0x0");
    }

    function test_balance_of_pool() public view {
        uint256 avax = 100.098901_098901_098903e18;
        assertEq(AVAX.balanceOf(address(vAVAX)), avax);
    }

    function test_balance_of_self() public view {
        uint256 avax = 899.901098_901098_901097e18;
        assertEq(AVAX.balanceOf(self), avax);
    }

    function test_supply_of_self() public view {
        assertEq(sAVAX.balanceOf(self), 0);
    }

    function test_borrow_of_self() public view {
        assertEq(bAVAX.balanceOf(self), 0);
    }

    function test_health_of_self() public view {
        Health memory health = pool.healthOf(self);
        assertEq(health.wnav_supply, 0); // *zero* supply
        assertEq(health.wnav_borrow, 0); // *zero* borrow
    }
}

contract Flash is IFlash, Test {
    constructor(address user_, IPool pool_) {
        user = user_;
        pool = pool_;
    }

    function loan(
        IERC20 token,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external view override returns (bool) {
        assertEq(IERC20Metadata(address(token)).symbol(), "AVAX");
        assertEq(amount, 98.901098_901098_901097e18);
        assertEq(premium, 0.098901_098901_098903e18);
        assertEq(initiator, user);
        assertEq(params, "0x0");
        ///
        Health memory health = pool.healthOf(initiator);
        assertEq(health.wnav_supply, 0); // *zero* supply
        assertGt(health.wnav_borrow, 0); // *more* borrow
        return true;
    }

    address immutable user;
    IPool immutable pool;
}

contract PoolBorrow_InsufficientHealth is TestBase {
    function setUp() public {
        AVAX.approve(address(pool), 100 * ONE);
        pool.supply(AVAX, 100 * ONE);
    }

    function test_borrow() public {
        Weight memory weight = pool.weightOf(AVAX);
        uint256 supply = Math.mulDiv(
            sAVAX.balanceOf(self),
            weight.supply,
            weight.borrow
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                INSUFFICIENT_HEALTH,
                self,
                8499.999999_999999_999915e18,
                8500.000000_000000_000042e18
            )
        );
        pool.borrow(AVAX, supply + 1);
    }

    bytes4 INSUFFICIENT_HEALTH = IPool.InsufficientHealth.selector;
}

contract PoolBorrow_NotEnlisted is TestBase {
    function test_borrow() public {
        vm.expectRevert(
            abi.encodeWithSelector(IPool.NotEnlisted.selector, T18)
        );
        pool.borrow(T18, ONE);
    }
}
