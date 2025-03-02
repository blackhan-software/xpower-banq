// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {BorrowRate} from "../../source/library/Rate.sol";
import {SupplyRate} from "../../source/library/Rate.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {RateTest} from "./Rate.t.sol";

//
// BorrowRateTest: util=80%, rate=20%, spread=0%
//

contract BorrowRateTest is RateTest {
    constructor() RateTest(IRModel({util: 80e16, rate: 20e16, spread: 0e16})) {}
}

//
// SupplyRateTest: util=80%, rate=20%, spread=3%
//

contract SupplyRateTest is RateTest {
    constructor() RateTest(IRModel({util: 80e16, rate: 20e16, spread: 3e16})) {}
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

    // util=40% => rate=10%
    function test_u40P() public view {
        assertEq(irm.by(40 * PCT), 10 * PCT);
    }

    // util=80% => rate=20%
    function test_u80P() public view {
        assertEq(irm.by(80 * PCT), 20 * PCT);
    }

    // util=90% => rate=60%
    function test_u95P() public view {
        assertEq(irm.by(90 * PCT), 60 * PCT);
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

    // util=[0%, 80%) => rate=[0%, 20%)
    function test_lt_u80P(uint256 util) public view {
        util = bound(util, 0, 80 * PCT - 1);
        assertLt(irm.by(util), 20 * PCT);
    }

    // util=[80%, 100%] => rate=[20%, 100%]
    function test_ge_u80P(uint256 util) public view {
        util = bound(util, 80 * PCT, 100 * PCT);
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

    // util=40% => rate=10%
    function test_y12M_u40P() public view {
        assertEq(irm.over(12 * MONTH, 40 * PCT), 10 * PCT);
    }

    // util=80% => rate=20%
    function test_y12M_u80P() public view {
        assertEq(irm.over(12 * MONTH, 80 * PCT), 20 * PCT);
    }

    // util=90% => rate=60%
    function test_y12M_u90P() public view {
        assertEq(irm.over(12 * MONTH, 90 * PCT), 60 * PCT);
    }

    // util=100% => rate=100%
    function test_y12M_uONE() public view {
        assertEq(irm.over(12 * MONTH, 100 * PCT), 100 * PCT);
    }

    // util=0% => rate=0%×(6/12)
    function test_y6M_u00P() public view {
        assertEq(irm.over(6 * MONTH, 0 * PCT), 0 * BPS);
    }

    // util=40% => rate=10%×(6/12)
    function test_y6M_u40P() public view {
        assertEq(irm.over(6 * MONTH, 40 * PCT), 500 * BPS);
    }

    // util=80% => rate=20%×(6/12)
    function test_y6M_u80P() public view {
        assertEq(irm.over(6 * MONTH, 80 * PCT), 1000 * BPS);
    }

    // util=90% => rate=60%×(6/12)
    function test_y6M_u90P() public view {
        assertEq(irm.over(6 * MONTH, 90 * PCT), 3000 * BPS);
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

    // util=40% => rate=10%
    function test_aE18_y12M_u40P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 40 * PCT),
            1_105170_918075_647624
        );
    }

    // util=80% => rate=20%
    function test_aE18_y12M_u80P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 80 * PCT),
            1_221402_758160_169833
        );
    }

    // util=90% => rate=60%
    function test_aE18_y12M_u90P() public view {
        assertEq(
            irm.accrue(1e18, 12 * MONTH, 90 * PCT),
            1_822118_800390_508974
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

    // util=40% => rate=10%×(6/12)
    function test_aE18_y6M_u40P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 40 * PCT), 1_051271_096376_024039);
    }

    // util=80% => rate=20%×(6/12)
    function test_aE18_y6M_u80P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 80 * PCT), 1_105170_918075_647624);
    }

    // util=90% => rate=60%×(6/12)
    function test_aE18_y6M_u90P() public view {
        assertEq(irm.accrue(1e18, 6 * MONTH, 90 * PCT), 1_349858_807576_003103);
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
        assertEq(irm.over(12 * MONTH, 100 * PCT), 97 * PCT);
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
            2_637944_459354_152530
        );
    }
}
