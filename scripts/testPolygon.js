const { ethers, upgrades } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  const Dimo = await ethers.getContractFactory("Dimo");
  console.log("Deploying proxy and implementation");
  const dimoProxy = await upgrades.deployProxy(Dimo, {
    initializer: "initialize",
  });
  await dimoProxy.deployed();

  console.log("Deployment Success");
  const implAddress = await upgrades.erc1967.getImplementationAddress(
    dimoProxy.address
  );
  console.log("Dimo Proxy Deployed To: ", dimoProxy.address);
  console.log("Dimo Implementation Deployed To: ", implAddress);

  const DEFAULT_ADMIN_ROLE = await dimoProxy.DEFAULT_ADMIN_ROLE();
  const DEPOSITOR_ROLE = await dimoProxy.DEPOSITOR_ROLE();
  const PAUSER_ROLE = await dimoProxy.PAUSER_ROLE();
  const MINTER_ROLE = await dimoProxy.MINTER_ROLE();
  const UPGRADER_ROLE = await dimoProxy.UPGRADER_ROLE();

  console.log("\nRoles");
  console.log(DEFAULT_ADMIN_ROLE);
  console.log(DEPOSITOR_ROLE);
  console.log(PAUSER_ROLE);
  console.log(MINTER_ROLE);
  console.log(UPGRADER_ROLE);

  console.log("\nHas Roles");
  console.log(await dimoProxy.hasRole(DEFAULT_ADMIN_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(DEPOSITOR_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(PAUSER_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(MINTER_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(UPGRADER_ROLE, owner.address));

  await (await dimoProxy.grantRole(DEPOSITOR_ROLE, owner.address)).wait();
  await (await dimoProxy.grantRole(PAUSER_ROLE, owner.address)).wait();
  await (await dimoProxy.grantRole(MINTER_ROLE, owner.address)).wait();
  await (await dimoProxy.grantRole(UPGRADER_ROLE, owner.address)).wait();
  console.log(await dimoProxy.hasRole(DEPOSITOR_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(PAUSER_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(MINTER_ROLE, owner.address));
  console.log(await dimoProxy.hasRole(UPGRADER_ROLE, owner.address));

  await dimoProxy.initialize();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
