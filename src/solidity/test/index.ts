import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20 } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";


describe("ERC20Contract", function () {
  let myERC20Contract: ERC20;
  let someAddress: SignerWithAddress;
  let someOtherAddress: SignerWithAddress;

  beforeEach(async function() {
    const ERC20ContractFactory = await ethers.getContractFactory("ERC20");
    myERC20Contract = await ERC20ContractFactory.deploy("Hello", "SYM");
    await myERC20Contract.deployed();

    someAddress = (await ethers.getSigners())[1];
    someOtherAddress = (await ethers.getSigners())[2];
  });

  describe("When I have 10 tokens", function() {
    // mint 10 tokens
    beforeEach(async function () {
      await myERC20Contract.transfer(someAddress.address, 10);
    });

    describe("When I transfer 10 tokens", function () {
      it("should transfer tokens correctly", async function () {
        await myERC20Contract
        .connect(someAddress)
        .transfer(someOtherAddress.address, 10);

        expect(
          await myERC20Contract.balanceOf(someOtherAddress.address)
        ).to.equal(10);
      });
    });

    describe("When I transfer 15 tokens", function () {
      it("should revert the transaction", async function () {
        await expect(myERC20Contract
          .connect(someAddress)
          .transfer(someOtherAddress.address, 15)
        ).to.be.revertedWith("ERC20: Transfert amount exceeds balance");
      });
    });

    describe("When I deposit 15 tokens", function() {
      it("should deposit 15 tokens in sender's wallet", async () => {

        let oldBalance = await myERC20Contract.balanceOf(someAddress.address);
        await myERC20Contract.connect(someAddress).deposit({value: 15});

        expect(
          await myERC20Contract.balanceOf(someAddress.address)
        ).to.equal(+oldBalance + 15);
      })
    });

    describe("When I redeem 5 tokens", function() {
      it("should remove 5 tokens from sender's wallet", async () => {

        await expect(myERC20Contract
          .connect(someAddress)
          .redeem({value: 15})
        ).to.be.reverted;

        let oldBalance = await myERC20Contract.balanceOf(someAddress.address);
        expect(oldBalance).to.greaterThanOrEqual(5)
        await myERC20Contract.connect(someAddress).redeem({value: 5});

        expect(
          await myERC20Contract.balanceOf(someAddress.address)
        ).to.equal(+oldBalance - 5);
      });
    });
  });
});
