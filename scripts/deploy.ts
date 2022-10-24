import { ethers, upgrades } from "hardhat";

async function main() {
  const Dimo = await ethers.getContractFactory("Dimo");
  console.log("Deploying proxy and implementation.");
  const dimo = await upgrades.deployProxy(Dimo);
  await dimo.deployed();
  console.log("Deployment Success.");
  const implAddress = await upgrades.erc1967.getImplementationAddress(dimo.address);
  console.log("Dimo Proxy Deployed To:", dimo.address);
  console.log("Dimo Implementation Deployed To:", implAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
