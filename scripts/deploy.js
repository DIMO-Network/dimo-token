// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat");
const { LedgerSigner } = require("@ethersproject/hardware-wallets");    

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  console.log("Running compile for contracts.");
  await run('compile');

  const Dimo = await ethers.getContractFactory("Dimo");
  console.log("Deploying proxy and implementation.");
  const dimo = await upgrades.deployProxy(Dimo);
  await dimo.deployed();
  console.log("Deployment Success.");
  const implAddress = await upgrades.erc1967.getImplementationAddress(dimo.address);
  console.log("Dimo Proxy Deployed To:", dimo.address);
  console.log("Dimo Implementation Deployed To:", implAddress);

  console.log("Verifying contract:", implAddress);
  await run("verify:verify", {address: implAddress});

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
