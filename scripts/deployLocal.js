const { ethers, upgrades } = require("hardhat");

async function main() {
  const [owner, user1] = await ethers.getSigners();

  console.log("Running compile for contracts.");
  await run("compile");

  const Dimo = await ethers.getContractFactory("Dimo");
  console.log("Deploying proxy and implementation");
  const dimo = await upgrades.deployProxy(Dimo, {
    initializer: "initialize",
  });
  await dimo.deployed();
  console.log("Deployment Success.");
  const implAddress = await upgrades.erc1967.getImplementationAddress(
    dimo.address
  );
  console.log("Dimo Proxy Deployed To: ", dimo.address);
  console.log("Dimo Implementation Deployed To: ", implAddress);

  console.log();
  console.log(await dimo.SNAPSHOT_ROLE());
  console.log(await dimo.PAUSER_ROLE());
  console.log(await dimo.MINTER_ROLE());
  console.log(await dimo.UPGRADER_ROLE());
  console.log();
  await dimo.mint(owner.address, 1000000000);
  console.log(await dimo.balanceOf(owner.address));
  console.log(await dimo.totalSupply());

  const DimoV2 = await ethers.getContractFactory("DimoV2");
  console.log("New version DimoV2 deployed to: ", DimoV2.address);
  const upgraded = await upgrades.upgradeProxy(dimo.address, DimoV2);
  await upgraded.deployed();

  const implAddress2 = await upgrades.erc1967.getImplementationAddress(
    upgraded.address
  );
  console.log("Dimo Proxy Deployed To: ", upgraded.address);
  console.log("Dimo Implementation Deployed To: ", implAddress2);
  
  await upgraded.grantRole(await upgraded.BURNER_ROLE(), owner.address);
  await upgraded.grantRole(await upgraded.BURNER_ROLE(), user1.address);
  await upgraded.mint(owner.address, 1000000000);
  console.log(await dimo.balanceOf(owner.address));
  console.log(await dimo.totalSupply());

  console.log(
    "Proxy upgraded",
    await upgrades.erc1967.getImplementationAddress(dimo.address)
  );

  console.log();
  // console.log(await upgraded.getSNAPSHOT_ROLE());
  console.log(await upgraded.PAUSER_ROLE());
  console.log(await upgraded.MINTER_ROLE());
  console.log(await upgraded.UPGRADER_ROLE());
  console.log(await upgraded.BURNER_ROLE());
  // for (let i = 200; i < 500; i++) {
  //   console.log(i, await ethers.provider.getStorageAt(upgraded.address, i));
  // }
  // console.log(
  //   await upgraded.hasRole(await upgraded.BURNER_ROLE(), owner.address)
  // );

  await upgraded.approve(user1.address, 1000000000);
  await upgraded.connect(user1).burnFrom(owner.address, 1000000000);
  console.log(await dimo.balanceOf(owner.address));
  console.log(await dimo.totalSupply());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
