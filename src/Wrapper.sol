// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import "./Gold.sol";

/// @title An ERC4626-compatible token fractional wrapper
/// @author Kibouweb3
contract Wrapper is IERC4626, ERC20 {
    error ZeroAddress();
    error TransferFailed();
    address public immutable asset;

    constructor(address gold_address) ERC20('Wrapped Gold', 'wGLD') {
        if (gold_address == address(0))
            revert ZeroAddress();

        asset = gold_address;
    }

    function totalAssets() external view returns (uint256 assets) {
        return Gold(asset).balanceOf(address(this));
    }

    function convertToAssets(uint256 shares) public pure returns (uint256 assets) {
        return shares;
    }

    function convertToShares(uint256 assets) public pure returns (uint256 shares) {
        return assets;
    }

    function maxDeposit(address receiver) external pure returns (uint256 maxAssets) {
        return 2 ** 256 - 1;
    }

    function previewDeposit(uint256 assets) external view returns (uint256 shares) {
        return convertToShares(assets);
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        uint256 _shares = convertToShares(assets);
        _mint(receiver, _shares);
        emit Deposit(msg.sender, receiver, assets, _shares);
        
        bool succ = Gold(asset).transferFrom(msg.sender, address(this), assets);
        if (!succ)
            revert TransferFailed();

        return _shares;
    }

    function maxMint(address receiver) external pure returns (uint256 maxShares) {
        return 2 ** 256 - 1;
    }

    function previewMint(uint256 shares) external view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function mint(uint256 shares, address receiver) external returns (uint256 assets) {
        uint256 _assets = convertToAssets(shares);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, _assets, shares);
        
        bool succ = Gold(asset).transferFrom(msg.sender, address(this), _assets);
        if (!succ)
            revert TransferFailed();

        return _assets;
    }

    function maxWithdraw(address owner) external view returns (uint256 maxAssets) {
        return convertToAssets(balanceOf(owner));
    }

    function previewWithdraw(uint256 assets) external pure returns (uint256 shares) {
        return convertToShares(assets);
    }

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
        uint256 _shares = convertToShares(assets);
        _spendAllowance(owner, msg.sender, _shares);
        _burn(owner, _shares);
        emit Withdraw(msg.sender, receiver, owner, assets, _shares);
        
        bool succ = Gold(asset).transferFrom(address(this), receiver, assets);
        if (!succ)
            revert TransferFailed();

        return _shares;
    }

    function maxRedeem(address owner) external view returns (uint256 maxShares) {
        return balanceOf(owner);
    }

    function previewRedeem(uint256 shares) external pure returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        uint256 _assets = convertToAssets(shares);
        _spendAllowance(owner, msg.sender, shares);
        _burn(owner, assets);
        emit Withdraw(msg.sender, receiver, owner, _assets, shares);
        
        bool succ = Gold(asset).transferFrom(address(this), receiver, _assets);
        if (!succ)
            revert TransferFailed();

        return _assets;
    }
}