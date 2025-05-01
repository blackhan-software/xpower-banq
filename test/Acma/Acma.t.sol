// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";

import {IAcma} from "../../source/interface/Acma.sol";
import {Acma} from "../../source/contract/Acma.sol";
import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    IAcma internal acma;

    function setUp() public {
        acma = new Acma(address(this));
    }

    bytes4 SELECTOR = bytes4("0x1");
    uint64 ROLE_ID = 2;
}

contract AcmaTest is BaseTest {
    function test_relate() public {
        acma.grantRole(acma.ACMA_RELATE_ROLE(), address(this), 0);
        acma.relate(address(this), SELECTOR, ROLE_ID);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), address(this));
    }
}

contract AcmaTest_Role is BaseTest {
    function test_relate() public view {
        uint64 role_id = acma.getTargetFunctionRole(
            address(acma),
            acma.relate.selector
        );
        assertEq(role_id, acma.ACMA_RELATE_ROLE());
    }
}

contract AcmaTest_Unauthorized is BaseTest {
    function test_relate() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessManaged.AccessManagedUnauthorized.selector,
                address(this)
            )
        );
        acma.relate(address(this), SELECTOR, ROLE_ID);
    }
}
