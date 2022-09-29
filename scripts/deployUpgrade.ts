const { ethers, upgrades } = require("hardhat");

const dimoV1Address = "0x0";

async function main() {
  const [owner, user1] = await ethers.getSigners();

  const DimoV2 = await ethers.getContractFactory("DimoV2");
  console.log("New version DimoV2 deployed to: ", DimoV2.address);
  const upgraded = await upgrades.upgradeProxy(dimoV1Address, DimoV2);
  await upgraded.deployed();

  const implAddress2 = await upgrades.erc1967.getImplementationAddress(
    upgraded.address
  );
  console.log("Dimo Proxy Deployed To: ", upgraded.address);
  console.log("DimoV2 Implementation Deployed To: ", implAddress2);

  await upgraded.grantRole(await upgraded.BURNER_ROLE(), owner.address);

  console.log(
    "Proxy upgraded",
    await upgrades.erc1967.getImplementationAddress(upgraded.address)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
