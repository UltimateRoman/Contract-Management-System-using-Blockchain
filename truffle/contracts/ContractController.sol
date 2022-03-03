// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IContractInit.sol";
import "./ContractStages.sol";

contract ContractController is IContractInit, ContractStages, Initializable {
    CompleteContractData contractData;

    mapping(address => bool) hasPartyApproved;
    mapping(address => uint) fundDistribution;

    event contractInitialized(address contractAddress);
    event partyApproved(address party, address contractAddress);
    event finalApprovalCompleted(address contractAddress);
    event paymentExecuted(address contractAddress);
    event contractRejectedByParty(address party, address contractAddress);

    modifier onlyInitiator() {
        require(msg.sender == contractData.initiatingParty, "Not initiating party");
        _;
    }

    modifier onlyParty() {
        bool isParty;
        if (contractData.initiatingParty == msg.sender) {
            isParty = true;
        } else {
            for (uint i = 0; i < contractData.parties.length; ++i) {
                if (contractData.parties[i] == msg.sender) {
                    isParty = true;
                    break;
                }
            }
        }
        require(isParty, "Not a party to the contract");
        _;
    }

    function getContractStage() external view onlyParty returns (uint) {
        return uint(currentStage);
    }

    function viewContractData() external view onlyParty returns (CompleteContractData memory) {
        return contractData;
    }

    function initialize(
        CompleteContractData calldata _contractData
    )
        external 
        initializer
    {
        contractData = _contractData;
        if (_contractData.isPayable) {
            for (uint i=0; i < _contractData.fundDistribution.length; i++) {
                fundDistribution[_contractData.parties[i]] = _contractData.fundDistribution[i];
            }
        }
        emit contractInitialized(address(this));
    }
}