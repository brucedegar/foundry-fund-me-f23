// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFunMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe(); // FundFunMe@0x2a9e8fa175F45b235efDdD97d2727741EF4Eee63
        fundMe = deploy.run(); /// 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFunMe fundFunMe = new FundFunMe();
        console.log(address(fundMe));

        fundFunMe.fundFunMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFunMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
