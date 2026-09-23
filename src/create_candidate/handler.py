import base64
import binascii
import json
import os
import secrets

import boto3
from botocore.exceptions import ClientError

# Clients are created once per container and reused across invocations.
s3_client = boto3.client("s3")
table = boto3.resource("dynamodb").Table(os.environ["DYNAMODB_TABLE_NAME"])
BUCKET_NAME = os.environ["S3_BUCKET_NAME"]

REQUIRED_FIELDS = ["specialty", "firstName", "lastName", "birthDate", "fileContent", "fileExtension"]
MAX_ID_ATTEMPTS = 3
# Lambda sync payload limit is 6 MB and base64 adds ~33%, so decoded files are capped at 4.5 MB.
MAX_FILE_SIZE_BYTES = 4_500_000


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    # Parse the JSON body (HTTP API may base64-encode it depending on the content type).
    raw_body = event.get("body")
    if not raw_body:
        return _response(400, {"message": "Request body is required."})
    if event.get("isBase64Encoded"):
        raw_body = base64.b64decode(raw_body)
    try:
        body = json.loads(raw_body)
    except json.JSONDecodeError:
        return _response(400, {"message": "Request body must be valid JSON."})

    missing = [field for field in REQUIRED_FIELDS if not body.get(field)]
    if missing:
        return _response(400, {"message": f"Missing required fields: {', '.join(missing)}"})

    try:
        file_bytes = base64.b64decode(body["fileContent"], validate=True)
    except (binascii.Error, ValueError):
        return _response(400, {"message": "fileContent must be valid base64."})

    if len(file_bytes) > MAX_FILE_SIZE_BYTES:
        return _response(400, {"message": "CV file exceeds the maximum allowed size of 4.5MB."})

    # Reserve a random 6-digit ID in DynamoDB first: the conditional write fails on
    # collision, before the CV upload could overwrite another candidate's object.
    for _ in range(MAX_ID_ATTEMPTS):
        candidate_id = f"CA-{secrets.randbelow(1_000_000):06d}"
        cv_s3_key = f"{body['specialty']}/{candidate_id}.{body['fileExtension']}"
        try:
            table.put_item(
                Item={
                    "candidateId": candidate_id,
                    "specialty": body["specialty"],
                    "candidateFirstName": body["firstName"],
                    "candidateLastName": body["lastName"],
                    "candidateBirthDate": body["birthDate"],
                    "cvS3Key": cv_s3_key,
                },
                ConditionExpression="attribute_not_exists(candidateId)",
            )
            break
        except ClientError as error:
            if error.response["Error"]["Code"] != "ConditionalCheckFailedException":
                raise
    else:
        return _response(500, {"message": "Could not generate a unique candidateId, please retry."})

    s3_client.put_object(Bucket=BUCKET_NAME, Key=cv_s3_key, Body=file_bytes)

    return _response(201, {"candidateId": candidate_id, "cvS3Key": cv_s3_key})
