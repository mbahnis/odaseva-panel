import json
import os

import boto3
from botocore.config import Config

# Clients are created once per container and reused across invocations.
# Virtual addressing makes presigned URLs use the regional host matching the signature region.
s3_client = boto3.client(
    "s3",
    region_name=os.environ["AWS_REGION"],
    config=Config(s3={"addressing_style": "virtual"}),
)
table = boto3.resource("dynamodb").Table(os.environ["DYNAMODB_TABLE_NAME"])
BUCKET_NAME = os.environ["S3_BUCKET_NAME"]

PRESIGNED_URL_EXPIRATION_SECONDS = 600


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    # candidateId comes from the route path, e.g. GET /candidates/{candidateId}.
    candidate_id = (event.get("pathParameters") or {}).get("candidateId")
    if not candidate_id:
        return _response(400, {"message": "candidateId path parameter is required."})

    item = table.get_item(Key={"candidateId": candidate_id}).get("Item")
    if not item:
        return _response(404, {"message": f"Candidate {candidate_id} not found."})

    # Signed locally with the Lambda role credentials: no call to S3 is made here.
    cv_download_url = s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": BUCKET_NAME, "Key": item["cvS3Key"]},
        ExpiresIn=PRESIGNED_URL_EXPIRATION_SECONDS,
    )

    return _response(
        200,
        {
            "candidateId": item["candidateId"],
            "specialty": item["specialty"],
            "candidateFirstName": item["candidateFirstName"],
            "candidateLastName": item["candidateLastName"],
            "candidateBirthDate": item["candidateBirthDate"],
            "cvDownloadUrl": cv_download_url,
        },
    )
