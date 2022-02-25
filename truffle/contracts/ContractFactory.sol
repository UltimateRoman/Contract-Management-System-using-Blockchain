// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IContractInit.sol";

/**
 * @title Contract Factory
 * @dev Create & retrieve contracts
 */

contract ContractFactory is IContractInit {

    Contract[] draftContracts;
    mapping(uint => address) public initiatingParty;

    event createdContract(uint);

    //Modifier to check whether msg.sender is the initiating party of the contract
    modifier onlyInitiator(uint _contractId) {
        require(msg.sender == draftContracts[_contractId].initiatingParty, "Not the initiator");
        _;
    }

    //Modifier to check whether msg.sender is a party to the contract
    modifier onlyParty(uint _contractId) {
        bool isParty;

        if (initiatingParty[_contractId] == msg.sender) {
            isParty = true;
        }

        for (uint i = 0; i < draftContracts[_contractId].parties.length; ++i) {
            if (draftContracts[_contractId].parties[i] == msg.sender) {
                isParty = true;
            }
        }
        require(isParty, "Not a party to the contract");
        _;
    }

    function getContractsCount() external view returns (uint) {
        return draftContracts.length;
    }

    function viewContract(uint _contractId) external view onlyParty(_contractId) returns (Contract memory) {
        return draftContracts[_contractId];
    }

    function initiateContract(
        uint _amount, 
        address[] calldata _parties, 
        string memory _contractName, 
        string memory _document
    ) 
        external 
    {
        Contract memory newContract = Contract(draftContracts.length, _amount, false, msg.sender, _parties, _contractName, _document);
        draftContracts.push(newContract);
        initiatingParty[draftContracts.length-1] = msg.sender;
        emit createdContract(draftContracts.length-1);
    }

    function validateContract(uint _contractId) external payable onlyInitiator(_contractId) {
        require(msg.value == draftContracts[_contractId].amount);
        draftContracts[_contractId].isValid = true;
    }
}