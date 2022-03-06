const DAI = artifacts.require("DAI");
const ContractFactory = artifacts.require("ContractFactory");
const ContractController = artifacts.require("ContractController");

module.exports = async function(deployer) {
    await deployer.deploy(DAI);
    let dai = await DAI.deployed();
    await deployer.deploy(ContractFactory, dai.address);
}