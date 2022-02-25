// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IContractInit {
    struct Contract {
        uint id;
        uint amount;
        bool isValid;
        address initiatingParty;
        address[] parties;
        string contractName;
        string document;
    }
}