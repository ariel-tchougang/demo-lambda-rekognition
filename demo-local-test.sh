#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Error: This script requires exactly 3 arguments."
  echo "Usage: ./demo-local-test.sh BUCKET_NAME IMAGE_KEY SNS_TOPIC_ARN"
  exit 1
fi

BUCKET_NAME=$1
IMAGE_KEY=$2
SNS_TOPIC_ARN=$3

echo "Performing sam build"
sam build

echo "Preparing event payload"
mkdir tests
cp ./templates/s3-putObject.json ./tests/s3-putObject.json
sed -i "s|REPLACE_WITH_BUCKET_NAME|$BUCKET_NAME|g" ./tests/s3-putObject.json
sed -i "s|REPLACE_WITH_IMAGE_KEY|$IMAGE_KEY|g" ./tests/s3-putObject.json

echo "Preparing env var"
cp ./templates/env.json ./tests/env.json
sed -i "s|REPLACE_WITH_SNS_TOPIC_ARN|$SNS_TOPIC_ARN|g" ./tests/env.json


echo "Building sam application"
sam build

echo "Local testing"
sam local invoke -e ./tests/s3-putObject.json --env-vars ./tests/env.json DemoRekognitionFunction

echo "Cleaning up"
rm -rf tests

