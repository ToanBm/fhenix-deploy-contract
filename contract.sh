#!/bin/bash
# Logo
curl -s https://raw.githubusercontent.com/ToanBm/user-info/main/logo.sh | bash
sleep 3

show() {
    echo -e "\033[1;35m$1\033[0m"
}

# Step 1. Clone Hardhat Template
git clone https://github.com/FhenixProtocol/fhenix-hardhat-example.git && cd fhenix-hardhat-example

pnpm install
pnpm install @nomiclabs/hardhat-ethers
npm install ethers@^6.1.0


# Step 2: Configure the Helium Testnet
echo "Creating new hardhat.config file..."
rm hardhat.config.js
rm hardhat.config.ts

cat <<EOL > hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";
import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";
import "hardhat-deploy"; // Import hardhat-deploy
import "@nomiclabs/hardhat-ethers"; // Import hardhat-ethers

dotenvConfig({ path: resolve(__dirname, "./.env") });

const TESTNET_CHAIN_ID = 8008148;
const TESTNET_RPC_URL = "https://api.nitrogen.fhenix.zone";

// Ensure PRIVATE_KEY is set in the .env file
if (!process.env.PRIVATE_KEY || process.env.PRIVATE_KEY.trim() === "") {
  throw new Error("PRIVATE_KEY is missing in the .env file.");
}

const testnetConfig = {
  chainId: TESTNET_CHAIN_ID,
  url: TESTNET_RPC_URL,
  accounts: [`0x${process.env.PRIVATE_KEY}`],
};

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.25",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337, // Use Hardhat's default chainId for local development
    },
    testnet: testnetConfig,
  },
  namedAccounts: {
    deployer: {
      default: 0, // Use the first account for deployments
    },
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
};

export default config;
EOL

# Step 3: Create deploy script
echo "Creating deploy script..."
rm deploy/deploy.ts

cat <<'EOL' > deploy/deploy.ts
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import chalk from "chalk";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { fhenixjs, ethers } = hre;
  const { deploy } = hre.deployments;
  const [signer] = await ethers.getSigners();

  if ((await ethers.provider.getBalance(signer.address)).toString() === "0") {
    if (hre.network.name === "localfhenix") {
      await fhenixjs.getFunds(signer.address);
    } else {
        console.log(
            chalk.red("Please fund your account with testnet FHE from https://faucet.fhenix.zone"));
        return;
    }
  }

  const counter = await deploy("Counter", {
    from: signer.address,
    args: [],
    log: true,
    skipIfAlreadyDeployed: false,
  });

  console.log(`Counter contract: `, counter.address);
};

export default func;
func.id = "deploy_counter";
func.tags = ["Counter"];
EOL

# Step 4: Create Environment Variables
echo "Create .env file..."

read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY
cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF

# "Waiting before deploying..."
sleep 5
cd fhenix-hardhat-example

# Step 5: Deploy the contract to the Hemi network
echo "Deploy your contracts..."
npx hardhat deploy --network testnet

echo "Thank you!"
