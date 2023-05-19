#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "Usage: ./demo-deploy.sh AWS_REGION"
  exit 1
fi

AWS_REGION=$1

# Define the stack name
demo_stack_name="demo-rekognition-lambda-stack"

# Build SAM application
sam build

# Deploy the SAM application
sam deploy --region $AWS_REGION

# Wait for the stack to be created
aws cloudformation wait stack-create-complete --stack-name $demo_stack_name --region $AWS_REGION

# Retrieve the bucket name
bucket_name=$(aws cloudformation describe-stacks --stack-name $demo_stack_name --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionBucketName'].OutputValue" --output text)
lambda_arn=$(aws cloudformation describe-stacks --stack-name $demo_stack_name --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionFunction'].OutputValue" --output text)

echo "Creating images folder"
aws s3api put-object --bucket $bucket_name --key images/

echo "Managing notification.json"
rm -f notification.json
cp ./templates/notification.json notification.json
sed -i "s|REPLACE_WITH_LAMBDA_ARN|$lambda_arn|g" notification.json

echo "Updating lambda permissions"
aws lambda add-permission \
    --function-name $lambda_arn \
    --principal s3.amazonaws.com \
    --statement-id s3invoke \
    --action lambda:InvokeFunction \
    --source-arn arn:aws:s3:::$bucket_name \
    --region $AWS_REGION

echo "Updating the SAM template to add s3 Event notification"
aws s3api put-bucket-notification-configuration --region $AWS_REGION --bucket $bucket_name --notification-configuration file://notification.json
