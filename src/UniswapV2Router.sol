// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//Interfaces
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external returns (address);
}

interface IUniswapV2Pair {
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function mint(address to) external returns (uint256);
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

    //add Liquidity
    function _calculateLiquidity(address tokenA, address tokenB, uint256 amountAdesired, uint256 amountBdesired)
        private
        returns (uint256 amountA, uint256 amountB)
    {
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            return (amountAdesired, amountBdesired);
        } else {
            (amountA, amountB) = (amountAdesired, amountBdesired);
        }
    }

    function _addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB)
        private
        returns (uint256 liquidity)
    {
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (pair == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);

        liquidity = IUniswapV2Pair(pair).mint(msg.sender);
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amountAdesired, uint256 amountBdesired)
        external
        returns (uint256 liquidity)
    {
        (uint256 amountA, uint256 amountB) = _calculateLiquidity(tokenA, tokenB, amountAdesired, amountBdesired);
        liquidity = _addLiquidity(tokenA, tokenB, amountA, amountB);
    }
}
