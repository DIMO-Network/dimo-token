import { ethers, upgrades, network } from "hardhat";

const dimoProxyAddress = "0xA40C0a17c21fe335308Be305a3315B14bBeD5157";

async function upgrade(signer: any) {
  const DimoOld = await ethers.getContractFactory("contracts/Base/Mainnet/DimoV2.sol:Dimo", signer);
  await upgrades.forceImport(dimoProxyAddress, DimoOld, {
    kind: 'uups',
  });

  const DimoNewVersion = await ethers.getContractFactory("contracts/Base/Mainnet/DimoV3.sol:Dimo", signer);

  await upgrades.validateImplementation(DimoNewVersion, {
    kind: 'uups',
  });
  await upgrades.validateUpgrade(dimoProxyAddress, DimoNewVersion, {
    kind: 'uups',
  });

  const upgraded = await upgrades.upgradeProxy(dimoProxyAddress, DimoNewVersion);
  console.log("New version DimoNewVersion deployed to: ", upgraded.address);
  await upgraded.deployed();

  const implAddress2 = await upgrades.erc1967.getImplementationAddress(
    upgraded.address
  );
  console.log("Dimo Proxy Deployed To: ", upgraded.address);
  console.log("DimoNewVersion Implementation Deployed To: ", implAddress2);

  console.log(
    "Proxy upgraded",
    await upgrades.erc1967.getImplementationAddress(upgraded.address)
  );
}

async function deploy(signer: any) {
  const DimoNewVersion = await ethers.getContractFactory("contracts/Base/Mainnet/DimoV3.sol:Dimo", signer);
  
  const contract = await DimoNewVersion.deploy()
  await contract.deployed()

  console.log("DimoNewVersion Implementation Deployed To:", contract.address);
}

async function main() {
  let [signer, funder] = await ethers.getSigners();

  if (network.name === 'hardhat' || network.name === 'localhost') {
  
    // 0x0a3092E52BD2565e451E846f064D63dC6864FF06 Base
    // 0xCED3c922200559128930180d3f0bfFd4d9f4F123 Polygon
    // 0x1741eC2915Ab71Fc03492715b5640133dA69420B Deployer
    // 0xC008EF40B0b42AAD7e34879EB024385024f753ea Shared account
    signer = await ethers.getImpersonatedSigner(
      '0xC008EF40B0b42AAD7e34879EB024385024f753ea'
    );

    await funder.sendTransaction({
      to: await signer.getAddress(),
      value: ethers.utils.parseEther('100')
    });
  }

  await deploy(signer);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
