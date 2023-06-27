require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const privateKeys = process.env.PRIVATE_KEYS || ""



/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.18",
  networks: {
     localhost: {},
     kovan : {
      url: `https://kovan.infura/io/v3/${process.env.INFURA_API_KEY}`,
      accounts: privateKeys.split(',')
     },
     mumbai : {
      url : `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: privateKeys.split(',')
     }
  },
  mocha: {
		timeout: 5000000,
	},
};
