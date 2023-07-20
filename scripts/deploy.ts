import { ethers } from "hardhat";

async function main() {
  const voteContract = await ethers.getContractFactory("Vote");
  const vote = await voteContract.deploy();
  await vote.waitForDeployment();
  const address = await vote.getAddress();
  console.log("address", address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
