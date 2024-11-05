// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import {IOptimismMintableERC20, ILegacyMintableERC20} from "./IOptimismMintableERC20.sol";

contract Dimo is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IOptimismMintableERC20,
    ILegacyMintableERC20
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address public REMOTE_TOKEN;
    address public BRIDGE;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _bridge,
        address _remoteToken
    ) public initializer {
        __ERC20_init("Dimo", "DIMO");
        __ERC165_init();
        __ERC20Burnable_init();
        __AccessControl_init();
        __Pausable_init();
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        REMOTE_TOKEN = _remoteToken;
        BRIDGE = _bridge;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, _bridge);
        _setupRole(BURNER_ROLE, _bridge);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(
        address to,
        uint256 amount
    )
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyRole(MINTER_ROLE)
    {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(
        address _from,
        uint256 _amount
    )
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyRole(BURNER_ROLE)
    {
        _burn(_from, _amount);
        emit Burn(_from, _amount);
    }

    function remoteToken() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    function bridge() public view override returns (address) {
        return BRIDGE;
    }

    function l1Token() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
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

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        override(IERC165Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IOptimismMintableERC20).interfaceId ||
            interfaceId == type(ILegacyMintableERC20).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}
