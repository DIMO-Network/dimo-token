// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

contract TestDevPolygon is
    ERC20Upgradeable,
    ERC165Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ERC20VotesUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    function initialize() public initializer {
        __ERC20_init("TestDev", "TD");
        __ERC165_init();
        __AccessControl_init();
        __Pausable_init();
        __ERC20Votes_init();
        __UUPSUpgradeable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function withdraw(uint256 amount) external {
        ERC20VotesUpgradeable._burn(_msgSender(), amount);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        ERC20VotesUpgradeable._mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     * @notice Function required to integrate with Wormhole NttManager
     * @param amount The amount of tokens to burn
     * @dev Can only be called by accounts with the BURNER_ROLE
     */
    function burn(uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), amount);
        emit Burn(_msgSender(), amount);
    }

    function burn(address user, uint256 amount) external onlyRole(BURNER_ROLE) {
        ERC20VotesUpgradeable._burn(user, amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        override(AccessControlUpgradeable, ERC165Upgradeable)
        returns (bool)
    {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        ERC20VotesUpgradeable._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        ERC20VotesUpgradeable._burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        ERC20VotesUpgradeable._afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}
}
