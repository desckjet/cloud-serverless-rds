# Cloud Serverless RDS Infrastructure

Infrastructure-as-code project that stands up an AWS environment for a serverless CRUD API backed by Aurora PostgreSQL. The stack is organised as reusable Terraform modules so environments can be spun up with minimal configuration.

## Architecture Overview

- **Networking** – Custom VPC with public and private subnets, Internet Gateway, NAT Gateways for outbound internet access from private subnets, and security groups tailored for database and Lambda communication.
- **Aurora PostgreSQL** – Serverless v2 cluster exposed through an RDS Proxy so Lambdas can authenticate with IAM and keep warm connections.
- **Lambda Functions** – Three Python handlers (`get`, `post`, `delete`) packaged with dependencies, deployed inside private subnets with internet access via NAT Gateway, and granted DB access through IAM policies and security groups.
- **API Gateway** – Regional REST API that maps `/animals` methods to the Lambda functions using proxy integrations.
- **GitHub OIDC & CI Role** – Allows GitHub Actions to assume an AWS role without static credentials; repository workflow runs `terraform fmt`, `validate`, `tflint`, and `tfsec`.
- **EC2 Bastion** – SSM managed instance in private subnet for administrative access to Aurora when direct connectivity is needed.

## Module Layout

```
terraform/
├─ main.tf                  # Composes environment from individual modules
├─ modules/
│  ├─ network/              # VPC, public/private subnets, IGW, NAT gateways, and security groups
│  ├─ database/             # Aurora cluster, RDS Proxy, IAM permissions
│  ├─ lambda/               # Packaging resources and Lambda functions
│  ├─ api_gateway/          # REST API, routes, integrations, permissions
│  ├─ github_oidc/          # OIDC provider, IAM role for CI
│  └─ ec2/                  # Bastion instance for SSM access
└─ ci_tester_role.tf        # Optional IAM role for manual validation
```

## Prerequisites

- Terraform ≥ 1.13
- AWS credentials with permissions to manage the services above
- (Optional) `pre-commit`, `tflint`, and `tfsec` if you want the same linting locally

## Usage

1. Copy `terraform/terraform.tfvars.example` (if present) or edit `terraform/terraform.tfvars` with project-specific values such as GitHub repository details and IAM principals.
2. Initialise Terraform and providers:
   ```bash
   cd terraform
   terraform init
   ```
3. Review the execution plan:
   ```bash
   terraform plan -out=tfplan
   ```
4. Apply the infrastructure:
   ```bash
   terraform apply tfplan
   ```

## Post-Deploy Verification

- Run `terraform output` to capture key identifiers (API invoke URL, Lambda names, RDS proxy endpoint, bastion instance ID).
- Test the API Gateway endpoints using `curl`:
  ```bash
  INVOKE_URL=$(terraform output -raw api_gateway_invoke_url)
  curl "$INVOKE_URL/animals"
  curl -X POST "$INVOKE_URL/animals" -H 'Content-Type: application/json' \
       -d '{"name":"lion","type":"mammal"}'
  curl -X DELETE "$INVOKE_URL/animals?name=lion"
  ```
- Inspect CloudWatch logs for each Lambda (`/aws/lambda/<function-name>`) to confirm successful executions.
- Use the SSM-managed bastion to forward a port to the Aurora proxy when direct SQL checks are required.

## Local Development & CI

- The repository includes a GitHub Actions workflow at `.github/workflows/gitops.yml` that runs `terraform fmt`, `terraform validate`, `tflint`, and `tfsec` on pull requests.
- Enable `pre-commit install` to mirror the same checks before committing.
- Lambda source lives under `terraform/modules/lambda/src`; update the Python handlers and rerun `terraform apply` to publish new logic.

## Cleanup

Destroy the environment when no longer needed to avoid ongoing AWS costs:

```bash
cd terraform
terraform destroy
```

## Future Enhancements

- Extend API Gateway routing to support nested resources or additional methods.
- Add automated integration tests that invoke the endpoints after deployment.
- Enable Aurora back-up policies and alarms for improved observability.

## 🛠 Development Workflow

- Install the tooling once (`brew install pre-commit tflint tfsec libpq` or use the official binaries/pip) and link the PostgreSQL client (`brew link --force libpq`).
- Install the Session Manager plugin for AWS CLI (`brew install --cask session-manager-plugin`) to enable SSM port forwarding.
- Enable the hooks with `pre-commit install`; they enforce `terraform fmt`, `terraform validate`, `tflint` and `tfsec` before every commit.
- Run `pre-commit run --all-files` or `terraform fmt -recursive` locally to check formatting on demand.
- The GitHub Actions workflow (`.github/workflows/gitops.yml`) repeats the same checks (`fmt`, `validate`, `tflint`, `tfsec`) and blocks merges when any lint or security finding appears.
- Define the GitHub repository secrets `AWS_GITHUB_ROLE_ARN` and `CI_TESTER_PRINCIPALS` (ARNs of the principals that can assume the tester role) so that the pipeline and your local sessions can federate.

## 🔐 Accessing Aurora via SSM Bastion

- Terraform provisions a private EC2 instance (SSM managed) and an Aurora PostgreSQL Serverless v2 cluster fronted by an RDS Proxy with IAM authentication.
- After deployment, retrieve outputs:
  ```bash
  terraform output ec2_instance_id
  terraform output database_proxy_endpoint
  terraform output database_master_username
  terraform output database_iam_token_username
  ```
- Establish an SSM port forwarding session against the writer when you need to execute administrative commands:
  ```bash
  aws ssm start-session \
    --target <ec2_instance_id> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["<proxy-endpoint>"],"portNumber":["5432"],"localPortNumber":["5432"]}' \
    --region us-east-1
  ```
- With the password stored in Secrets Manager (`terraform output database_credentials_secret_arn`) create the IAM-dedicated user once and enable the necessary permissions:
  ```sql
  CREATE USER <database_iam_token_username> WITH LOGIN;
  GRANT rds_iam TO <database_iam_token_username>;
  GRANT CONNECT ON DATABASE app TO <database_iam_token_username>;
  GRANT USAGE ON SCHEMA public TO <database_iam_token_username>;
  ```
- Generate an IAM auth token (replace the region/account accordingly):
  ```bash
  aws rds generate-db-auth-token \
    --hostname <proxy-endpoint> \
    --port 5432 \
    --region us-east-1 \
    --username <database_iam_token_username>
  ```
- Use the token as the password in your PostgreSQL client. If you see authentication errors, verify that `<database_iam_token_username>` retains the `rds_iam` grant.
