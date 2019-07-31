pragma solidity ^0.5.0;

interface IDiscountStructs {
	function getBonus(address _investor, uint256 _purchasedAmount, uint256 _purchasedValue) external returns (uint256);
}
