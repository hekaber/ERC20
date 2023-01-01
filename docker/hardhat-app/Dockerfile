# syntax=docker/dockerfile:1

FROM node:18-alpine3.16
ENV NODE_ENV=production
WORKDIR /usr/src
COPY package.json .
COPY hardhat.config.js .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
RUN <<EOF
mkdir /logs
touch /logs/out.txt
npm install
npm install chai @nomiclabs/hardhat-ethers ethers @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-chai-matchers
EOF
ENTRYPOINT ["/usr/src/entrypoint.sh"]
