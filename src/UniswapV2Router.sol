// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//Interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract UniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _Weth) {
        factory = _factory;
        WETH = _Weth;
    }
}
