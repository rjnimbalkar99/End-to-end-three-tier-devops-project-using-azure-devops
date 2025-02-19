#Stage-1
#Pull the base image for backend
FROM node:14 AS backend-builder

#Set metedata for image.
LABEL maintainer="Rahul Nimbalkar"
LABEL description="To serve the backend of the application"

#Set working directory in container.
WORKDIR /app

#Copy the package.json & package.lock.json into container directory.
COPY package*.json ./

#Instll nodejs dependanciesss.
RUN npm install

#Copy the complete backend to container directory.
COPY . . 

#Stage-2
#Pull the base image for backend
FROM node:14-slim

#Set working directory in container.
WORKDIR /app

#Copy the complete backend to container directory.
COPY --from=backend-builder /app .

#Expose port on backend container.
EXPOSE 3500

#To run the backend application.
CMD ["node","index.js"]