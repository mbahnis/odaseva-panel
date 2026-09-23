import json
import os

import boto3
from boto3.dynamodb.conditions import Key

# Client is created once per container and reused across invocations.
table = boto3.resource("dynamodb").Table(os.environ["DYNAMODB_TABLE_NAME"])
GSI_NAME = os.environ["GSI_NAME"]

CANDIDATE_FIELDS = ["candidateId", "specialty", "candidateFirstName", "candidateLastName", "candidateBirthDate"]


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    # specialty comes from the query string, e.g. GET /candidates?specialty=dev.
    specialty = (event.get("queryStringParameters") or {}).get("specialty")
    if not specialty:
        return _response(400, {"message": "specialty query string parameter is required."})

    # Query the GSI, following pagination since a single page is capped at 1 MB.
    query_kwargs = {"IndexName": GSI_NAME, "KeyConditionExpression": Key("specialty").eq(specialty)}
    items = []
    while True:
        page = table.query(**query_kwargs)
        items.extend(page["Items"])
        if "LastEvaluatedKey" not in page:
            break
        query_kwargs["ExclusiveStartKey"] = page["LastEvaluatedKey"]

    # Only expose candidate fields; cvS3Key stays internal as no presigned URL is generated here.
    candidates = [{field: item.get(field) for field in CANDIDATE_FIELDS} for item in items]

    return _response(200, {"specialty": specialty, "count": len(candidates), "candidates": candidates})
