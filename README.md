# Sample Hardhat Project with its webapp

## Basis:

[https://buildspace.so/p/build-solidity-web3-app](https://buildspace.so/p/build-solidity-web3-app)

## Description

This project demonstrates a basic Hardhat use case.
It comes with a sample contract, a test for that contract, and a script that deploys that contract.

## How it works

Please check the .env.sample files in each application, copy it to a .env file and fill it out with the correct info.
Check the server.sh file (do not forget to chmod +x it), it will give you some details about the running but basically:

```shell
./server.sh -s
```

starts all the containers

```shell
./server.sh -n
```

stops them

In case you have some persisting images simply run the following command to delete those

```shell
./server.sh -k <image name>
```

The docker-hardhat image provides a local ETH networking, it starts automatically with the -s option, you can deploy your deploy.js script to it using --network docker or simply deploy to your favorite network.
Reminder:

```shell
npx hardhat run scripts/deploy.js --network <my_eth_network>
```

And of course more details with:
```shell
./server.sh -h
```
## More

You still can try running some of the following tasks in your local environment:

```shell
cd src/
npx hardhat help
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```