//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // ? us -> fundMeTest -> FundMe
        // ! us == msg.sender
        // * fundMeTest == address(this) == fundMe.i_owner()
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        // assertEq(fundMe.i_owner(), msg.sender);
        // ? Why address(this) instead of msg.sender ?
        // ? Look comments in the setUp function
        assertEq(fundMe.i_owner(), msg.sender);
    }

    //? What can we do to work with addresses outside our system?
    //1 1. Unit
    //1     - Testing a specific part of our code
    //2 2. Integration
    //2     - Testing how our code works with other parts of our code
    //5 3. Forked
    //5     - Testing our code on a simulated real environment
    //7 4. Staging
    //7     - Testing our code in a real environment that is not prod
    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }
}

//3 Modular deployments
//4 Modular testing
