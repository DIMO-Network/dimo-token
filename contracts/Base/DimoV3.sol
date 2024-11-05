// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
`
contract Dimo is
    ERC20BurnableUpgradeable,
    ERC165Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ERC20VotesUpgradeable
    //do we need to add the OptimismInteface
{
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address public immutable REMOTE_TOKEN;
    address public immutable BRIDGE;
    uint8 public immutable DECIMALS;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    //0x3154Cf16ccdb4C6d922629664174b904d80F2C35
    function initialize(address _bridge, address _remoteToken, uint8 _decimals) public initializer {
        __ERC20_init("Dimo", "DIMO");
        __ERC165_init();
        __ERC20Burnable_init();
        __AccessControl_init();
        __Pausable_init();
        __ERC20Votes_init();
        __UUPSUpgradeable_init();

        REMOTE_TOKEN = _remoteToken; //0x5fd
        BRIDGE = _bridge; //
        DECIMALS = _decimals;

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

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(address _from, uint256 _amount) external onlyRole(BURNER_ROLE) {
        _burn(_from, _amount);
        emit(Burn(_from, _amount));
    }

    function remoteToken() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    function bridge() public view override returns (address) {
        return BRIDGE;
    }

    function l1Token() public view returns (address) {
        return REMOTE_TOKEN;
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

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC165Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IOptimismMintableERC20).interfaceId ||
            interfaceId == type(ILegacyMintableERC20).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    function decimals() public view override virtual returns (uint8) {
        return DECIMALS;
    }
}
