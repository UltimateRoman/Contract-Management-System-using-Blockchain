// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract ContractStages {

    enum ContractManagementStages {
        PartyApprovalPending,
        FinalApprovalPending,
        Validated,
        Expired,
        Rejected
    }

    ContractManagementStages internal currentStage = ContractManagementStages.PartyApprovalPending;

    function _atStage(ContractManagementStages _stage) internal view {
        require(currentStage == _stage, "Not in expected stage");
    }

    function _jumpToNextStage() internal {
        require(uint(currentStage) + 1 <= 2, "Invalid stage");
        currentStage = ContractManagementStages(uint(currentStage) + 1);
    }

    function _goToRejected() internal {
        currentStage = ContractManagementStages(4);
    }
}