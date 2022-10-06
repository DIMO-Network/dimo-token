import { ethers, upgrades } from "hardhat";

async function main() {
  const [owner] = await ethers.getSigners();

  const DimoChildTokenV1 = await ethers.getContractFactory("DimoChildTokenV1");
  console.log("Deploying proxy and implementation");
  const dimo = await upgrades.deployProxy(DimoChildTokenV1, {
    initializer: "initialize",
    kind: "uups",
  });
  console.log("First version deployed to: ", dimo.address);

  await dimo.grantRole(await dimo.UPGRADER_ROLE(), owner.address);

  const DimoChildTokenV2 = await ethers.getContractFactory("DimoChildTokenV2");
  const upgraded = await upgrades.upgradeProxy(dimo.address, DimoChildTokenV2, {
    unsafeSkipStorageCheck: false,
  });
  console.log("New version DimoV2 deployed to: ", upgraded.address);
  await upgraded.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
