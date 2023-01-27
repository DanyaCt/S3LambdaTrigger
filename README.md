# Creating Lambda function trigger and CloudWatch alarm
## Task
Set up monitoring for lambda function. Create a custom metric and alarm for it.
- create S3 bucket
- create lambda
- create event notification, that will trigger our lambda from 2d step on s3:ObjectCreated:* type
- create a custom metric, which will count words ERROR, Error, error in logs
- create an alarm based on that metric (threshold > 0). 

Flow is the following: you're uploading random files to your S3 bucket, and lambda just prints the names of uploaded files. Each time, when you're uploading the file, which name includes 'error', 'Error' or 'ERROR', your custom metric should reflect it in the graphs (simple count) and trigger the alarm

## How to run
Clone repository to your computer
```
git clone https://github.com/DanyaCt/S3LambdaTrigger.git
```
Also you need to download Terraform and AWS CLI, you can use these links:

>Terraform: https://developer.hashicorp.com/terraform/downloads
>
>AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Next you must login to your account in AWS, guide for this:
>https://docs.aws.amazon.com/cli/latest/reference/configure/

Run these commands:
```
terraform init
terraform apply -auto-approve
```
Now you can upload some files that contain "Error", "error" or "ERROR" in their name to S3 bucket and CloudWatch alarm will be triggered
