pragma solidity ^0.5.0;

interface ERC20Token {
	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function burn(uint256 amount) external;

	function decimals() external view returns (uint8);
}
