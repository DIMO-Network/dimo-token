// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

/**
 * @title IOptimismMintableERC20
 * @notice This interface is available on the OptimismMintableERC20 contract. We declare it as a
 *         separate interface so that it can be used in custom implementations of
 *         OptimismMintableERC20.
 */
interface IOptimismMintableERC20 is IERC165Upgradeable {
    function remoteToken() external returns (address);

    function bridge() external returns (address);

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

/**
 * @custom:legacy
 * @title ILegacyMintableERC20
 * @notice This interface was available on the legacy L2StandardERC20 contract. It remains available
 *         on the OptimismMintableERC20 contract for backwards compatibility.
 */
interface ILegacyMintableERC20 is IERC165Upgradeable {
    function l1Token() external returns (address);

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}
