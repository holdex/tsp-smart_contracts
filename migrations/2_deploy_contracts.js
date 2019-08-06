const BigNumber = require('bignumber.js');
const Staff = artifacts.require("./Staff.sol");
const Crowdsale = artifacts.require("./Crowdsale.sol");
const PromoCodes = artifacts.require("./PromoCodes.sol");
const DiscountPhases = artifacts.require("./DiscountPhases.sol");
const DiscountStructs = artifacts.require("./DiscountStructs.sol");

module.exports = function (deployer) {
    deployer
        .deploy(Staff)
        .then(() => deployer.deploy(DiscountPhases, Staff.address))
        .then(() => deployer.deploy(DiscountStructs, Staff.address))
        .then(() => deployer.deploy(PromoCodes, Staff.address))
        .then(() => deployer.deploy(Crowdsale,
            [
                new BigNumber(process.env.START_DATE),
                new BigNumber(process.env.CROWDSALE_START_DATE),
                new BigNumber(process.env.END_DATE),
                new BigNumber(process.env.TOKEN_DECIMALS),
                new BigNumber(process.env.TOKEN_RATE),
                new BigNumber(process.env.TOKENS_FOR_SALE_CAP).multipliedBy(10 ** parseInt(process.env.TOKEN_DECIMALS)).toFixed(),
                web3.utils.toWei(process.env.MIN_PURCHASE_IN_ETH, 'ether'),
                web3.utils.toWei(process.env.MAX_INVESTOR_CONTRIBUTION_IN_ETH, 'ether'),
                new BigNumber(process.env.PURCHASED_TOKENS_CLAIM_DATE),
                new BigNumber(process.env.BONUS_TOKENS_CLAIM_DATE),
                new BigNumber(process.env.REFERRAL_BONUS_PERCENT)
            ],
            process.env.COMMISSION_SC,
            [
                PromoCodes.address,
                DiscountPhases.address,
                DiscountStructs.address,
                Staff.address
            ]))
        .then(() => PromoCodes.deployed())
        .then(p => {
            console.log("PromoCodes.setCrowdsale");
            return p.setCrowdsale(Crowdsale.address)
        })
        .then(() => DiscountStructs.deployed())
        .then(d => {
            console.log("DiscountStructs.setCrowdsale");
            return d.setCrowdsale(Crowdsale.address)
        })
        .then(() => DiscountPhases.deployed())
        .then(d => {
            console.log("DiscountPhases.setCrowdsale");
            return d.setCrowdsale(Crowdsale.address)
        })
        .then(() => Staff.deployed())
        .then(s => {
            const staff = process.env.STAFF_ADDR;
            if (staff && staff.length > 0) {
                console.log("Add staff", staff);
                return s.addStaff(staff);
            }
            console.log("Skip staff");
        })
        .then(() => Staff.deployed())
        .then(s => {
            const owner = process.env.OWNER_ADDR;
            if (owner && owner.length > 0) {
                console.log("Transfer ownership", owner);
                return s.transferOwnership(owner);
            }
            console.log("Skip transfer ownership");
        })
        .then(() => {
            console.log("===============================================================");
            console.log("CROWDSALE_CONTRACT_ADDRESS=" + Crowdsale.address);
            console.log("PROMO_CODES_CONTRACT_ADDRESS=" + PromoCodes.address);
            console.log("DISCOUNT_PHASES_CONTRACT_ADDRESS=" + DiscountPhases.address);
            console.log("DISCOUNT_STRUCTS_CONTRACT_ADDRESS=" + DiscountStructs.address);
            console.log("===============================================================");
        })
        .catch((e) => console.log("error:", e));
};
