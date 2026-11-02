// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {FlightRegistry} from "../src/FlightRegistry.sol";

contract DeployFlightRegistry is Script {
    function run() external returns (FlightRegistry registry) {
        // Foundry loads .env automatically; the key is read here and never printed
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        console.log("Deployer address:", vm.addr(deployerKey));

        vm.startBroadcast(deployerKey);
        registry = new FlightRegistry();
        vm.stopBroadcast();

        console.log("FlightRegistry deployed at:", address(registry));
    }
}
