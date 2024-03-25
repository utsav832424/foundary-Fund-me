// q
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("Anmol");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdisTwo() public view {
        assertEq(fundMe.minimumUSD(), 2e18);
    }

    function testOwnerisMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundsFailsWithoutEnoughtEth() public {
        vm.expectRevert(); //the next line should be reverted
        fundMe.Fundme();
    }

    function testFundUpdatesDataStructure() public {
        vm.prank(USER); //the next tx will sent by USER
        fundMe.Fundme{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFund(USER);
        console.log(amountFunded);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToFunderArray() public {
        vm.prank(USER);
        fundMe.Fundme{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.Fundme{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnercanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.Withdraw();
    }

    function testWihdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = address(fundMe).balance;

        // Act
        // vm.txGasPrice(1);
        // uint256 gasStart = gasleft();

        vm.prank(fundMe.getOwner());
        fundMe.Withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundeMeBalance,
            endingOwnerBalance
        );
    }

    function testWihdrawWithMultipleFunder() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank
            // vm.deal
            hoax(address(i), SEND_VALUE);
            fundMe.Fundme{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.Withdraw();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testCheaperWihdrawWithMultipleFunder() public {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank
            // vm.deal
            hoax(address(i), SEND_VALUE);
            fundMe.Fundme{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
