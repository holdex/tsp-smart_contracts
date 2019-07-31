pragma solidity ^0.4.24;


import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./Staff.sol";
import "./StaffUtil.sol";
import "./Crowdsale.sol";


contract DiscountStructs is StaffUtil {
	using SafeMath for uint256;

	address public crowdsale;

	event DiscountStructAdded(
		uint index,
		bytes32 name,
		uint256 tokens,
		uint[2] dates,
		uint256[] fromWei,
		uint256[] toWei,
		uint256[] percent,
		uint timestamp,
		address byStaff
	);
	event DiscountStructRemoved(
		uint index,
		uint timestamp,
		address byStaff
	);
	event DiscountStructUsed(
		uint index,
		uint step,
		address investor,
		uint256 tokens,
		uint timestamp
	);

	struct DiscountStruct {
		uint256 availableTokens;
		uint256 distributedTokens;
		uint fromDate;
		uint toDate;
	}

	struct DiscountStep {
		uint256 fromWei;
		uint256 toWei;
		uint256 percent;
	}

	DiscountStruct[] public discountStructs;
	mapping(uint => DiscountStep[]) public discountSteps;

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

	function getBonus(address _investor, uint256 _purchasedAmount, uint256 _purchasedValue) public onlyCrowdsale returns (uint256) {
		for (uint i = 0; i < discountStructs.length; i++) {
			if (now >= discountStructs[i].fromDate && now <= discountStructs[i].toDate) {

				if (discountStructs[i].distributedTokens >= discountStructs[i].availableTokens) {
					return;
				}

				for (uint j = 0; j < discountSteps[i].length; j++) {
					if (_purchasedValue >= discountSteps[i][j].fromWei
						&& (_purchasedValue < discountSteps[i][j].toWei || discountSteps[i][j].toWei == 0)) {
						uint256 bonus = _purchasedAmount.mul(discountSteps[i][j].percent).div(100);
						if (discountStructs[i].distributedTokens.add(bonus) > discountStructs[i].availableTokens) {
							return;
						}
						discountStructs[i].distributedTokens = discountStructs[i].distributedTokens.add(bonus);
						emit DiscountStructUsed(i, j, _investor, bonus, now);
						return bonus;
					}
				}

				return;
			}
		}
	}

	function calculateBonus(uint256 _purchasedAmount, uint256 _purchasedValue) public constant returns (uint256) {
		for (uint i = 0; i < discountStructs.length; i++) {
			if (now >= discountStructs[i].fromDate && now <= discountStructs[i].toDate) {

				if (discountStructs[i].distributedTokens >= discountStructs[i].availableTokens) {
					return;
				}

				for (uint j = 0; j < discountSteps[i].length; j++) {
					if (_purchasedValue >= discountSteps[i][j].fromWei
						&& (_purchasedValue < discountSteps[i][j].toWei || discountSteps[i][j].toWei == 0)) {
						uint256 bonus = _purchasedAmount.mul(discountSteps[i][j].percent).div(100);
						if (discountStructs[i].distributedTokens.add(bonus) > discountStructs[i].availableTokens) {
							return;
						}
						return bonus;
					}
				}

				return;
			}
		}
	}

	function addDiscountStruct(bytes32 _name, uint256 _tokens, uint[2] _dates, uint256[] _fromWei, uint256[] _toWei, uint256[] _percent) external onlyOwnerOrStaff {
		require(_name.length > 0);
		require(_tokens > 0);
		require(_dates[0] < _dates[1]);
		require(_fromWei.length > 0 && _fromWei.length == _toWei.length && _fromWei.length == _percent.length);

		for (uint j = 0; j < discountStructs.length; j++) {
			require(_dates[0] > discountStructs[j].toDate || _dates[1] < discountStructs[j].fromDate);
		}

		DiscountStruct memory ds = DiscountStruct(_tokens, 0, _dates[0], _dates[1]);
		uint index = discountStructs.push(ds) - 1;

		for (uint i = 0; i < _fromWei.length; i++) {
			require(_fromWei[i] > 0 || _toWei[i] > 0);
			if (_fromWei[i] > 0 && _toWei[i] > 0) {
				require(_fromWei[i] < _toWei[i]);
			}
			require(_percent[i] > 0 && _percent[i] <= 100);
			discountSteps[index].push(DiscountStep(_fromWei[i], _toWei[i], _percent[i]));
		}

		emit DiscountStructAdded(index, _name, _tokens, _dates, _fromWei, _toWei, _percent, now, msg.sender);
	}

	function removeDiscountStruct(uint _index) public onlyOwnerOrStaff {
		require(now < discountStructs[_index].toDate);
		delete discountStructs[_index];
		delete discountSteps[_index];
		emit DiscountStructRemoved(_index, now, msg.sender);
	}
}
