#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "Usage: ./demo-deploy.sh AWS_REGION"
  exit 1
fi

AWS_REGION=$1

# Define the stack name
STACK_NAME="demo-rekognition-lambda-stack"

# Build SAM application
sam build

# Deploy the SAM application
sam deploy --region $AWS_REGION

# Wait for the stack to be created
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $AWS_REGION

# Retrieve the bucket name
BUCKET_NAME=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionBucket'].OutputValue" --output text)
LAMBDA_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionFunction'].OutputValue" --output text)
LAMBDA_ROLE_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION --query "Stacks[0].Outputs[?OutputKey=='DemoRekognitionFunctionRole'].OutputValue" --output text)
IMAGE_KEY=images/random-image.png

sleep 5

echo "Updating lambda permissions"
aws lambda add-permission \
    --function-name $LAMBDA_ARN \
    --principal s3.amazonaws.com \
    --statement-id s3invoke \
    --action lambda:InvokeFunction \
    --source-arn arn:aws:s3:::$BUCKET_NAME \
    --region $AWS_REGION

sleep 5

echo "Managing notification.json"
rm -f notification.json
cp ./templates/notification.json notification.json
sed -i "s|REPLACE_WITH_LAMBDA_ARN|$LAMBDA_ARN|g" notification.json

echo "Updating the SAM template to add s3 Event notification"
aws s3api put-bucket-notification-configuration --region $AWS_REGION --bucket $BUCKET_NAME --notification-configuration file://notification.json

sleep 5

echo "Deleting notification.json"
rm -f notification.json

echo "Managing bucket-policy.json"
rm -f bucket-policy.json
cp ./templates/bucket-policy.json bucket-policy.json
sed -i "s|REPLACE_WITH_LAMBDA_FUNCTION_ROLE_ARN|$LAMBDA_ROLE_ARN|g" bucket-policy.json
sed -i "s|REPLACE_WITH_BUCKET_NAME|$BUCKET_NAME|g" bucket-policy.json

echo "Adding bucket policy"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

sleep 5

echo "Deleting bucket-policy.json"
rm -f bucket-policy.json

echo "Preparing event payload"
mkdir tests
cp ./templates/s3-putObject.json ./tests/s3-putObject.json
sed -i "s|REPLACE_WITH_BUCKET_NAME|$BUCKET_NAME|g" ./tests/s3-putObject.json
sed -i "s|REPLACE_WITH_IMAGE_KEY|$IMAGE_KEY|g" ./tests/s3-putObject.json

echo "Test uploading image"
aws s3api put-object --bucket $BUCKET_NAME --key $IMAGE_KEY --body ./images/element-1.PNG

sleep 5

echo "Test invocation"
aws lambda invoke --function-name $LAMBDA_ARN --cli-binary-format raw-in-base64-out --payload file://tests/s3-putObject.json --invocation-type Event --region $AWS_REGION response.json

echo "Cleaning up"
rm -rf tests response.json


