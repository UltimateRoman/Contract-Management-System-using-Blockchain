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
    address public daiTokenAddress;

    constructor(address _daiTokenAddress) {
        daiTokenAddress = _daiTokenAddress;
        baseContract = address(new ContractController());
    }

    BaseContractData[] public contractsList;

    event createdNewDraftContract(uint);    

    function isPartyOf(address _partyAddress, uint _contractId) internal view returns (bool) {
        bool isParty;
        if (contractsList[_contractId].initiatingParty == _partyAddress) {
            isParty = true;
        } else {
            for (uint i=0; i < contractsList[_contractId].parties.length; i++) {
                if (contractsList[_contractId].parties[i] == _partyAddress) {
                    isParty = true;
                    break;
                }
            }
        }
        return isParty;
    }

    function getContractsCount() external view returns (uint) {
        return contractsList.length;
    }

    function initiateContract(
        CompleteContractData calldata _contractData
    ) 
        external 
    {
        address[] memory partyAddresses = new address[](_contractData.parties.length);
        for (uint8 i=0; i<partyAddresses.length; ++i) {
            partyAddresses[i] = _contractData.parties[i];
        }
        address newContract = Clones.clone(baseContract);
        contractsList.push(BaseContractData(contractsList.length, newContract, msg.sender, partyAddresses));
        ContractController(newContract).initialize(_contractData, daiTokenAddress);
        emit createdNewDraftContract(contractsList.length-1);
    }
}