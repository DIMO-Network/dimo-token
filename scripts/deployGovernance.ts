import { ethers, upgrades } from "hardhat";

const DIMO_ADDRESS = '0x21cFE003997fB7c2B3cfe5cf71e7833B7B2eCe10';

async function main() {
  const [owner] = await ethers.getSigners();

  const TimeLock = await ethers.getContractFactory("TimeLock");
  const DimoGovernor = await ethers.getContractFactory("DimoGovernor");

  await upgrades.validateImplementation(
    TimeLock,
    {
      kind: 'uups',
    },
  );

  await upgrades.validateImplementation(
    DimoGovernor,
    {
      kind: 'uups',
    },
  );

  let timelock = await upgrades.deployProxy(TimeLock, [21600, [], [], owner.address], {
    initializer: "initialize",
    kind: 'uups'
  });
  await timelock.deployed();
  console.log("TimeLock deployed to ", timelock.address);

  let dimoGovernor = await upgrades.deployProxy(DimoGovernor, [DIMO_ADDRESS, timelock.address], {
    initializer: "initialize",
    kind: 'uups'
  });
  await dimoGovernor.deployed();
  console.log("DimoGovernor deployed to ", dimoGovernor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
