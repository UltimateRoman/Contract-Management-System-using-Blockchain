// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IContractInit.sol";
import "./ContractController.sol";

/**
 * @title CMSB Contract Factory
 * @dev Create and view draft contracts
 */

contract ContractFactory is IContractInit {

    address public immutable baseContract;

    constructor() {
        baseContract = address(new ContractController());
    }

    BaseContractData[] public contractsList;

    event createdNewDraftContract(uint);    

    function getContractsCount() external view returns (uint) {
        return contractsList.length;
    }

    function initiateContract(
        CompleteContractData calldata _contractData
    ) 
        external 
    {
        address newContract = Clones.clone(baseContract);
        contractsList.push(BaseContractData(contractsList.length, newContract, msg.sender, _contractData.parties));
        ContractController(newContract).initialize(_contractData);
        emit createdNewDraftContract(contractsList.length-1);
    }
}