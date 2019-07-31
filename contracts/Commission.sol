pragma solidity ^0.4.24;


import "./StaffUtil.sol";
import "./Staff.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract Commission is StaffUtil {
	using SafeMath for uint256;

	address public crowdsale;
	address public ethFundsWallet;
	address[] public txFeeAddresses;
	uint256[] public txFeeNumerator;
	uint256 public txFeeDenominator;
	uint256 public txFeeCapInWei;
	uint256 public txFeeSentInWei;

	constructor(
		Staff _staffContract,
		address _ethFundsWallet,
		address[] _txFeeAddresses,
		uint256[] _txFeeNumerator,
		uint256 _txFeeDenominator,
		uint256 _txFeeCapInWei
	) StaffUtil(_staffContract) public {
		require(_ethFundsWallet != address(0));
		require(_txFeeAddresses.length == _txFeeNumerator.length);
		require(_txFeeAddresses.length == 0 || _txFeeDenominator > 0);
		uint256 totalFeesNumerator;
		for (uint i = 0; i < txFeeAddresses.length; i++) {
			require(txFeeAddresses[i] != address(0));
			require(_txFeeNumerator[i] > 0);
			require(_txFeeDenominator > _txFeeNumerator[i]);
			totalFeesNumerator = totalFeesNumerator.add(_txFeeNumerator[i]);
		}
		require(_txFeeDenominator == 0 || totalFeesNumerator < _txFeeDenominator);

		ethFundsWallet = _ethFundsWallet;
		txFeeAddresses = _txFeeAddresses;
		txFeeNumerator = _txFeeNumerator;
		txFeeDenominator = _txFeeDenominator;
		txFeeCapInWei = _txFeeCapInWei;
	}

	function() public payable {
		require(msg.sender == crowdsale);

		uint256 fundsToTransfer = msg.value;

		if (txFeeCapInWei > 0 && txFeeSentInWei < txFeeCapInWei) {
			for (uint i = 0; i < txFeeAddresses.length; i++) {
				uint256 txFeeToSendInWei = msg.value.mul(txFeeNumerator[i]).div(txFeeDenominator);
				if (txFeeToSendInWei > 0) {
					txFeeSentInWei = txFeeSentInWei.add(txFeeToSendInWei);
					fundsToTransfer = fundsToTransfer.sub(txFeeToSendInWei);
					txFeeAddresses[i].transfer(txFeeToSendInWei);
				}
			}
		}

		ethFundsWallet.transfer(fundsToTransfer);
	}

	function setCrowdsale(address _crowdsale) external onlyOwner {
		require(_crowdsale != address(0));
		require(crowdsale == address(0));
		crowdsale = _crowdsale;
	}
}
