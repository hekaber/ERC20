import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-solhint";
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname + '/config/env/.env' });

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  networks: {
    goerli: {
      url: process.env.GOERLI_URL,
      accounts: [process.env.GOERLI_ACCOUNT_KEY ?? ""]
    },
  }
};

export default config;
