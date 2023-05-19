# demo-lambda-rekognition
Demo of an AWS Lambda function that:
- receives an S3 event notification on object created event
- send the created object to Amazon Rekognition for label detection
- retrieves the results from Amazon Rekognition and publish them in an SNS topic


# Getting started

## What you need

* AWS SAM CLI
* AWS CLI
* npm
 
All provided scripts were tested under Amazon Linux 2.

You'll need to mak ethem executable.


```bash
chmod 755 *.sh
```

## Test the application locally

Run the script:

```bash
./demo-local-test.sh BUCKET_NAME IMAGE_KEY SNS_TOPIC_ARN
```

The aws profile used to run the test command must have permission to access the provided parameters:
* BUCKET_NAME (must exists)
* IMAGE_KEY (image file, must exists )
* SNS_TOPIC_ARN (make sure to have an email subscription to the given topic)

Once the execution is done, go to the email address with a subscription to SNS_TOPIC_ARN, and assert receiving the rekognition process results.


## Deploy the application in AWS

Run the script:

```bash
./demo-deploy.sh AWS_REGION
```

## Cleanup the application in AWS

Run the script:

```bash
./demo-cleanup.sh AWS_REGION
```
