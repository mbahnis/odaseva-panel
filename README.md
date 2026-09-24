# Odaseva Panel

A serverless REST API for managing job candidates on AWS, deployed with Terraform.

## Architecture

```
                 1. POST /oauth2/token
                    (client_id + client_secret)
   ┌────────┐ ──────────────────────────────────► ┌─────────┐
   │ Client │ ◄────────────────────────────────── │ Cognito │
   └────────┘            access token (JWT)       └─────────┘
       │
       │ 2. HTTPS request + "Authorization: Bearer <token>"
       ▼
┌──────────────────┐   JWT + scope   ┌────────────────────────────┐
│   API Gateway    │ ──────────────► │ Lambda: create_candidate   │──┐
│   (HTTP API)     │   validated     │ Lambda: get_candidate      │──┤
└──────────────────┘                 │ Lambda: list_candidates    │──┤
                                     └────────────────────────────┘  │
                                                                     ▼
                                               ┌──────────────────────────────┐
                                               │ DynamoDB (candidate records) │
                                               │ S3       (CV files)          │
                                               └──────────────────────────────┘
                                                  encrypted with a shared KMS key
```

| Route | Lambda | Required scope |
|---|---|---|
| `POST /candidates` | `create_candidate` | `candidates-api/write` |
| `GET /candidates/{candidateId}` | `get_candidate` | `candidates-api/read` |
| `GET /candidates?specialty=...` | `list_candidates` | `candidates-api/read` |

AWS services used:

- **API Gateway (HTTP API)**: public entry point, JWT authorizer backed by Cognito
- **Lambda (Python 3.13)**: one function per route
- **DynamoDB**: candidate records, with a `specialty-index` GSI for listing by specialty
- **S3**: CV storage, downloaded through 10-minute presigned URLs
- **Cognito**: OAuth2 authorization server (Client Credentials flow)
- **KMS**: customer-managed key encrypting DynamoDB and S3
- **IAM**: one least-privilege role per Lambda
- **CloudWatch**: Lambda logs and API Gateway access logs (14-day retention)

## Project structure

```
.
├── infra/          Terraform root module (providers, variables, module calls, outputs)
│   └── modules/    One module per component: kms, dynamodb, s3, iam, lambda (generic), cognito, api_gateway
├── src/            Lambda source code, one folder per function (handler.py)
│   ├── create_candidate/
│   ├── get_candidate/
│   └── list_candidates/
└── docs/           Technical documentation
```

## Prerequisites

- Terraform >= 1.9
- AWS CLI configured with valid credentials for the target account
- curl, to test the API
- python3, used in the test commands to read JSON responses

## Deployment

```bash
cd infra
terraform init
terraform plan
terraform apply
```

The Lambda packages are built automatically by Terraform (`archive_file`) into `infra/.build/`.

## Testing

Run these commands from the `infra/` directory, after `terraform apply`. Secrets are loaded into shell variables and never printed.

```bash
# 1. Load the Terraform outputs
CLIENT_ID=$(terraform output -raw cognito_app_client_id)
CLIENT_SECRET=$(terraform output -raw cognito_app_client_secret)
COGNITO_DOMAIN=$(terraform output -raw cognito_user_pool_domain)
API_ENDPOINT=$(terraform output -raw api_endpoint)
AWS_REGION=eu-west-3   # default value of var.aws_region
```

```bash
# 2. Get an OAuth2 access token (Client Credentials flow)
TOKEN=$(curl -s -X POST "https://${COGNITO_DOMAIN}.auth.${AWS_REGION}.amazoncognito.com/oauth2/token" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  --data-urlencode "scope=candidates-api/write candidates-api/read" \
  | python3 -c 'import json, sys; print(json.load(sys.stdin)["access_token"])')
```

```bash
# 3. Create a candidate (expected: 201)
# fileContent is a tiny fake PDF, base64-encoded, for demo purposes only.
curl -s -X POST "${API_ENDPOINT}/candidates" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "specialty": "backend",
    "firstName": "Jane",
    "lastName": "Doe",
    "birthDate": "1990-05-17",
    "fileContent": "JVBERi0xLjQKJSBGYWtlIENWIGZvciBkZW1vIHB1cnBvc2VzIG9ubHkgLSBvZGFzZXZhLXBhbmVsIHNtb2tlIHRlc3QKJSVFT0YK",
    "fileExtension": "pdf"
  }'
# Response: {"candidateId": "CA-123456", "cvS3Key": "backend/CA-123456.pdf"}
```

```bash
# 4. Get the candidate by ID (expected: 200, includes a presigned cvDownloadUrl)
CANDIDATE_ID=CA-123456   # replace with the candidateId returned above
curl -s "${API_ENDPOINT}/candidates/${CANDIDATE_ID}" \
  -H "Authorization: Bearer ${TOKEN}"
```

```bash
# 5. List candidates by specialty (expected: 200)
curl -s "${API_ENDPOINT}/candidates?specialty=backend" \
  -H "Authorization: Bearer ${TOKEN}"
```

```bash
# 6. Call without a token (expected: 401 Unauthorized)
curl -s -o /dev/null -w "%{http_code}\n" "${API_ENDPOINT}/candidates?specialty=backend"
```

## Destroying the infrastructure

```bash
cd infra
terraform destroy
```

- The KMS key is not deleted immediately: AWS schedules it for deletion after a 7-day waiting period (`deletion_window_in_days = 7`), during which the deletion can still be cancelled.
- `force_destroy = true` is enabled on the S3 bucket so that `terraform destroy` also deletes the stored CVs, allowing repeated destroy/apply cycles during the demo. This is not recommended in production, where a destroy could permanently delete candidate data.

## Security and design decisions

See [docs/technical-specification.md](docs/technical-specification.md) for the
full rationale behind the architecture and security choices (authentication,
encryption, least-privilege IAM).

## Known limitations

See [docs/technical-specification.md](docs/technical-specification.md) for the
complete list of limitations and possible improvements.
