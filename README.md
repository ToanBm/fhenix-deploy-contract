# Deploy Contract on Fhenix Testnet
- Project twitter : [FhenixIO](https://x.com/FhenixIO)
- Follow me : [toanbm](https://x.com/buiminhtoan1985)
---
- Open [Codespace](https://github.com/codespaces) 
- Bridge $ETH from Sepolia to Helium Testnet: [Bridge](https://bridge.helium.fhenix.zone/)
- Enter the below command to start deployment
## 1. Clone Hardhat Template:
```Bash
git clone https://github.com/FhenixProtocol/fhenix-hardhat-example.git
cd fhenix-hardhat-example
pnpm install
```
```Bash
pnpm install @nomiclabs/hardhat-ethers

```
## 2. Configure the Helium Testnet:
### Config file:
```bash
rm hardhat.config.ts && nano hardhat.config.ts
```
Edit file `hardhat.config.ts` as in the code below. 
(Ctrl + X, Y and Enter will do to save)
```Bash
import { HardhatUserConfig } from "hardhat/config";
import { resolve } from "path";
import { config as dotenvConfig } from "dotenv";
import "hardhat-deploy"; // Import hardhat-deploy
import "@nomiclabs/hardhat-ethers"; // Import hardhat-ethers

dotenvConfig({ path: resolve(__dirname, "./.env") });

const TESTNET_CHAIN_ID = 8008135;
const TESTNET_RPC_URL = "https://api.helium.fhenix.zone";

const testnetConfig = {
    chainId: TESTNET_CHAIN_ID,
    url: TESTNET_RPC_URL,
    accounts: [process.env.KEY || ""],
};

const config: HardhatUserConfig = {
  solidity: "0.8.25",
  defaultNetwork: "hardhat",
  networks: {
    testnet: testnetConfig,
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
};

export default config;
```
### Deploy file:
```bash
rm deploy/deploy.ts && nano deploy/deploy.ts
```
Edit file `deploy.ts` as in the code below. 
(Ctrl + X, Y and Enter will do to save)
```Bash
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
```
## 3. Environment Variables:
```bash
nano .env
```
* Enter your private key where it says
```bash
KEY=your-private-key
```
## 4. Deploy Contract:
```Bash
npx hardhat deploy --network testnet
```
* Counter contract:  0x...
* Check in [Explorer](https://explorer.helium.fhenix.zone/)
## .......Thank you!..........

