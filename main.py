import json
import boto3
from io import StringIO
import csv
import urllib.parse

def lambda_handler(event, context):
    # TODO implement
    s3 = boto3.client('s3')
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    response = s3.get_object(Bucket=bucket, Key=key)
    file_content = response['Body'].read().decode('utf-8')
    json_content = json.loads(file_content) # Create CSV content
    output = StringIO()
    csv_writer = csv.DictWriter(output, fieldnames=json_content.keys())
    csv_writer.writeheader()
    csv_writer.writerow(json_content)

    # Generate the CSV key
    csv_key = key.rsplit('.', 1)[0] + '.csv'

    # Save the CSV file to S3
    s3.put_object(Body=output.getvalue(), Bucket=bucket, Key=csv_key)

    return {
        'statusCode': 200,
        'body': json.dumps(f'CSV saved to {csv_key} in bucket {bucket}')
    }
