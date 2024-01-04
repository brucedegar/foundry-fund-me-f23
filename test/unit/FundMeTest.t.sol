// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);

        //uint256 gasStart = gasleft(); // 9223372036854654992 -> 9.223372036854654992 Ether
        //console.log(gasStart);
    }

    function testMinimumDollarIs5() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsCorrect() public {
        uint256 version = fundMe.getVersion();
        //console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); ///  the next line should revert
        // assert this tx fails/ revert
        fundMe.fund();
        //uint256 cat = 1;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithraw() public funded {
        vm.expectRevert();
        //vm.prank(USER);
        fundMe.withdraw();
    }

    // GAS before optize - FundMeTest:testWithdrawWithASingleFunder() (gas: 84842)
    function testWithdrawWithASingleFunder() public funded {
        // arrage
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // act

        vm.txGasPrice(GAS_PRICE);

        //uint256 gasStart = gasleft(); // 9223372036854654992 -> 9.223372036854654992 Ether
        //console.log(gasStart);

        vm.prank(fundMe.getOwner()); // Actuak gas 1181

        fundMe.withdraw(); // spend gas? // actual gas is - 4029

        // assert
        //uint256 gasStart = gasleft();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalace = address(fundMe).balance;

        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        assertEq(endingFundMeBalace, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // prank new address
            // deal new address <- add value to balance
            hoax(address(i), SEND_VALUE);

            // fund the contract
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        console.log(startingOwnerBalance);
        console.log(startingFundMeBalance);

        vm.prank(fundMe.getOwner()); // Set the current user is the contract owner
        fundMe.withdraw();
        vm.stopPrank(); //  the code btw prank and stopPrank only applicable for that address only

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalace = address(fundMe).balance;

        // assert
        assertEq(endingFundMeBalace, 0);
        assertEq(
            endingOwnerBalance,
            startingFundMeBalance + startingOwnerBalance
        );
    }

    function testImprovedWithrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // prank new address
            // deal new address <- add value to balance
            hoax(address(i), SEND_VALUE);

            // fund the contract
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        console.log(startingOwnerBalance);
        console.log(startingFundMeBalance);

        vm.prank(fundMe.getOwner()); // Set the current user is the contract owner
        fundMe.cheaperWithdraw();
        vm.stopPrank(); //  the code btw prank and stopPrank only applicable for that address only

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalace = address(fundMe).balance;

        // assert
        assertEq(endingFundMeBalace, 0);
        assertEq(
            endingOwnerBalance,
            startingFundMeBalance + startingOwnerBalance
        );
    }
}
