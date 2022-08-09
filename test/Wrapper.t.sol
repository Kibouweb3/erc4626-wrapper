// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Gold.sol";
import "../src/Wrapper.sol";

contract WrapperTest is Test {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    Gold private gold;
    Wrapper private wrapper;

    function setUp() public {
        gold = new Gold();
        wrapper = new Wrapper(address(gold));
    }

    function testDeposit() public {
        gold.mint(address(this), 50 ether);
        gold.approve(address(wrapper), 50 ether);

        vm.expectEmit(true, true, false, true, address(wrapper));
        emit Transfer(address(0), address(1), 50 ether);

        vm.expectEmit(true, true, false, true, address(wrapper));
        emit Deposit(address(this), address(1), 50 ether, 50 ether);

        vm.expectEmit(true, true, false, true, address(gold));
        emit Transfer(address(this), address(wrapper), 50 ether);

        wrapper.deposit(50 ether, address(1));

        assertEq(wrapper.totalAssets(), 50 ether);
        assertEq(wrapper.balanceOf(address(1)), 50 ether);
    }

    function testCannotDepositWoApproval() public {
        gold.mint(address(this), 50 ether);
        vm.expectRevert(bytes("ERC20: insufficient allowance"));
        wrapper.deposit(50 ether, address(1));
    }

    function testCannotDepositExceedsBalance() public {
        gold.approve(address(wrapper), 50 ether);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        wrapper.deposit(50 ether, address(1));
    }

    function testMint() public {
        gold.mint(address(this), 60 ether);
        gold.approve(address(wrapper), 60 ether);

        vm.expectEmit(true, true, false, true, address(wrapper));
        emit Transfer(address(0), address(1), 60 ether);

        vm.expectEmit(true, true, false, true, address(wrapper));
        emit Deposit(address(this), address(1), 60 ether, 60 ether);

        vm.expectEmit(true, true, false, true, address(gold));
        emit Transfer(address(this), address(wrapper), 60 ether);

        wrapper.mint(60 ether, address(1));

        assertEq(wrapper.totalAssets(), 60 ether);
        assertEq(wrapper.balanceOf(address(1)), 60 ether);
    }
}
