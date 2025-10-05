// deploy/01_deploy_fheauction.js
const { HardhatRuntimeEnvironment } = require("hardhat/types");
const { DeployFunction } = require("hardhat-deploy/types");

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  // Deploy FHEAuction với minDeposit = 0.01 ETH, duration = 1 giờ (3600 giây)
  const minDepositWei = hre.ethers.parseEther("0.01");
  const durationSeconds = 3600;

  await deploy("FHEAuction", {
    from: deployer,
    args: [durationSeconds, minDepositWei],
    log: true,
    autoMine: true, // Tự động mine tx cho test
  });
};

export default func;
func.tags = ["FHEAuction"];