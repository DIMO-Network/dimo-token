import { ethers, upgrades, network } from "hardhat";

const DIMO_MAINNET_ADDRESS = '0x5fab9761d60419c9eeebe3915a8fa1ed7e8d2e1b';
const DIMO_ADDRESS = '0xe261d618a959afffd53168cd07d12e37b26761db';
const OMID_ADDRESS = '0x80ee7ec4493a1d7975ab900f94db25ba7c688201';

async function main() {
  const [owner] = await ethers.getSigners();

  const DimoChildTokenV1 = await ethers.getContractFactory("DimoChildTokenV1");
  const Dimo = await ethers.getContractFactory("contracts/Polygon/ChildToken/DimoV2.sol:Dimo");

  await upgrades.forceImport(
    DIMO_ADDRESS,
    DimoChildTokenV1,
    {
      kind: 'uups',
    },
  );

  await upgrades.validateImplementation(
    Dimo,
    {
      kind: 'uups',
    },
  );

  await upgrades.validateUpgrade(
    DIMO_ADDRESS,
    Dimo,
    {
      kind: 'uups',
    },
  )

  const contractImplementation = await Dimo.deploy();
  await contractImplementation.deployed();
  console.log("Deployed to ", contractImplementation.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
