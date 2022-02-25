// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract ContractStages {

    enum ContractManagementStages {
        Initiation,
        PartiesApproved,
        FinallyApproved,
        Execution,
        Expired,
        Rejected
    }

    ContractManagementStages internal currentStage = ContractManagementStages.Initiation;

    function getStage() external view returns (uint) {
        return uint(currentStage);
    }

    function jumpStage(uint8 _offset) external {
        currentStage = ContractManagementStages(uint(currentStage) + _offset);
    }
}