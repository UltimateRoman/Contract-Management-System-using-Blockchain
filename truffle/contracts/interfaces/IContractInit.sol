// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IContractInit {
    struct BaseContractData {
        uint id;
        address contractAddress;
        address initiatingParty;
        address[] parties;
    }

    struct CompleteContractData {
        bool isPayable;
        uint expiryTime;
        uint[] fundDistribution;
        address initiatingParty;
        address[] parties;
        string contractName;
        string document;
    }
}