#Stage-1
#Pull the base image for frontend
FROM node:14 AS frontend-builder

#Set metedata for image.
LABEL maintainer="Rahul Nimbalkar"
LABEL description="To serve the frontend of the application"

#Set working directory in container.
WORKDIR /app

#Copy the package.json & package.lock.json into container directory.
COPY package*.json ./

#Instll nodejs dependanciesss.
RUN npm install

#Copy the complete frontend to container directory.
COPY . . 

#Stage-2
#Pull the base image for frontend
FROM node:14-slim

#Set working directory in container.
WORKDIR /app

#Copy the complete frontend to container directory.
COPY --from=frontend-builder /app .

#Expose port on backend container.
EXPOSE 3000

#To run the frontend application.
CMD ["npm","start"]