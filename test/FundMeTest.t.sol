//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //4 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        //1 us -> fundMeTest -> FundMe
        //2 us == msg.sender
        //3 fundMeTest == address(this) == fundMe.i_owner()
        // FundMe fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testOwnerIsMsgSender() public {
        /*  console.log("FundMe Owner: ");
        console.log(fundMe.i_owner());
        console.log("\nmsg.sender: ");
        console.log(msg.sender); */
        // assertEq(fundMe.i_owner(), msg.sender);
        // ? Why address(this) instead of msg.sender ?
        // ? Look comments in the setUp function
        assertEq(fundMe.getOwner(), msg.sender);
    }

    //? What can we do to work with addresses outside our system?
    //1 1. Unit
    //1     - Testing a specific part of our code
    //2 2. Integration
    //2     - Testing how our code works with other parts of our code
    //3 3. Forked
    //3     - Testing our code on a simulated real environment
    //4 4. Staging
    //4     - Testing our code in a real environment that is not prod
    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //1 hey, the next line, shoud rever!
        //2 assert(This tx fails/reverts
        fundMe.fund(); //3 send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //1 The next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // 1. Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // 3. Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        // 1. Arrange
        //1 uint160 needed to generate addresses from numbers
        //1 https://stackoverflow.com/questions/43318077/solidity-type-address-not-convertible-to-type-uint256
        uint160 numberOfFunders = 7;
        //2 sometimes address(0) reverts in tests, so better start from address(1)
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //1 vm.prank new address
            //2 vm.deal new address
            //3 hoax -> prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
            //4 fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // 3. Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
}

//3 Modular deployments
//5 Modular testing
