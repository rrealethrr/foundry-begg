// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Begg} from "../../src/Begg.sol";
import {DeployBegg} from "../../script/DeployBegg.s.sol";

contract BeggTest is Test {
    Begg begg;
    
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //begg = new Begg(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployBegg deployBegg = new DeployBegg();
        begg = deployBegg.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollarIsFive() public view {
        assertEq(begg.MINIMUM_USD(), 5*10**18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(begg.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = begg.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        begg.fund();
    }

    modifier funded() {
        vm.prank(USER);
        begg.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = begg.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = begg.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        begg.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = begg.getOwner().balance;
        uint256 startingBeggBalance = address(begg).balance;

        vm.prank(begg.getOwner());
        begg.withdraw();

        uint256 endingOwnerBalance = begg.getOwner().balance;
        uint256 endingBeggBalance = address(begg).balance;
        assertEq(endingBeggBalance, 0);
        assertEq(startingBeggBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            begg.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = begg.getOwner().balance;
        uint256 startingBeggBalance = address(begg).balance;

        vm.startPrank(begg.getOwner());
        begg.withdraw();
        vm.stopPrank();

        assert(address(begg).balance == 0);
        assert(startingBeggBalance + startingOwnerBalance == begg.getOwner().balance); 
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            begg.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = begg.getOwner().balance;
        uint256 startingBeggBalance = address(begg).balance;

        vm.startPrank(begg.getOwner());
        begg.cheaperWithdraw();
        vm.stopPrank();

        assert(address(begg).balance == 0);
        assert(startingBeggBalance + startingOwnerBalance == begg.getOwner().balance); 
    }
}