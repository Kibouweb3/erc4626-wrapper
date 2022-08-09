// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title A simple ERC-20 token
/// @author Kibouweb3
contract Gold is ERC20 {
    constructor() ERC20('Gold', 'GLD') {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}