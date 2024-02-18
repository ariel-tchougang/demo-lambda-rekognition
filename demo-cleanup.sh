#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "Usage: ./demo-cleanup.sh AWS_REGION"
  exit 1
fi

AWS_REGION=$1

echo "Define the stack name"
STACK_NAME="demo-rekognition-lambda-stack"

echo "Retrieve the bucket name"
BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionBucket'].OutputValue" --output text)

echo "Empty the S3 bucket"
aws s3 rm s3://$BUCKET_NAME --recursive --region $AWS_REGION

echo "Delete the Lambda stack"
sam delete --stack-name $STACK_NAME --no-prompts --region $AWS_REGION

echo "Cleaning up build files"
rm -rf .aws-sam

