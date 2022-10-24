// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TimeLock is
    Initializable,
    TimelockControllerUpgradeable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) public initializer {
        __TimelockController_init(minDelay, proposers, executors, admin);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(TIMELOCK_ADMIN_ROLE)
    {}
}
