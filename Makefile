flatten:
	truffle-flattener --output flattened/Crowdsale.sol contracts/Crowdsale.sol
	truffle-flattener --output flattened/Commission.sol contracts/Commission.sol
	truffle-flattener --output flattened/DiscountPhases.sol contracts/DiscountPhases.sol
	truffle-flattener --output flattened/DiscountStructs.sol contracts/DiscountStructs.sol
	truffle-flattener --output flattened/PromoCodes.sol contracts/PromoCodes.sol
	truffle-flattener --output flattened/Staff.sol contracts/Staff.sol