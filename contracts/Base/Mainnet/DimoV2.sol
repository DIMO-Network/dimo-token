// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {IOptimismMintableERC20, ILegacyMintableERC20} from "./IOptimismMintableERC20.sol";

/**
 * @title Dimo
 * @dev DIMO is an ERC20 token deployed on the Base network. It was bridged from the Ethereum mainnet
 */
contract Dimo is
    Initializable,
    ERC20Upgradeable,
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
    uint8 public DECIMALS;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract
     * @param _bridge The address of the bridge contract
     * @param _remoteToken The address of the remote token on Ethereum Mainnet
     */
    function initialize(
        address _bridge,
        address _remoteToken
    ) public initializer {
        __ERC20_init("Dimo", "DIMO");
        __ERC20Votes_init();
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        require(_bridge != address(0), "Bridge cannot be zero address");
        require(_remoteToken != address(0), "Remote token cannot be zero address");

        REMOTE_TOKEN = _remoteToken;
        BRIDGE = _bridge;
        DECIMALS = 18;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, BRIDGE);
        _setupRole(BURNER_ROLE, BRIDGE);
    }

    /**
     * @notice Pauses the contract
     * @dev Can only be called by accounts with the PAUSER_ROLE
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the contract
     * @dev Can only be called by accounts with the PAUSER_ROLE
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Mints new tokens
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     * @dev Can only be called by accounts with the MINTER_ROLE
     */
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

    /**
     * @notice Burns tokens
     * @param _from The address to burn tokens from
     * @param _amount The amount of tokens to burn
     * @dev Can only be called by accounts with the BURNER_ROLE
     */
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

    /**
     * @notice Function required to integrate with Wormhole NttManager
     * @param amount The amount of tokens to burn
     * @dev Can only be called by accounts with the BURNER_ROLE
     */
    function burn(uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), amount);
        emit Burn(_msgSender(), amount);
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for the remote token. Use REMOTE_TOKEN going forward.
     */
    function l1Token() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for the bridge. Use BRIDGE going forward.
     */
    function l2Bridge() public view returns (address) {
        return BRIDGE;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for REMOTE_TOKEN.
     */
    function remoteToken() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for BRIDGE.
     */
    function bridge() public view override returns (address) {
        return BRIDGE;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

    /**
     * @notice Required override
     */
    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._mint(to, amount);
    }

    /**
     * @notice Required override
     */
    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }

    /**
     * @notice Required override
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
    }

    /**
     * @notice Required override
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @notice Authorizes an upgrade of the contract
     * @dev Can only be called by accounts with the UPGRADER_ROLE
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    /**
     * @notice ERC165 interface check function
     * @param interfaceId Interface ID to check
     * @return Whether or not the interface is supported by this contract
     */
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
