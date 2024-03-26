// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDepoyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDepoyed)).Fundme{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDepoyed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDepoyed);
    }
}

contract WihdrawFundMe is Script {
    function wihdrawFundMe(address mostRecentlyDepoyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDepoyed)).Withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDepoyed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        wihdrawFundMe(mostRecentlyDepoyed);
    }
}
