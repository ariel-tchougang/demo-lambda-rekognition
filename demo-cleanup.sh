#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "Usage: ./demo-cleanup.sh AWS_REGION"
  exit 1
fi

AWS_REGION=$1

echo "Define the stack name"
lambda_stack_name="demo-rekognition-lambda-stack"

echo "Retrieve the bucket name"
bucket_name=$(aws cloudformation describe-stacks --stack-name $lambda_stack_name --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionBucketName'].OutputValue" --output text)

echo "Empty the S3 bucket"
aws s3 rm s3://$bucket_name --recursive --region $AWS_REGION

echo "Delete the Lambda stack"
sam delete --stack-name $lambda_stack_name --no-prompts --region $AWS_REGION

echo "Cleaning up build files"
rm -rf .aws-sam

