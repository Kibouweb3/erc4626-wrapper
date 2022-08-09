// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Gold.sol";

contract GoldTest is Test {
    Gold private gold;

    function setUp() public {
        gold = new Gold();
    }

    function testMint() public {
        gold.mint(address(1), 100 ether);
    }
}
