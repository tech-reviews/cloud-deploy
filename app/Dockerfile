# TODO: Create Dockerfile suitable for deployment to cloud provider

FROM node:latest

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080


CMD ["npm", "start"]