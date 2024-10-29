
FROM node:16-alpine  


WORKDIR /app



RUN npm install  


EXPOSE 3000


CMD ["npm", "start"]  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wisecow
  labels:
    app: wisecow
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wisecow
  template:
    metadata:
      labels:
        app: wisecow
    spec:
      containers:
        - name: wisecow
          image: wisecow:latest  
          ports:
            - containerPort: 3000  
          env:
            - name: NODE_ENV
              value: "production"  
              apiVersion: v1
kind: Service
metadata:
  name: wisecow-service
spec:
  type: LoadBalancer  
  ports:
    - port: 80
      targetPort: 3000
  selector:
    app: wisecow
name: Build and Push Docker Image

on:
  push:
    branches:
      - main 

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build Docker image
        run: docker build -t wisecow:latest .

      - name: Push Docker image
        run: docker push wisecow:latest  

      - name: Deploy to Kubernetes (optional)
        run: |
          kubectl apply -f wisecow-deployment.yaml
          kubectl apply -f wisecow-service.yaml
          apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: wisecow-tls
    solvers:
      - http01:
          ingress:
            class: nginx
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wisecow-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  rules:
    - host: wisecow.example.com  # Replace with your domain
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: wisecow-service
                port:
                  number: 80
  tls:
    - hosts:
        - wisecow.example.com
      secretName: wisecow-tls

FROM node:16-alpine


WORKDIR /app

# Step 4: Install dependencies
RUN npm install


CMD ["npm", "start"]

# Use the Node.js LTS version as a base image
FROM node:16-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

RUN npm install




EXPOSE 3000


CMD ["npm", "start"]
docker build -t wisecow:latest .
docker run -p 3000:3000 wisecow:latest
http://localhost:3000








