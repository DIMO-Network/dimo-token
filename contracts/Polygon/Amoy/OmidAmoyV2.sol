// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

contract OmidAmoyV2 is
    ERC20BurnableUpgradeable,
    ERC165Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ERC20VotesUpgradeable
{
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    function initialize() public initializer {
        __ERC20_init("Omid", "OMID");
        __ERC20Burnable_init();
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);
        _mint(msg.sender, 1000000000 * 10**decimals());
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function deposit(address user, bytes calldata depositData)
        external
        onlyRole(DEPOSITOR_ROLE)
    {
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function burn(address user, uint256 amount) external onlyRole(BURNER_ROLE) {
        super._burn(user, amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyRole(BURNER_ROLE) {
        super.burnFrom(account, amount);
    }

    function mint(address user, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(user, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable) 
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable) 
    {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable)  {
        super._afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    function supportsInterface(bytes4 interfaceId) public pure override(AccessControlUpgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}
