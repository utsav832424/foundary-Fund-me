// 1.Deploy mocks when we are on a local anvil chain
// 2.Keep track of contract address across different chains

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {console} from "forge-std/Test.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks
    // Otherwise grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getorCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sepoliaConfig;
    }

    function getorCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Deploy the mocks
        // Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            console.log(activeNetworkConfig.priceFeed);
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(
            address(mockV3Aggregator)
        );
        return anvilConfig;
    }
}
