const truffleAssert = require('truffle-assertions');
const Commission = artifacts.require("./Commission.sol");
const Crowdsale = artifacts.require("./Crowdsale.sol");

const emptyAddr = "0x0000000000000000000000000000000000000000";

contract("Commission", accounts => {
    it("should set correct holdex wallet", () => Commission.deployed()
        .then(c => c.wallet())
        .then(wallet => assert.equal(wallet, process.env.HOLDEX_WALLET, "holdex wallet is not right")));

    it("should set correct owner", () => Commission.deployed()
        .then(c => c.owner())
        .then(owner => assert.equal(owner, accounts[0], "owner is not right")));

    describe("add customer", () => {
        it("should add if all data is correct", () => Commission.deployed()
            .then(c => c.addCustomer(Crowdsale.address, process.env.ETH_FUNDS_WALLET, 10))
            .then((result) => {
                truffleAssert.eventEmitted(result, 'CustomerAdded', (ev) => {
                    assert.equal(ev.customer, Crowdsale.address);
                    assert.equal(ev.wallet, process.env.ETH_FUNDS_WALLET);
                    assert.equal(ev.commission, 10);
                    return true;
                });
            }));
        it("should update if already exists", () => Commission.deployed()
            .then(c => c.addCustomer(Crowdsale.address, process.env.ETH_FUNDS_WALLET, 10))
            .then((result) => {
                truffleAssert.eventEmitted(result, 'CustomerUpdated', (ev) => {
                    assert.equal(ev.customer, Crowdsale.address);
                    assert.equal(ev.wallet, process.env.ETH_FUNDS_WALLET);
                    assert.equal(ev.commission, 10);
                    return true;
                });
            }));
        it("should fail if invalid customer", () => Commission.deployed()
            .then(async c => {
                try {
                    await c.addCustomer(emptyAddr, process.env.ETH_FUNDS_WALLET, 100);
                    assert(false, 'the contract should throw here')
                } catch (e) {
                    assert.equal(e.reason, 'missing customer address', "invalid reason");
                }
            }));
        it("should fail if invalid wallet", () => Commission.deployed()
            .then(async c => {
                try {
                    await c.addCustomer(Crowdsale.address, emptyAddr, 10);
                    assert(false, 'the contract should throw here')
                } catch (e) {
                    assert.equal(e.reason, 'missing wallet address', "invalid reason");
                }
            }));
        it("should fail if invalid percent", () => Commission.deployed()
            .then(async c => {
                try {
                    await c.addCustomer(Crowdsale.address, process.env.ETH_FUNDS_WALLET, 100);
                    assert(false, 'the contract should throw here')
                } catch (e) {
                    assert.equal(e.reason, 'invalid commission percent', "invalid reason");
                }
            }));
    });
});