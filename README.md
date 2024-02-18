# demo-lambda-rekognition
Demo of an AWS Lambda function that:
- receives an S3 event notification on object created event
- send the created object to Amazon Rekognition for label detection
- retrieves the results from Amazon Rekognition and publish them in an SNS topic

Here's the expected workflow:
![Alt text](/images/workflow.png?raw=true "Architecture workflow")

# Getting started

## What you'll need

* AWS SAM CLI
* AWS CLI
* Docker (to perform local testing with SAM CLI)
* npm
* Rekognition service regional availability (as of January 2024)
    * Asia Pacific (Mumbai)
    * Europe (London)
    * Europe (Ireland)
    * Asia Pacific (Seoul)
    * Asia Pacific (Tokyo)
    * Israel (Tel Aviv)
    * Canada (Central)
    * Asia Pacific (Singapore)
    * Asia Pacific (Sydney)
    * Europe (Frankfurt)
    * US East (N. Virginia)
    * US East (Ohio)
    * US West (N. California)
    * US West (Oregon)

    
All provided scripts were tested under Amazon Linux 2.

You'll need to make them executable.

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

This script will create:
* An S3 bucket
* A prefix (folder) "images/" where images are to be uploaded
* A Lambda function that can process an S3 event notification and send data to Rekognition
* An S3 event notification on objects created with the previous Lambda as target
* An SNS topic, with an subscription on endpoint demo.lambda.rekognition@mailinator.com (go to mailinator.com public inbox to validate the subscription)


## Test in AWS

* Upload an image file inside the folder (prefix) images/ from the S3 bucket. There are some sample images files in project images folder.
* Check the function logs on CloudWatch Logs to verify it has been called
* Check you received a result: 
	* message sent in an SQS queue
	* email (at demo.lambda.rekognition@mailinator.com or any other email that you would have subscribed beforehand to the SNS topic)


## Checkout the AWS X-Ray Trace map

* Go to CloudWatch
* On the left menu expand X-Ray Traces, and click on Trace Map
* Observe the application architecture

![Alt text](/images/xray-map.png?raw=true "X-Ray Map")

## Cleanup the application in AWS

Run the script:

```bash
./demo-cleanup.sh AWS_REGION
```
