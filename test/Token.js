const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n, 'ether');
}

describe('Token', () => {
    let token, accounts, deployer;

    // In a test file, the function beforeEach() will be executed before each test. 
    beforeEach(async () => {
        // Fetch Token from Blockchain
        const Token = await ethers.getContractFactory('Token');
        token = await Token.deploy('DeCoin', 'DeCo', '1000000');

        accounts = await ethers.getSigners();
        deployer = accounts[0];
    })
    
    // creating different describe block to differentiate testing during deployment and other phases
    describe('Deployment', () => {
        const name = 'DeCoin';
        const symbol = 'DeCo';
        const decimals = '18';
        const totalSupply = tokens('1000000');

        it('has correct name', async () => {
            expect(await token.name()).to.equal(name);
        })
    
        it('has correct symbol', async () => {
            expect(await token.symbol()).to.equal(symbol);
        })
    
        it('has correct decimals', async () => {
            expect(await token.decimals()).to.equal(decimals);
        })
    
        it('has correct total supply', async () => {
            expect(await token.totalSupply()).to.equal(totalSupply);
        })

        it('assigns total supply to deployer', async () => {
            expect(await token.balanceOf(deployer.address)).to.equal(totalSupply);
        })
    })
})
