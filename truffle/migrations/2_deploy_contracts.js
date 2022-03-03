const ContractFactory = artifacts.require("ContractFactory");
const ContractController = artifacts.require("ContractController");

module.exports = async function(deployer) {
    await deployer.deploy(ContractFactory);
}