// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";
import "lib/solmate/src/utils/FixedPointMathLib.sol";
//Interface

interface IERC20 {
    function Transfer(address _to, uint256 _amount) external returns (bool);
    function TransferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _account) external returns (uint256);
}

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

    //mint function(for giving SBS-LP tokens to our liquidity provider)
    function mint(address to) external returns (uint256 Liquidity) {
        uint256 Balance0 = IERC20(token0).balanceOf(address(this));
        uint256 Balance1 = IERC20(token1).balanceOf(address(this));
        (uint112 _reserve0, uint112 _reserve1) = getReserve();

        uint256 amount0 = (Balance0 - _reserve0);
        uint256 amount1 = (Balance1 - _reserve1);
        uint256 _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            Liquidity = FixedPointMathLib.sqrt(amount0 * amount1) - MIN_LIQUIDITY;
            _mint(address(0), MIN_LIQUIDITY);
        } else {
            Liquidity = min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }
        require(Liquidity > 0, "No Liquidity token minted");

        _mint(to, Liquidity);
        _update(Balance0, Balance1);
    }

    function min(uint256 x, uint256 y) private pure returns (uint256) {
        return x < y ? x : y;
    }

    function getReserve() public view returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = uint112(reserve0);
        _reserve1 = uint112(reserve1);
    }

    function _update(uint256 _Balance0, uint256 _Balance1) private {
        reserve0 = _Balance0;
        reserve1 = _Balance1;
    }
}
