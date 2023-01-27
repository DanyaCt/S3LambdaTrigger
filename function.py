import json

def lambda_handler(event, context):
    for i in event['Records']:
        print(i['s3']['object']['key'])
