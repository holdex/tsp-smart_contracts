pragma solidity ^0.5.0;

interface IPromoCodes {
	function applyBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode) external returns (uint256);
}
