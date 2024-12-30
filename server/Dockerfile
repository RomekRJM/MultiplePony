FROM node:22.12-alpine3.21
WORKDIR /usr/src/app
COPY package.json .
RUN npm install
COPY . ./

EXPOSE 5000

CMD ["npm", "start"]