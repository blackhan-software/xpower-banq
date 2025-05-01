// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IBorrowPosition} from "../../source/interface/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {BaseTest} from "./Base.t.sol";

contract BorrowTest_Meta is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {
        bAPOW_XPOW = new BorrowPosition(this, APOW, XPOW, IR_MODEL, acma);
        bAPOW_AVAX = new BorrowPosition(this, APOW, AVAX, IR_MODEL, acma);
        bXPOW_APOW = new BorrowPosition(this, XPOW, APOW, IR_MODEL, acma);
        bAVAX_APOW = new BorrowPosition(this, AVAX, APOW, IR_MODEL, acma);
    }

    function test_borrow_name() public view {
        assertEq(borrow.name(), "ABCToken Borrow");
    }

    function test_borrow_name_apow_xpow() public view {
        assertEq(bAPOW_XPOW.name(), "APower APOW Borrow");
    }

    function test_borrow_name_apow_avax() public view {
        assertEq(bAPOW_AVAX.name(), "APower APOW Borrow");
    }

    function test_borrow_name_xpow_apow() public view {
        assertEq(bXPOW_APOW.name(), "XPower XPOW Borrow");
    }

    function test_borrow_name_avax_apow() public view {
        assertEq(bAVAX_APOW.name(), "Wrapped AVAX Borrow");
    }

    function test_borrow_symbol_full() public view {
        assertEq(borrow.symbol(), "bABC:XYZ");
    }

    function test_borrow_symbol_apow_xpow() public view {
        assertEq(bAPOW_XPOW.symbol(), "bAPOW");
    }

    function test_borrow_symbol_apow_avax() public view {
        assertEq(bAPOW_AVAX.symbol(), "bAPOW:AVAX");
    }

    function test_borrow_symbol_xpow_apow() public view {
        assertEq(bXPOW_APOW.symbol(), "bXPOW");
    }

    function test_borrow_symbol_avax_apow() public view {
        assertEq(bAVAX_APOW.symbol(), "bAVAX:APOW");
    }

    APOWToken internal immutable APOW = new APOWToken(ONE);
    IBorrowPosition internal immutable bAPOW_XPOW;
    XPOWToken internal immutable XPOW = new XPOWToken(ONE);
    IBorrowPosition internal immutable bXPOW_APOW;
    AVAXToken internal immutable AVAX = new AVAXToken(ONE);
    IBorrowPosition internal immutable bAVAX_APOW;
    IBorrowPosition internal immutable bAPOW_AVAX;
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
