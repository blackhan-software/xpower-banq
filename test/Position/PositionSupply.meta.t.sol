// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ISupplyPosition} from "../../source/interface/Position.sol";
import {SupplyPosition} from "../../source/contract/Position.sol";
import {BaseTest} from "./Base.t.sol";

contract SupplyTest_Meta is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {
        sAPOW_XPOW = new SupplyPosition(this, APOW, XPOW, IR_MODEL, acma);
        sAPOW_AVAX = new SupplyPosition(this, APOW, AVAX, IR_MODEL, acma);
        sXPOW_APOW = new SupplyPosition(this, XPOW, APOW, IR_MODEL, acma);
        sAVAX_APOW = new SupplyPosition(this, AVAX, APOW, IR_MODEL, acma);
    }

    function test_supply_name() public view {
        assertEq(supply.name(), "ABCToken Supply");
    }

    function test_supply_name_apow_xpow() public view {
        assertEq(sAPOW_XPOW.name(), "APower APOW Supply");
    }

    function test_supply_name_apow_avax() public view {
        assertEq(sAPOW_AVAX.name(), "APower APOW Supply");
    }

    function test_supply_name_xpow_apow() public view {
        assertEq(sXPOW_APOW.name(), "XPower XPOW Supply");
    }

    function test_supply_name_avax_apow() public view {
        assertEq(sAVAX_APOW.name(), "Wrapped AVAX Supply");
    }

    function test_supply_symbol_full() public view {
        assertEq(supply.symbol(), "sABC:XYZ");
    }

    function test_supply_symbol_apow_xpow() public view {
        assertEq(sAPOW_XPOW.symbol(), "sAPOW");
    }

    function test_supply_symbol_apow_avax() public view {
        assertEq(sAPOW_AVAX.symbol(), "sAPOW:AVAX");
    }

    function test_supply_symbol_xpow_apow() public view {
        assertEq(sXPOW_APOW.symbol(), "sXPOW");
    }

    function test_supply_symbol_avax_apow() public view {
        assertEq(sAVAX_APOW.symbol(), "sAVAX:APOW");
    }

    APOWToken internal immutable APOW = new APOWToken(ONE);
    ISupplyPosition internal immutable sAPOW_XPOW;
    XPOWToken internal immutable XPOW = new XPOWToken(ONE);
    ISupplyPosition internal immutable sXPOW_APOW;
    AVAXToken internal immutable AVAX = new AVAXToken(ONE);
    ISupplyPosition internal immutable sAVAX_APOW;
    ISupplyPosition internal immutable sAPOW_AVAX;
}

contract APOWToken is ERC20 {
    constructor(uint256 amount) ERC20("APower APOW", "APOW") {
        _mint(msg.sender, amount);
    }
}

contract XPOWToken is ERC20 {
    constructor(uint256 amount) ERC20("XPower XPOW", "XPOW") {
        _mint(msg.sender, amount);
    }
}

contract AVAXToken is ERC20 {
    constructor(uint256 amount) ERC20("Wrapped AVAX", "WAVAX") {
        _mint(msg.sender, amount);
    }
}
