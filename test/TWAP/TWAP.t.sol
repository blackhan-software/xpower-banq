// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {TWAP, TWAPLib} from "../../source/library/TWAP.sol";
import {Quote} from "../../source/library/TWAP.sol";
import {Test} from "forge-std/Test.sol";

contract TWAPTest is Test {
    using TWAPLib for TWAP;
    TWAP internal twap;

    function assertEq(Quote memory a, Quote memory b) internal pure {
        assertEq(a.bid, b.bid);
        assertEq(a.ask, b.ask);
        assertEq(a.time, b.time);
    }

    function twap_update(
        Quote memory q
    ) internal view virtual returns (TWAP memory) {
        return twap.update(q, 1e18);
    }
}

contract TWAPInit_d1E18 is TWAPTest {
    function setUp() public {
        twap = TWAPLib.init(Quote(0, 0, 0));
    }

    function testInit() public view {
        assertEq(twap.mean, Quote(0e18, 0e18, 0));
        assertEq(twap.last, Quote(0e18, 0e18, 0));
    }
}

contract TWAPUpdate_d1E18 is TWAPTest {
    using TWAPLib for TWAP;

    function setUp() public {
        twap = TWAPLib.init(Quote(0, 0, 0));
    }

    function testUpdate_q1E18_t0a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 1e9));
    }

    function testUpdate_q1E18_t0b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t0c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 3e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t1a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t1b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t1c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t2a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t2b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t2c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t3a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t3b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t3c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }
}

contract TWAPUpdate_d5E17 is TWAPTest {
    using TWAPLib for TWAP;

    function setUp() public {
        twap = TWAPLib.init(Quote(0, 0, 0));
    }

    function twap_update(
        Quote memory q
    ) internal view override returns (TWAP memory) {
        return twap.update(q, 0.5e18);
    }

    function testUpdate_q1E18_t0a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 1e9));
    }

    function testUpdate_q1E18_t0b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t0c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 3e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t1a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t1b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t1c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.500000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t1d() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        assertEq(twap.last, Quote(4e18, 4e18, 4e9));
        uint256 both = 2.250000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 4e9));
    }

    function testUpdate_q1E18_t1e() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        assertEq(twap.last, Quote(5e18, 5e18, 5e9));
        uint256 both = 3.125000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 5e9));
    }

    function testUpdate_q1E18_t1f() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        vm.warp(6e9);
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        assertEq(twap.last, Quote(6e18, 6e18, 6e9));
        uint256 both = 4.062500_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 6e9));
    }

    function testUpdate_q1E18_t2a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t2b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t2c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.500000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t2d() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        assertEq(twap.last, Quote(4e18, 4e18, 4e9));
        uint256 both = 2.250000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 4e9));
    }

    function testUpdate_q1E18_t2e() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        assertEq(twap.last, Quote(5e18, 5e18, 5e9));
        uint256 both = 3.125000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 5e9));
    }

    function testUpdate_q1E18_t2f() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        vm.warp(6e9);
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        assertEq(twap.last, Quote(6e18, 6e18, 6e9));
        uint256 both = 4.062500_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 6e9));
    }

    function testUpdate_q1E18_t3a() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        assertEq(twap.last, Quote(1e18, 1e18, 1e9));
        assertEq(twap.mean, Quote(1e18, 1e18, 1e9));
    }

    function testUpdate_q1E18_t3b() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        assertEq(twap.last, Quote(2e18, 2e18, 2e9));
        uint256 both = 1.000000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 2e9));
    }

    function testUpdate_q1E18_t3c() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        assertEq(twap.last, Quote(3e18, 3e18, 3e9));
        uint256 both = 1.500000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 3e9));
    }

    function testUpdate_q1E18_t3d() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        assertEq(twap.last, Quote(4e18, 4e18, 4e9));
        uint256 both = 2.250000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 4e9));
    }

    function testUpdate_q1E18_t3e() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        assertEq(twap.last, Quote(5e18, 5e18, 5e9));
        uint256 both = 3.125000_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 5e9));
    }

    function testUpdate_q1E18_t3f() public {
        vm.warp(1e9);
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        twap = twap_update(Quote(1e18, 1e18, block.timestamp));
        vm.warp(2e9);
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        twap = twap_update(Quote(2e18, 2e18, block.timestamp));
        vm.warp(3e9);
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        twap = twap_update(Quote(3e18, 3e18, block.timestamp));
        vm.warp(4e9);
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        twap = twap_update(Quote(4e18, 4e18, block.timestamp));
        vm.warp(5e9);
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        twap = twap_update(Quote(5e18, 5e18, block.timestamp));
        vm.warp(6e9);
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        twap = twap_update(Quote(6e18, 6e18, block.timestamp));
        assertEq(twap.last, Quote(6e18, 6e18, 6e9));
        uint256 both = 4.062500_000000_000000e18;
        assertEq(twap.mean, Quote(both, both, 6e9));
    }
}
