require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */


/**
* @type import('hardhat/config').HardhatUserConfig
*/

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { ETH_RINKEBY_API_URL, ETH_RINKEBY_PRIVATE_KEY, ETH_MAINNET_API_URL, ETH_MAINNET_PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
   defaultNetwork: "rinkeby",
   networks: {
      hardhat: {},
      eth_rinkeby: {
         url: ETH_RINKEBY_API_URL,
         gas: 4000000,
         accounts: [`0x${ETH_RINKEBY_PRIVATE_KEY}`]
      },
      eth_mainnet: {
        url: ETH_MAINNET_API_URL,
        gasPrice: 140000000000,
        gas: 3800000,
        accounts: [`0x${ETH_MAINNET_PRIVATE_KEY}`]
     }
   },
   etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
}
