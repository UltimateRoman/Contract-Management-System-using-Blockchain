const DAI  = artifacts.require("DAI");
const ContractFactory = artifacts.require("ContractFactory");
const ContractController = require("../build/contracts/ContractController.json");

contract("CMSB Contracts Test", (accounts) => {
    let contractFactory, baseContract, dai;

    before(async () => {
        dai = await DAI.deployed();
        contractFactory = await ContractFactory.deployed();
        baseContract = await contractFactory.baseContract();

        for (let i=0; i<5; ++i) {
            await dai.mint(accounts[i], web3.utils.toWei("100"));
        }
    });

    describe("Smart contract deployment", async () => {
        it("contract deploys succesfully", async () => {
            const address = await contractFactory.address;
            assert.isDefined(address);    
            assert.notEqual(address, "0x0000000000000000000000000000000000000000");    
            assert.isDefined(baseContract);    
            assert.notEqual(baseContract, "0x0000000000000000000000000000000000000000");
        });
    });

    describe("Contract Initiation", async () => {
        let contractMain;

        it("initiating party can create a new contract", async () => {
            let contractData = {
                isPayable: false,
                expiryTime: 2000000,
                fundDistribution: [0],
                initiatingParty: accounts[1],
                parties: [accounts[2], accounts[3]],
                contractName: "Sample contract",
                document:"https://sampleuri.ipfs.io"
            }

            await contractFactory.initiateContract(contractData, {from: accounts[1]});
        });

        it("contract list count is incremented", async () => {
            let contractCount = await contractFactory.getContractsCount();
            assert.equal(contractCount, 1);
        });

        it("contract data can be correctly retrieved", async () => {
            let baseContractData = await contractFactory.contractsList(0);

            contractMain = new web3.eth.Contract(ContractController.abi, baseContractData.contractAddress);
            const completeContractData = await contractMain.methods.viewContractData().call({from: accounts[1]});
            
            assert.equal(completeContractData.isPayable, false);
            assert.equal(completeContractData.expiryTime, 2000000);
            assert.equal(completeContractData.initiatingParty, accounts[1]);
            assert.equal(completeContractData.parties[0], accounts[2]);
            assert.equal(completeContractData.contractName, 'Sample contract');
            assert.equal(completeContractData.document, 'https://sampleuri.ipfs.io');
        });
    });
});