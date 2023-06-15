async function main() {
    // Fetch contract to deploy
    const Token = await ethers.getContractFactory("Token")
    const Exchange = await ethers.getContractFactory("Exchange")

    // Fetch accounts
    const accounts = await ethers.getSigners()

    console.log(`Accounts fetched:\n${accounts[0].address}\n${accounts[1].address}\n`)
    
    // Deploy contract 
    const DeCo = await Token.deploy('DeCoin', 'DeCo', 1000000);
    await DeCo.deployed();
    console.log(`DeCo Deployed to: ${DeCo.address}`);
    
    const mETH = await Token.deploy('mETH', 'mETH', 1000000);
    await mETH.deployed();
    console.log(`mETH Deployed to: ${mETH.address}`);
    
    const mDAI = await Token.deploy('mDAI', 'mDAI', 1000000);
    await mDAI.deployed();
    console.log(`mDAI Deployed to: ${mDAI.address}`);

    const exchange = await Exchange.deploy(accounts[1].address, 5);
    await exchange.deployed();
    console.log(`Exchange Deployed to: ${exchange.address}`)
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });