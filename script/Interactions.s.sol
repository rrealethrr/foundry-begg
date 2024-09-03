// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Begg} from "../src/Begg.sol";

contract FundBegg is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundBegg(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Begg(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded Begg with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Begg", block.chainid);
        vm.startBroadcast();
        fundBegg(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawBegg is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawBegg(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Begg(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Begg", block.chainid);
        withdrawBegg(mostRecentlyDeployed);
    }
}
