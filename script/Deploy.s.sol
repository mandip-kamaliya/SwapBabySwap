// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Router} from "../src/UniswapV2Router.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract Deploy is Script {
    function run() external returns (address, address, address, address, address) {
        vm.startBroadcast();

        MockERC20 tokenA = new MockERC20("tokenA", "TKA");
        MockERC20 tokenB = new MockERC20("tokenB", "TKB");

        UniswapV2Factory factory = new UniswapV2Factory();
        UniswapV2Router router = new UniswapV2Router(address(factory), address(0));

        tokenA.mint(msg.sender, 1000 * 10 ** 18);
        tokenB.mint(msg.sender, 1000 * 10 ** 18);
        vm.stopBroadcast();

        return (address(tokenA), address(tokenB), address(factory), address(router), msg.sender);
    }
}
