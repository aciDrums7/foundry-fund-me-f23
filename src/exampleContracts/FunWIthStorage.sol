// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FunWithStorage {
    uint256 favoriteNumber; //1 Stored at slot 0
    bool someBool; //2 Stored at slot 1
    uint256[] myArray; /* Array Length Stored at slot 2,
        but the objects will be the keccak256(2), since 2 is the storage slot of the array */
    mapping(uint256 => bool) myMap; /* An empty slot is held at slot 3
        and the elements will be stored at keccak256(h(k) . p)
        p: The storage slot (aka, 3)
        k: The key in hex
        h: Some function based on the type. For uint256, it just pads the hex
        */
    uint256 constant NOT_IN_STORAGE = 123;
    uint256 immutable i_not_in_storage;

    constructor() {
        favoriteNumber = 25; //1 See stored spot above // SSTORE
        someBool = true; //2 See stored spot above // SSTORE
        myArray.push(222); //3 SSTORE
        myMap[0] = true; //4 SSTORE
        i_not_in_storage = 123;
    }

    function doStuff() public {
        uint256 newVar = favoriteNumber + 1; //4 SLOAD
        bool otherVar = someBool; //5 SLOAD
            //6 ^^ memory variables
    }
}
