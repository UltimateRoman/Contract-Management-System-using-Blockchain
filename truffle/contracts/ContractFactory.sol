// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    function getArraySum(uint[] memory array) private pure returns (uint) {
        uint arraySum;
        for (uint i=0; i < array.length; ++i) {
            arraySum += array[i];
        }
        return arraySum;
    }

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

    function getMyContracts() external view returns (address[] memory) {
        uint j = 0;
        for (uint i=0; i < contractsList.length; ++i) {
            if (isPartyOf(msg.sender, contractsList[i].id)) {
                j++;
            }
        }
        uint k=0;
        address[] memory myContracts = new address[](j);
        for (uint i=0; i < contractsList.length; ++i) {
            if (isPartyOf(msg.sender, contractsList[i].id)) {
                myContracts[k] = contractsList[i].contractAddress;
                k++;
            }
        }
        return myContracts;
    }

    function initiateContract(
        CompleteContractData calldata _contractData
    ) 
        external 
    {
        address newContract = Clones.clone(baseContract);
        contractsList.push(BaseContractData(contractsList.length, newContract, msg.sender, _contractData.parties));
        ContractController(newContract).initialize(_contractData, daiTokenAddress);
        if (_contractData.isPayable) {
            bool success = IERC20(daiTokenAddress).transferFrom(msg.sender, newContract, getArraySum(_contractData.fundDistribution));
            require(success, "DAI transfer failed");
        }
        emit createdNewDraftContract(contractsList.length-1);
    }
}