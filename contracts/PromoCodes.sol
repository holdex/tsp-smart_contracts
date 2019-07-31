pragma solidity ^0.4.24;


import "./Staff.sol";
import "./StaffUtil.sol";
import "./Crowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


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

	constructor(Staff _staffContract) StaffUtil(_staffContract) public {
	}

	modifier onlyCrowdsale() {
		require(msg.sender == crowdsale);
		_;
	}

	function setCrowdsale(Crowdsale _crowdsale) external onlyOwner {
		require(crowdsale == address(0));
		require(_crowdsale.staffContract() == staffContract);
		crowdsale = _crowdsale;
	}

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

	function calculateBonusAmount(address _investor, uint256 _purchasedAmount, bytes32 _promoCode) public constant returns (uint256) {
		if (promoCodes[_promoCode].percent == 0
		|| promoCodes[_promoCode].investors[_investor]
		|| promoCodes[_promoCode].uses == promoCodes[_promoCode].maxUses) {
			return 0;
		}
		return _purchasedAmount.mul(promoCodes[_promoCode].percent).div(100);
	}

	function addPromoCode(string _name, bytes32 _code, uint256 _maxUses, uint8 _percent) public onlyOwnerOrStaff {
		require(bytes(_name).length > 0);
		require(_code[0] != 0);
		require(_percent > 0 && _percent <= 100);
		require(_maxUses > 0);
		require(promoCodes[_code].percent == 0);

		promoCodes[_code].percent = _percent;
		promoCodes[_code].maxUses = _maxUses;

		emit PromoCodeAdded(_code, _name, _percent, _maxUses, now, msg.sender);
	}

	function removePromoCode(bytes32 _code) public onlyOwnerOrStaff {
		delete promoCodes[_code];
		emit PromoCodeRemoved(_code, now, msg.sender);
	}
}
