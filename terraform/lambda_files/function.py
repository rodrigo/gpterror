import json
import urllib.parse
import boto3
import os
# print('Loading function')

s3 = boto3.client('s3')



def lambda_handler(event, context):
    s3_objects = s3.list_objects(Bucket='rebelatto', Prefix='gpterror/stories')['Contents']
    file_name = s3_objects[0]['Key']
    file_content = s3.get_object(Bucket='rebelatto', Key=file_name)['Body'].read().decode('utf-8')
    boto3.client('cloudwatch').put_metric_data(Namespace='gpterror', MetricData=[{'MetricName': 's3-objects-count','Value': len(s3_objects), 'Unit': 'Count'}])


    s3.delete_object(Bucket='rebelatto', Key=file_name)
    return {
        'statusCode': 200,
        'headers':{'Content-Type': 'text/html; charset=utf-8'},
        'body': f"<!DOCTYPE html><html></head><title>gpterror</title></head><body>{file_content}</body></html>"
    }
