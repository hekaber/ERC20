# syntax=docker/dockerfile:1

FROM node:18-alpine3.16
WORKDIR /usr/src/app
COPY package.json vite.config.js ./
COPY app/ .
RUN npm install
EXPOSE 8080
CMD ["npm", "start"]