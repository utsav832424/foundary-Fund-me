// Get Funds From users
// Withdraw funds
// Set a Minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant minimumUSD = 2e18;

    // For keeping the trck of funder addrss ans therit ammount
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFund;
    AggregatorV3Interface private s_priceFeed;
    address private immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier owner() {
        require(msg.sender == i_owner, "You are not owner");
        _;
    }

    // users can send the fund in usd
    function Fundme() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUSD,
            "Didn't Send to Enough USD"
        );
        s_addressToAmountFund[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function cheaperWithdraw() public owner {
        uint256 funderLength = s_funders.length;
        for (uint256 i = 0; i < funderLength; i++) {
            address funderaddress = s_funders[i];
            s_addressToAmountFund[funderaddress] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function Withdraw() public owner {
        // Set the amount of funding of funder 0
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funderaddress = s_funders[i];
            s_addressToAmountFund[funderaddress] = 0;
        }
        //create a new array because user withdraw mmount
        s_funders = new address[](0);

        // Transfer the amount from contract to user
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        Fundme();
    }

    fallback() external payable {
        Fundme();
    }

    /*
    view.pure function Getters
    */

    function getAddressToAmountFund(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFund[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
