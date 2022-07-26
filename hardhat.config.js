require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-contract-sizer");
require("hardhat-storage-layout");

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

const {
  GOERLI_URL,
  MUMBAI_URL,
  PRIVATE_KEY,
  MAINNET_URL,
  POLYGON_URL,
  ETHERSCAN_API_KEY,
  POLYGONSCAN_API_KEY,
} = process.env;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.6",
      },
      {
        version: "0.8.10",
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      outputSelection: {
        "*": {
          "*": ["storageLayout"],
        },
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    goerli: {
      url: GOERLI_URL || "",
      accounts: PRIVATE_KEY !== undefined ? [`0x${PRIVATE_KEY}`] : [],
      allowUnlimitedContractSize: true,
    },
    mumbai: {
      url: MUMBAI_URL || "",
      accounts: PRIVATE_KEY !== undefined ? [`0x${PRIVATE_KEY}`] : [],
    },
    mainnet: {
      url: MAINNET_URL || "",
      gasPrice: 70000000000,
      gas: 3400000,
      accounts: PRIVATE_KEY !== undefined ? [`0x${PRIVATE_KEY}`] : [],
    },
    polygon: {
      url: POLYGON_URL || "",
      accounts: PRIVATE_KEY !== undefined ? [`0x${PRIVATE_KEY}`] : [],
    },
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: process.env.CONTRACT_SIZER !== undefined,
    disambiguatePaths: false,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  gasReporter: {
    enabled: !!process.env.REPORT_GAS,
  },
};
