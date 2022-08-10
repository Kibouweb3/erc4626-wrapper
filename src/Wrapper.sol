// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import "./Gold.sol";

/// @title An ERC4626-compatible token fractional wrapper
/// @author Kibouweb3
contract Wrapper is IERC4626, ERC20, Ownable {
    error ZeroAddress();
    error TransferFailed();
    error ExchangeRateOutOfBounds();

    event ExchangeRateChanged(uint256 exchange_rate);

    address public immutable asset;

    /// @notice Stores the exchange rate at which GLD will be exchanged for wGLD (wGLD = GLD * rate)
    /// @dev this is a ray (a number with 27 digits of precision)
    uint256 exchangeRate;

    constructor(address assetAddress, uint256 exchangeRate_) ERC20('Wrapped Gold', 'wGLD') {
        if (assetAddress == address(0))
            revert ZeroAddress();

        asset = assetAddress;
        exchangeRate = exchangeRate_;
    }

    /// @notice Sets the rate at which GLD will be exchanged for wGLD (wGLD = GLD * rate)
    /// @param exchangeRate_ The exchange rate as a ray (a fixed point decimal number with 27 digits)
    function setExchangeRate(uint256 exchangeRate_) external onlyOwner {
        if (exchangeRate_ > 1e45) // max 1000000000000000000 in ray
            revert ExchangeRateOutOfBounds();
    
        exchangeRate = exchangeRate_;
        emit ExchangeRateChanged(exchangeRate_);
    }

    function totalAssets() external view returns (uint256 assets) {
        return Gold(asset).balanceOf(address(this));
    }

    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        return (shares * 1e27) / exchangeRate;
    }

    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        shares = assets * exchangeRate;
        unchecked { shares /= 1e27; }
    }

    function maxDeposit(address) external pure returns (uint256 maxAssets) {
        return 2 ** 256 - 1;
    }

    function previewDeposit(uint256 assets) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        shares = previewDeposit(assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        
        bool succ = Gold(asset).transferFrom(msg.sender, address(this), assets);
        if (!succ)
            revert TransferFailed();
    }

    function maxMint(address) external pure returns (uint256 maxShares) {
        return 2 ** 256 - 1;
    }

    function previewMint(uint256 shares) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function mint(uint256 shares, address receiver) external returns (uint256 assets) {
        assets = previewMint(shares);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        
        bool succ = Gold(asset).transferFrom(msg.sender, address(this), assets);
        if (!succ)
            revert TransferFailed();
    }

    function maxWithdraw(address owner) external view returns (uint256 maxAssets) {
        return convertToAssets(balanceOf(owner));
    }

    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
        shares = previewWithdraw(assets);
        _spendAllowance(owner, msg.sender, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        
        bool succ = Gold(asset).transferFrom(address(this), receiver, assets);
        if (!succ)
            revert TransferFailed();
    }

    function maxRedeem(address owner) external view returns (uint256 maxShares) {
        return balanceOf(owner);
    }

    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        assets = previewRedeem(shares);
        _spendAllowance(owner, msg.sender, shares);
        _burn(owner, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        
        bool succ = Gold(asset).transferFrom(address(this), receiver, assets);
        if (!succ)
            revert TransferFailed();
    }
}