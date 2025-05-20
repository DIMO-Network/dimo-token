# DIMO Token and Governance

## Documentation

- [Dimo documentation](https://docs.dimo.zone/docs)

The contracts are organized into different files by network and purpose: 

```
📦 contracts
┗ 📂 Mainnet
  ┗ 📂 DimoV1
    ┗ 📜 Dimo.sol
  ┗ 📂 DimoV2
    ┣ 📜 DimoV2.sol
    ┗ 📜 StorageV1.sol
┗ 📂 Mumbai
  ┣ 📜 Omid.sol
  ┗ 📜 OmidV2.sol
┗ 📂 Polygon
  ┗ 📂 ChildToken
    ┣ 📜 Dimo.sol
    ┗ 📜 DimoV2.sol
  ┗ 📂 TestDev
    ┗ 📜 TestDev.sol
  ┗ 📂 Governance
    ┣ 📜 DimoGovernorUpgradeable.sol
    ┗ 📜 TimeLockUpgradeable.sol
```

## How to run

You can execute the following commands to build the project and run additional scripts:

```sh
# Installs dependencies
npm i

# Clears cache, compiles contracts and generates typechain files
npm run build
```

### Scripts

You can deploy the contracts running the following scripts, where `network_name` is one of the networks available in [hardhat.config.ts](./hardhat.config.ts):

```sh
# Deploys/upgrade token in the Mainnet
npx hardhat run scripts/deployMainnetUpgrade.ts --network mainnet

# Deploys/upgrade token in Polygon
npx hardhat run scripts/deployPolygonDimoV2.ts --network polygon

# Deploys/upgrade governance in Polygon
npx hardhat run scripts/deployGovernance.ts --network polygon
```

You can also verify contracts in etherscan/polygonscan/etc running the following command. Remove `<constructor_arguments>` if there isn't any.

```sh
npx hardhat verify '<deployed_contract_address>' '<constructor_arguments>' --network '<network_name>'

# Use this flag to specify the contract implementation if needed
npx hardhat verify '<deployed_contract_address>' '<constructor_arguments>' --network '<network_name>' --contract '<contract_path>:<contract_name>'
```

You can print the order in which inherited contracts are linearized:

```sh
npx hardhat print-linearization contracts/../<ContractName>.sol:<ContractName>
```

## Testing

You can run the test suite with the following command:

```sh
# Runs test suite
npm run test
```

## Audit

[Sayfer - October 2022](https://sayfer.io/audits/smart-contract-audit-report-for-dimo/)
[Sayfer - March 2024](https://sayfer.io/audits/smart-contract-audit-report-for-dimo-4/)
