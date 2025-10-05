// scripts/deploy.js
// Full deployment script for FHEAuction contract using Hardhat
// Deploy to Sepolia testnet (or local/hardhat network)
// Requirements: Run 'npx hardhat compile' first
// Set MNEMONIC and INFURA_API_KEY in .env or hardhat vars

const { ethers } = require("hardhat");

async function main() {
  // Get network name for logging
  const network = hre.network.name;
  console.log(`\n🚀 Deploying FHEAuction to ${network} network...`);

  // Load contract factory
  const FHEAuction = await ethers.getContractFactory("FHEAuction");

  // Deploy arguments (example: 1 hour duration, 0.1 ETH min deposit)
  const durationInSeconds = 3600;  // 1 hour
  const minDeposit = ethers.parseEther("0.1");  // 0.1 ETH

  console.log("📝 Deploying with params:");
  console.log(`   - Duration: ${durationInSeconds} seconds`);
  console.log(`   - Min Deposit: ${ethers.formatEther(minDeposit)} ETH`);

  // Deploy the contract
  const auction = await FHEAuction.deploy(durationInSeconds, minDeposit);
  await auction.waitForDeployment();

  const auctionAddress = await auction.getAddress();
  console.log(`✅ FHEAuction deployed to: ${auctionAddress}`);

  // Log additional info for verification
  console.log(`\n🔍 Verify on Etherscan:`);
  if (network === "sepolia") {
    console.log(`   https://sepolia.etherscan.io/address/${auctionAddress}`);
  } else if (network === "mainnet") {
    console.log(`   https://etherscan.io/address/${auctionAddress}`);
  }

  // Optional: Save address to file for frontend
  const fs = require("fs");
  const deployInfo = {
    network: network,
    contractAddress: auctionAddress,
    constructorArgs: [durationInSeconds, minDeposit.toString()],
    deployTx: auction.deploymentTransaction().hash,
    timestamp: new Date().toISOString(),
  };
  fs.writeFileSync("./deployments/deploy-info.json", JSON.stringify(deployInfo, null, 2));
  console.log("💾 Deployment info saved to deployments/deploy-info.json");

  return auctionAddress;
}

// Handle errors
main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });