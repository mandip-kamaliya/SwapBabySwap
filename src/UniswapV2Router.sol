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
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function getReserve() external view returns (uint112 reserve0, uint112 reserve1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract UniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _Weth) {
        factory = _factory;
        WETH = _Weth;
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "Router: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Router: ZERO_ADDRESS");
    }

    function pairFor(address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        // This is a condensed version of the create2 address calculation
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            // This is the init code hash of the Pair contract.
                            // You would generate this from your specific Pair contract bytecode.
                            hex"e2635c78278505c2d38592679261352e03938029d20c35467d510ac767b2cb51"
                        )
                    )
                )
            )
        );
    }

    function getAmountOut(uint256 amountIn, uint112 reserve0, uint112 reserve1)
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "Router: INSUFFICIENT_INPUT_AMOUNT");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserve1;
        uint256 denominator = (reserve0 * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function _swap(address[] memory path, address _to) internal {
        (address input, address output) = (path[0], path[1]);
        (address token0,) = sortTokens(input, output);

        (uint112 reserve0, uint112 reserve1) = IUniswapV2Pair(pairFor(input, output)).getReserve();

        uint256 amountIn = IERC20(input).balanceOf(pairFor(input, output)) - reserve0;
        uint256 amountOut = getAmountOut(amountIn, reserve0, reserve1);

        (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));

        IUniswapV2Pair(pairFor(input, output)).swap(amount0Out, amount1Out, _to, new bytes(0));
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

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity)
        public
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = pairFor(tokenA, tokenB);

        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
        (amountA, amountB) = IUniswapV2Pair(pair).burn(msg.sender);
    }

    function swapExactTokensForTokens(uint256 amountIn, address[] calldata path, address to, uint256 deadline)
        external
    {
        require(block.timestamp <= deadline, "Router: EXPIRED");
        require(path.length == 2, "Router: INVALID_PATH");

        IERC20(path[0]).transferFrom(msg.sender, pairFor(path[0], path[1]), amountIn);

        _swap(path, to);
    }
}
