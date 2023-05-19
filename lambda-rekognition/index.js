const AWS = require('aws-sdk');

exports.handler = async (event) => {
    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));

    try {
        const rekognition = new AWS.Rekognition();
        const sns = new AWS.SNS();

        const params = {
            Image: {
                S3Object: {
                    Bucket: bucket,
                    Name: key
                }
            },
            MaxLabels: 10
        };

        const response = await rekognition.detectLabels(params).promise();
        console.log(response);

        const formattedResults = response.Labels.map(label => ({
            name: label.Name,
            confidence: label.Confidence
        }));

        const publishParams = {
            Message: JSON.stringify(formattedResults),
            TopicArn: process.env.SNS_TOPIC
        };

        await sns.publish(publishParams).promise();

    } catch (error) {
        console.error(error);
        throw new Error(error);
    }
};
