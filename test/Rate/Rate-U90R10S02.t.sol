// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {BorrowRate} from "../../source/library/Rate.sol";
import {SupplyRate} from "../../source/library/Rate.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {RateTest} from "./Rate.t.sol";

//
// BorrowRateTest: util=90%, rate=10%, spread=0%
//

contract BorrowRateTest is RateTest {
    constructor() RateTest(IRModel({util: 90e16, rate: 10e16, spread: 0e16})) {}
}

//
// SupplyRateTest: util=90%, rate=10%, spread=2%
//

contract SupplyRateTest is RateTest {
    constructor() RateTest(IRModel({util: 90e16, rate: 10e16, spread: 2e16})) {}
}

//
// BorrowRate: rate-of(utilization)
//

contract BorrowRateOf1 is BorrowRateTest {
    using BorrowRate for IRModel;

    // util=0% => rate=0%
    function test_u00P() public view {
        assertEq(irm.by(0 * PCT), 0 * PCT);
    }

    // util=45% => rate=5%
    function test_u45P() public view {
        assertEq(irm.by(45 * PCT), 5 * PCT);
    }

    // util=90% => rate=10%
    function test_u90P() public view {
        assertEq(irm.by(90 * PCT), 10 * PCT);
    }

    // util=95% => rate=55%
    function test_u95P() public view {
        assertEq(irm.by(95 * PCT), 55 * PCT);
    }

    // util=100% => rate=100%
    function test_uONE() public view {
        assertEq(irm.by(100 * PCT), 100 * PCT);
    }

    // util=200% => rate=200% (max!)
    function test_uTWO() public view {
        assertEq(irm.by(200 * PCT), 200 * PCT);
    }
}

contract BorrowRateOf1_Fuzz is BorrowRateTest {
    using BorrowRate for IRModel;

    // util=[0%, 90%) => rate=[0%, 10%)
    function test_lt_u90P(uint256 util) public view {
        util = bound(util, 0, 90 * PCT - 1);
        assertLt(irm.by(util), 10 * PCT);
    }

    // util=[90%, 100%] => rate=[10%, 100%]
    function test_ge_u90P(uint256 util) public view {
        util = bound(util, 90 * PCT, 100 * PCT);
        assertGe(irm.by(util), 1e1 * PCT);
        assertLe(irm.by(util), 1e2 * PCT);
    }
}

contract BorrowRateOf2 is BorrowRateTest {
    using BorrowRate for IRModel;

    // util=0% => rate=0%
    function test_y12M_u00P() public view {
        assertEq(irm.over(12 * MONTH, 0 * PCT), 0 * BPS);
    }

    // util=45% => rate=5%
    function test_y12M_u45P() public view {
        assertEq(irm.over(12 * MONTH, 45 * PCT), 5 * PCT);
    }

    // util=90% => rate=10%
    function test_y12M_u90P() public view {
        assertEq(irm.over(12 * MONTH, 90 * PCT), 10 * PCT);
    }

    // util=95% => rate=55%
    function test_y12M_u95P() public view {
        assertEq(irm.over(12 * MONTH, 95 * PCT), 55 * PCT);
    }

    // util=100% => rate=100%
    function test_y12M_uONE() public view {
        assertEq(irm.over(12 * MONTH, 100 * PCT), 100 * PCT);
    }

    // util=0% => rate=0%×(6/12)
    function test_y6M_u00P() public view {
        assertEq(irm.over(6 * MONTH, 0 * PCT), 0 * BPS);
    }

    // util=45% => rate=5%×(6/12)
    function test_y6M_u45P() public view {
        assertEq(irm.over(6 * MONTH, 45 * PCT), 250 * BPS);
    }

    // util=90% => rate=10%×(6/12)
    function test_y6M_u90P() public view {
        assertEq(irm.over(6 * MONTH, 90 * PCT), 500 * BPS);
    }

    // util=95% => rate=55%×(6/12)
    function test_y6M_u95P() public view {
        assertEq(irm.over(6 * MONTH, 95 * PCT), 2750 * BPS);
    }

    // util=100% => rate=100%×(6/12)
    function test_y6M_uONE() public view {
        assertEq(irm.over(6 * MONTH, 100 * PCT), 5000 * BPS);
    }
}

contract BorrowAccrue is BorrowRateTest {
    using BorrowRate for IRModel;

    // util=0% => rate=0%
    function test_aE18_y12M_u00P() public view {
        assertEq(irm.accrue(1e18, 12 * MONTH, 0 * PCT), 1_000000_000000_000000);
    }

    // util=45% => rate=5%
    function test_aE18_y12M_u45P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 45 * PCT),
            1_051271_096376_024039
        );
    }

    // util=90% => rate=10%
    function test_aE18_y12M_u90P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 90 * PCT),
            1_105170_918075_647624
        );
    }

    // util=95% => rate=55%
    function test_aE18_y12M_u95P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 95 * PCT),
            1_733253_017867_395235
        );
    }

    // util=100% => rate=100%
    function test_aE18_y12M_uONE() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 100 * PCT),
            2_718281_828459_045234
        );
    }

    // util=0% => rate=0%×(6/12)
    function test_aE18_y6M_u00P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 0 * PCT), 1_000000_000000_000000);
    }

    // util=45% => rate=5%×(6/12)
    function test_aE18_y6M_u45P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 45 * PCT), 1_025315_120524_428840);
    }

    // util=90% => rate=10%×(6/12)
    function test_aE18_y6M_u90P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 90 * PCT), 1_051271_096376_024039);
    }

    // util=95% => rate=55%×(6/12)
    function test_aE18_y6M_u95P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 95 * PCT), 1_316530_674867_621622);
    }

    // util=100% => rate=100%×(6/12)
    function test_aE18_y6M_uONE() public view {
        assertEq(
            irm.accrue(1e18, 6 * MONTH, 100 * PCT),
            1_648721_270700_128145
        );
    }
}

//
// SupplyRate: rate-of(utilization) * [100% - spread]
//

contract SupplyRateOf1 is SupplyRateTest {
    using SupplyRate for IRModel;

    // util=0% => rate=0%
    function test_u00P() public view {
        assertEq(irm.by(0 * PCT), 0 * PCT);
    }
}

contract SupplyRateOf2 is SupplyRateTest {
    using SupplyRate for IRModel;

    // util=0% => rate=0%
    function test_y12M_u00P() public view {
        assertEq(irm.over(12 * MONTH, 0 * PCT), 0);
    }

    // util=100% => rate=98%
    function test_y12_uONE() public view {
        assertEq(irm.over(12 * MONTH, 100 * PCT), 98 * PCT);
    }
}

contract SupplyAccrue is SupplyRateTest {
    using SupplyRate for IRModel;

    // util=0% => rate=0%
    function test_aE18_y12M_u00P() public view {
        assertEq(irm.accrue(1e18, 12 * MONTH, 0 * PCT), 1_000000_000000_000000);
    }

    // util=100% => rate~98%
    function test_aE18_y12M_uONE() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 100 * PCT),
            2_664456_241929_417136
        );
    }
}
