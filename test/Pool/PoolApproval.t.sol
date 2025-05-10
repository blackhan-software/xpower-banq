// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {IPoolApproval, IFlash} from "../../source/interface/Pool.sol";
import {PoolTest} from "./Pool.t.sol";

contract TestBase is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_NIL, IR_MODEL, DELPHI) {}

    bytes4 immutable UNAUTHORIZED =
        IAccessManaged.AccessManagedUnauthorized.selector;
}

contract PoolSupply_Approve is TestBase {
    function setUp() public {
        AVAX.transfer(papa, ONE);
        vm.prank(papa);
        AVAX.approve(address(pool), ONE);
    }

    function test_supply_approved() public {
        vm.prank(papa);
        vm.expectEmit();
        emit IPoolApproval.ApproveSupply(papa, self, AVAX, true);
        pool.approveSupply(self, AVAX, true);
        assertEq(pool.approvedSupply(papa, self, AVAX), true);
        vm.prank(self); // just explicit
        pool.supply(papa, AVAX, ONE, false);
    }

    function test_supply_revoked() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveSupply(papa, self, AVAX, false);
        pool.approveSupply(self, AVAX, false);
        assertEq(pool.approvedSupply(papa, self, AVAX), false);
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED, self));
        vm.prank(self); // just explicit
        pool.supply(papa, AVAX, ONE, false);
    }
}

contract PoolRedeem_Approve is TestBase {
    function setUp() public {
        AVAX.transfer(papa, ONE);
        vm.prank(papa);
        AVAX.approve(address(pool), ONE);
        vm.prank(papa);
        pool.supply(papa, AVAX, ONE, false);
    }

    function test_redeem_approved() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveRedeem(papa, self, AVAX, true);
        pool.approveRedeem(self, AVAX, true);
        assertEq(pool.approvedRedeem(papa, self, AVAX), true);
        vm.prank(self); // just explicit
        pool.redeem(papa, AVAX, ONE);
    }

    function test_redeem_revoked() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveRedeem(papa, self, AVAX, false);
        pool.approveRedeem(self, AVAX, false);
        assertEq(pool.approvedRedeem(papa, self, AVAX), false);
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED, self));
        vm.prank(self); // just explicit
        pool.redeem(papa, AVAX, ONE);
    }
}

contract PoolBorrow_Approve is TestBase {
    function setUp() public {
        AVAX.transfer(papa, 6 * ONE);
        vm.prank(papa);
        AVAX.approve(address(pool), 6 * ONE);
        vm.prank(papa);
        pool.supply(papa, AVAX, 6 * ONE, false);
    }

    function test_borrow_approved() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveBorrow(papa, self, AVAX, true);
        pool.approveBorrow(self, AVAX, true);
        assertEq(pool.approvedBorrow(papa, self, AVAX), true);
        vm.prank(self); // just explicit
        pool.borrow(papa, AVAX, 4 * ONE, false, IFlash(address(0)), "");
    }

    function test_borrow_revoked() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveBorrow(papa, self, AVAX, false);
        pool.approveBorrow(self, AVAX, false);
        assertEq(pool.approvedBorrow(papa, self, AVAX), false);
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED, self));
        vm.prank(self); // just explicit
        pool.borrow(papa, AVAX, 4 * ONE, false, IFlash(address(0)), "");
    }
}

contract PoolSettle_Approve is TestBase {
    function setUp() public {
        AVAX.transfer(papa, 6 * ONE);
        vm.prank(papa);
        AVAX.approve(address(pool), 10 * ONE);
        vm.prank(papa);
        pool.supply(papa, AVAX, 6 * ONE, false);
        vm.prank(papa);
        pool.borrow(papa, AVAX, 4 * ONE, false, IFlash(address(0)), "");
    }

    function test_settle_approved() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveSettle(papa, self, AVAX, true);
        pool.approveSettle(self, AVAX, true);
        assertEq(pool.approvedSettle(papa, self, AVAX), true);
        vm.prank(self); // just explicit
        pool.settle(papa, AVAX, 4 * ONE);
    }

    function test_settle_revoked() public {
        vm.prank(papa);
        emit IPoolApproval.ApproveSettle(papa, self, AVAX, false);
        pool.approveSettle(self, AVAX, false);
        assertEq(pool.approvedSettle(papa, self, AVAX), false);
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED, self));
        vm.prank(self); // just explicit
        pool.settle(papa, AVAX, 4 * ONE);
    }
}
