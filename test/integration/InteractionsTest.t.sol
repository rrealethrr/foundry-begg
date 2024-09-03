// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Begg} from "../../src/Begg.sol";
import {DeployBegg} from "../../script/DeployBegg.s.sol";
import {FundBegg, WithdrawBegg} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Begg begg;
    
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployBegg deploy = new DeployBegg();
        begg = deploy.run();
        vm.deal(USER, STARTING_BALANCE);    
    }

    function testUserCanFundInteractions() public {
        FundBegg fundBegg = new FundBegg();
        fundBegg.fundBegg(address(begg));

        WithdrawBegg withdrawBegg = new WithdrawBegg();
        withdrawBegg.withdrawBegg(address(begg));

        assert(address(begg).balance == 0);
    }
}
