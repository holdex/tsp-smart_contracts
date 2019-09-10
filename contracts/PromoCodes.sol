pragma solidity ^0.5.0;


import "./interfaces/IStaff.sol";
import "./StaffUtil.sol";
import "./interfaces/IStaffUtil.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract PromoCodes is StaffUtil {
	using SafeMath for uint256;

	address public crowdsale;

	event PromoCodeAdded(bytes32 indexed code, string name, uint8 percent, uint256 maxUses, uint timestamp, address byStaff);
	event PromoCodeRemoved(bytes32 indexed code, uint timestamp, address byStaff);
	event PromoCodeUsed(bytes32 indexed code, address investor, uint timestamp);

	struct PromoCode {
		uint8 percent;
		uint256 uses;
		uint256 maxUses;
		mapping(address => bool) investors;
	}

	mapping(bytes32 => PromoCode) public promoCodes;

	constructor(IStaff _staffContract) StaffUtil(_staffContract) public {
	}

	modifier onlyCrowdsale() {
		require(msg.sender == crowdsale);
		_;
	}
	
	/*
	function setCrowdsale
	
	Connect bonus contract with distribution contract.
	Parameter: 
	_crowdsale - distribution contract address
	*/

	function setCrowdsale(IStaffUtil _crowdsale) external onlyOwner {
		require(crowdsale == address(0));
		require(_crowdsale.staffContract() == address(staffContract));
		crowdsale = address(_crowdsale);
	}
	
	/*
	function applyBonusAmount
	
	Internal function. Returns the amount of bonus a contributor received from a token purchase.
	Parameters: 
	_investor - contributor wallet address
	_purchasedAmount - amount of tokens purchased in transaction
	_promoCode - promo-code applied for transaction
	*/
	
	function applyBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode) public onlyCrowdsale returns (uint256) {
		if (promoCodes[_promoCode].percent == 0
		|| promoCodes[_promoCode].investors[_investor]
		|| promoCodes[_promoCode].uses == promoCodes[_promoCode].maxUses) {
			return 0;
		}
		promoCodes[_promoCode].investors[_investor] = true;
		promoCodes[_promoCode].uses = promoCodes[_promoCode].uses + 1;
		emit PromoCodeUsed(_promoCode, _investor, now);
		return _purchasedAmount.mul(promoCodes[_promoCode].percent).div(100);
	}
	
	/*
	function calculateBonusAmount
	
	Internal function. Calculates the amount of bonus to be applied to a token purchase.
	Parameters: 
	_investor - contributor wallet address
	_purchasedAmount - amount of tokens purchased in transaction
	_promoCode - promo-code applied for transaction
	*/
	
	function calculateBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode) public view returns (uint256) {
		if (promoCodes[_promoCode].percent == 0
		|| promoCodes[_promoCode].investors[_investor]
		|| promoCodes[_promoCode].uses == promoCodes[_promoCode].maxUses) {
			return 0;
		}
		return _purchasedAmount.mul(promoCodes[_promoCode].percent).div(100);
	}
	
	/*
	function addPromoCode
	
	Internal function. Creates a new promo-code. 
	Parameters: 
	_name - promo-code name
	_code - promo-code code
	_maxUses - maximum amount of purchases made from different wallet addresses that can be made with this promo code
	_percent - bonus percent allocated per purchase
	*/
	
	function addPromoCode(string memory _name, bytes32 _code, uint256 _maxUses, uint8 _percent) public onlyOwnerOrStaff {
		require(bytes(_name).length > 0);
		require(_code[0] != 0);
		require(_percent > 0 && _percent <= 100);
		require(_maxUses > 0);
		require(promoCodes[_code].percent == 0);

		promoCodes[_code].percent = _percent;
		promoCodes[_code].maxUses = _maxUses;

		emit PromoCodeAdded(_code, _name, _percent, _maxUses, now, msg.sender);
	}
	
	/*
	function addPromoCode
	
	Internal function. Removes an active promo-code. 
	Parameter: 
	_code - promo-code code
	*/
	
	function removePromoCode(bytes32 _code) public onlyOwnerOrStaff {
		delete promoCodes[_code];
		emit PromoCodeRemoved(_code, now, msg.sender);
	}
}
