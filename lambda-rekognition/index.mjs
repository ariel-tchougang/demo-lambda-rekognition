import AWSXRay from 'aws-xray-sdk-core';
import { Rekognition } from "@aws-sdk/client-rekognition";
import { SNS } from "@aws-sdk/client-sns";

export const handler = async (event) => {
    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
    
    console.log('bucket: ' + bucket);
    console.log('key: ' + key);

    try {
        
        let rekognition;
        let sns;
        
        if (process.env.AWS_SAM_LOCAL) {
            // Disable X-Ray tracing for sam local testing
            rekognition = new Rekognition();
            sns = new SNS();
        } else {
            rekognition = AWSXRay.captureAWSv3Client(new Rekognition());
            sns = AWSXRay.captureAWSv3Client(new SNS());
        }

        const params = {
            Image: {
                S3Object: {
                    Bucket: bucket,
                    Name: key
                }
            },
            MaxLabels: 5
        };

        const response = await rekognition.detectLabels(params);
        console.log(response);

        const formattedResults = response.Labels.map(label => ({
            name: label.Name,
            confidence: label.Confidence
        }));

        const publishParams = {
            Message: JSON.stringify(formattedResults),
            TopicArn: process.env.SNS_TOPIC
        };

        await sns.publish(publishParams);

    } catch (error) {
        console.error(error);
        throw new Error(error);
    }
};
