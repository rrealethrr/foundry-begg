// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Begg} from "../src/Begg.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBegg is Script {

    HelperConfig helperConfig = new HelperConfig();
    address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

    function run() external returns (Begg) {
        vm.startBroadcast();
        Begg begg = new Begg(ethUsdPriceFeed);
        vm.stopBroadcast();
        return begg;
    }

}