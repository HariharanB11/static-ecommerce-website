#!/bin/bash
REGION=$1
ACCOUNT_ID=$2
REPO=$3
TAG=$4
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
docker pull ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}
docker rm -f static-ecom || true
docker run -d --name static-ecom -p 80:80 ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}
