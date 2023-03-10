import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const lockedAmount = ethers.utils.parseEther("1");

  const ERC20 = await ethers.getContractFactory("ERC20");
  const myERC20Contract = await ERC20.deploy("Hi token", "HEL");

  await myERC20Contract.deployed();

  console.log(`myERC20Contract with 1 ETH and unlock timestamp ${unlockTime} deployed to ${myERC20Contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
