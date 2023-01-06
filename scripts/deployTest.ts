import { ethers, upgrades } from "hardhat";

async function main() {
  const TestDev = await ethers.getContractFactory("TestDev");
  console.log("Deploying proxy and implementation");
  let testDev = await upgrades.deployProxy(TestDev, {
    initializer: "initialize"
  });
  console.log("Deployed to: ", testDev.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
