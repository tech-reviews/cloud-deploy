#!/usr/bin/env bash

# TODO: Write script to build a docker image and deploy it to cloud provider 
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 436600111889.dkr.ecr.us-east-1.amazonaws.com

docker build -t tr-cloud-deploy .
docker tag tr-cloud-deploy:latest 436600111889.dkr.ecr.us-east-1.amazonaws.com/tr-cloud-deploy:latest

docker push 436600111889.dkr.ecr.us-east-1.amazonaws.com/tr-cloud-deploy:latest

aws ecs update-service --cluster tr-cloud-cluster --service tr-cloud-service --force-new-deployment