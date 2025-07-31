// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
