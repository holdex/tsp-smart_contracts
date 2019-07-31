pragma solidity ^0.5.0;

interface IDiscountPhases {
	function getBonus(address _investor, uint _purchaseId, uint256 _purchasedTokensAmount, uint256 _purchasedWeiAmount, uint _discountId) external returns (uint256);

	function getBlockedBonus(address _investor, uint _purchaseId) external view returns (uint256);

	function getBlockedPurchased(address _investor, uint _purchaseId) external view returns (uint256[2] memory purchasedAmount);

	function cancelBonus(address _investor, uint _purchaseId) external;

	function cancelPurchase(address _investor, uint _purchaseId) external;
}
