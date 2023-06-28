//SPDX-License-Identifier: MIT
// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
//3 Sepolia ETH/USD
//4 Mainnet ETH/USD

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/Test.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //1 If we are on a local anvil, we deploy mocks
    //2 Otherwise, grab the existing address from the live netword

    struct NetworkConfig {
        address priceFeed; //? ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        // console.log(block.chainid);
        // console.log(address(0));
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
        // console.log(activeNetworkConfig.priceFeed);
    }

    function getMainnetEthConfig() public returns (NetworkConfig memory) {
        activeNetworkConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return activeNetworkConfig;
    }

    function getSepoliaEthConfig() public returns (NetworkConfig memory) {
        //1 price feed address
        //3 vrf address
        //5 gas price
        activeNetworkConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return activeNetworkConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // 1. Deploy the mocks
        // 2. Return the mock address
        //5 address(0) -> the first address/default value
        //5 Check to see if we already set an active network config -> SINGLETON
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        activeNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return activeNetworkConfig;
    }
}
