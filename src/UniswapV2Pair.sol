// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";
import "lib/solmate/src/utils/FixedPointMathLib.sol";

contract UniswapV2Pair is ERC20 {
    //state variable
    address public token0;
    address public token1;

    uint256 private reserve0;
    uint256 private reserve1;
    address public factory;

    uint256 public constant MIN_LIQUIDITY = 10 ** 3;
    bool private isLocked = true;

    //constructor
    constructor() ERC20("SwapBabySwap-LP", "SBS-LP", 18) {
        factory = msg.sender;
    }

    //Initialize function
    function Initialized(address _token0, address _token1) external {
        require(token0 == address(0), "Tokens are already initialized");
        require(msg.sender == factory, "Pair: NOT_FACTORY");
        token0 = _token0;
        token1 = _token1;
    }
}
