// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";
import "lib/solmate/src/utils/FixedPointMathLib.sol";
//Interface

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
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

    modifier nonReentrant() {
        require(isLocked, "Pair: LOCKED");
        isLocked = false;
        _;
        isLocked = true;
    }

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

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "Pair: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1) = getReserve();
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "Pair: INSUFFICIENT_LIQUIDITY");

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "Pair: INSUFFICIENT_INPUT_AMOUNT");

        uint256 balance0Adjusted = balance0 * 1000 - (amount0In * 3);
        uint256 balance1Adjusted = balance1 * 1000 - (amount1In * 3);
        require(
            balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * uint256(_reserve1) * (1000 ** 2),
            "Pair: K_INVARIANT_FAILED"
        );

        _update(balance0, balance1);
    }

    function burn(address to) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1) = getReserve();
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings

        // Get the amount of LP tokens that have been sent to this contract
        uint256 _liquidity = balanceOf[address(this)];

        // Calculate how much of each token to return based on the user's share of the pool
        amount0 = (_liquidity * reserve0) / totalSupply;
        amount1 = (_liquidity * reserve1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "Pair: INSUFFICIENT_LIQUIDITY_BURNED");

        // Burn the user's LP tokens and send them their underlying tokens
        _burn(address(this), _liquidity);
        IERC20(_token0).transfer(to, amount0);
        IERC20(_token1).transfer(to, amount1);

        // Update the reserves
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        _update(balance0, balance1);
    }

    // 3. Get the new balances after the transfer
}
