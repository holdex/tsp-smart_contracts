flatten:
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/Crowdsale.sol contracts/Crowdsale.sol
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/Commission.sol contracts/Commission.sol
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/DiscountPhases.sol contracts/DiscountPhases.sol
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/DiscountStructs.sol contracts/DiscountStructs.sol
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/PromoCodes.sol contracts/PromoCodes.sol
	solidity_flattener --solc-paths="zeppelin-solidity/=$(CURDIR)/node_modules/zeppelin-solidity/" --output flattened/Staff.sol contracts/Staff.sol