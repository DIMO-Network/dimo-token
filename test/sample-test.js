const chai = require("chai");
const { expect } = require("chai");
const { ethers, waffle, upgrades } = require("hardhat");

const { solidity } = waffle;
const provider = waffle.provider;

chai.use(solidity);

describe("Dimo V1", function () {
  let dimo;
  let SNAPSHOT_ROLE;
  let PAUSER_ROLE;
  let MINTER_ROLE;
  let UPGRADER_ROLE;

  const [admin, nonAdmin] = provider.getWallets();

  beforeEach(async () => {
    const Dimo = await ethers.getContractFactory("Dimo");
    dimo = await upgrades.deployProxy(Dimo, {
      initializer: "initialize",
    });
    await dimo.deployed();

    SNAPSHOT_ROLE = await dimo.SNAPSHOT_ROLE();
    PAUSER_ROLE = await dimo.PAUSER_ROLE();
    MINTER_ROLE = await dimo.MINTER_ROLE();
    UPGRADER_ROLE = await dimo.UPGRADER_ROLE();

    const implAddress = await upgrades.erc1967.getImplementationAddress(
      dimo.address
    );
  });

  it("Should revert if caller does not have SNAPSHOT_ROLE", async () => {
    await expect(dimo.connect(nonAdmin).snapshot()).to.be.revertedWith(
      `AccessControl: account ${nonAdmin.address.toLowerCase()} is missing role ${SNAPSHOT_ROLE}`
    );
  });
  it("Should revert if caller does not have PAUSER_ROLE", async () => {
    await expect(dimo.connect(nonAdmin).pause()).to.be.revertedWith(
      `AccessControl: account ${nonAdmin.address.toLowerCase()} is missing role ${PAUSER_ROLE}`
    );
  });
  it("Should revert if caller does not have PAUSER_ROLE", async () => {
    await expect(dimo.connect(nonAdmin).unpause()).to.be.revertedWith(
      `AccessControl: account ${nonAdmin.address.toLowerCase()} is missing role ${PAUSER_ROLE}`
    );
  });
  it("Should revert if caller does not have MINTER_ROLE", async () => {
    await expect(
      dimo.connect(nonAdmin).mint(nonAdmin.address, 100)
    ).to.be.revertedWith(
      `AccessControl: account ${nonAdmin.address.toLowerCase()} is missing role ${MINTER_ROLE}`
    );
  });

  context("Upgraded", async () => {
    let upgraded;

    beforeEach(async () => {
      const DimoV2 = await ethers.getContractFactory("DimoV2");
      upgraded = await upgrades.upgradeProxy(dimo.address, DimoV2);
      await upgraded.deployed();
    });

    it("Should revert if caller does not have PAUSER_ROLE", async () => {
      await expect(upgraded.connect(nonAdmin).pause()).to.be.reverted;
      // `AccessControl: account ${nonAdmin.address} is missing role ${PAUSER_ROLE}`
    });
    it("Should revert if caller does not have PAUSER_ROLE", async () => {
      await expect(upgraded.connect(nonAdmin).unpause()).to.be.reverted;
      // `AccessControl: account ${nonAdmin.address} is missing role ${PAUSER_ROLE}`
    });
    it("Should revert if caller does not have MINTER_ROLE", async () => {
      await expect(upgraded.connect(nonAdmin).mint(nonAdmin.address, 100)).to.be
        .reverted;
      // `AccessControl: account ${nonAdmin.address} is missing role ${MINTER_ROLE}`
    });
    it("Should revert if caller does not have BURNER_ROLE", async () => {
      await expect(upgraded.connect(nonAdmin).burn(100)).to.be.reverted;
      // `AccessControl: account ${nonAdmin.address} is missing role ${BURNER_ROLE}`
    });
    it("Should revert if caller does not have BURNER_ROLE", async () => {
      await expect(upgraded.connect(nonAdmin).burnFrom(nonAdmin.address, 100))
        .to.be.reverted;
      // `AccessControl: account ${nonAdmin.address} is missing role ${BURNER_ROLE}`
    });
  });
});
