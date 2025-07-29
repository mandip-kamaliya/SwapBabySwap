// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract SimpleTest is Test {
    function test_simple_assertion() public {
        assertTrue(true, "This simple test should pass.");
    }
}
