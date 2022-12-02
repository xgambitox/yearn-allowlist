// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

/*******************************************************
 *                      Interfaces
 *******************************************************/
interface IVeYfi {
  function token() external view returns(address);

  function reward_pool() external view returns(address);
}

interface IVeYfiRegistry {
  function isGauge(address) external view returns (bool);

  function getVaults() external view returns (address[] memory);
}

interface IAllowlistRegistry {
  function protocolOwnerAddressByOriginName(string memory originName)
    external
    view
    returns (address ownerAddress);
}

interface IAddressesProvider {
  function addressById(string memory) external view returns (address);
}

/*******************************************************
 *                      Implementation
 *******************************************************/
contract AllowlistImplementationVeYFI {
  string public constant protocolOriginName = "yearn.finance"; // Protocol owner name (must match the registered domain of the registered allowlist)
  address public addressesProviderAddress; // Used to fetch current veYFI registry
  address public allowlistRegistryAddress; // Used to fetch protocol owner
  mapping(address => bool) public isZapClaimContract; // Used to test zap claim contracts

  constructor(
    address _addressesProviderAddress,
    address _allowlistRegistryAddress
  ) {
    addressesProviderAddress = _addressesProviderAddress; // Set address provider address (can be updated by owner)
    allowlistRegistryAddress = _allowlistRegistryAddress; // Set allowlist registry address (can only be set once)
  }

  /**
   * @notice Only allow protocol owner to perform certain actions
   */
  modifier onlyOwner() {
    require(msg.sender == ownerAddress(), "Caller is not the protocol owner");
    _;
  }

  /**
   * @notice Fetch owner address from registry
   */
  function ownerAddress() public view returns (address protcolOwnerAddress) {
    protcolOwnerAddress = IAllowlistRegistry(allowlistRegistryAddress)
      .protocolOwnerAddressByOriginName(protocolOriginName);
  }

  /**
   * @notice Determine whether or not a contract address is a valid voting escrow contract
   * @param contractAddress The contract address to test
   * @return Returns true if the contract address is valid voting escrow contract and false if not
   */
  function isVotingEscrow(address contractAddress)
    public
    view
    returns (bool)
  {
    return veYfiAddress() == contractAddress;
  }

  /**
   * @notice Determine whether or not a token address is our underlying token
   * @param tokenAddress The token address to test
   * @return Returns true if the token address is the underlying and false if not
   */
  function isUnderlying(address tokenAddress)
    public
    view
    returns (bool)
  {
    return veYfi().token() == tokenAddress;
  }

  /**
   * @notice Determine whether or not an address is a valid reward pool contract
   * @param contractAddress The contract address to test
   * @return Returns true if the contract address is valid reward pool contract and false if not
   */
  function isRewardPool(address contractAddress)
    public
    view
    returns (bool)
  {
    return veYfi().reward_pool() == contractAddress;
  }

  /**
   * @notice Determine whether or not a gauge address is a valid gauge
   * @param gaugeAddress The gauge address to test
   * @return Returns true if the gauge address is valid and false if not
   */
  function isGauge(address gaugeAddress)
    public
    view
    returns (bool)
  {
    return veYfiRegistry().isGauge(gaugeAddress);
  }

  /*******************************************************
   *                    Convienence methods
   *******************************************************/

  /**
   * @dev Fetch veYFI address
   */
  function veYfiAddress() public view returns (address) {
    return
      IAddressesProvider(addressesProviderAddress).addressById(
        "VEYFI"
      );
  }

  /**
   * @dev Fetch veYFI interface
   */
  function veYfi() internal view returns (IVeYfi) {
    return IVeYfi(veYfiAddress());
  }

  /**
   * @dev Fetch veYFI registry address
   */
  function veYfiRegistryAddress() public view returns (address) {
    return
      IAddressesProvider(addressesProviderAddress).addressById(
        "VEYFI_REGISTRY"
      );
  }

  /**
   * @dev Fetch veYFI registry interface
   */
  function veYfiRegistry() internal view returns (IVeYfiRegistry) {
    return IVeYfiRegistry(veYfiRegistryAddress());
  }
}
