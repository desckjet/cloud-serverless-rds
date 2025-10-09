# Cloud Serverless RDS Infrastructure

Infrastructure-as-code project that stands up an AWS environment for a serverless CRUD API backed by Aurora PostgreSQL. The stack is organised as reusable Terraform modules so environments can be spun up with minimal configuration.

## Architecture Diagram

![Architecture Diagram](https://github.com/desckjet/cloud-serverles-rds/blob/feature/architecture-diagram.png)

## Architecture Overview

- **Networking** – Custom VPC with public and private subnets, Internet Gateway, NAT Gateways for outbound internet access from private subnets, and security groups tailored for database and Lambda communication.
- **Aurora PostgreSQL** – Serverless v2 cluster exposed through an RDS Proxy so Lambdas can authenticate with IAM and keep warm connections.
- **Lambda Functions** – Three Python handlers (`get`, `post`, `delete`) packaged with dependencies, deployed inside private subnets with internet access via NAT Gateway, and granted DB access through IAM policies and security groups.
- **API Gateway** – Regional REST API that maps `/animals` methods to the Lambda functions using proxy integrations.
- **GitHub OIDC & CI Role** – Allows GitHub Actions to assume an AWS role without static credentials; repository workflow runs `terraform fmt`, `validate`, `tflint`, and `tfsec`.
- **EC2 Bastion** – SSM managed instance in private subnet for administrative access to Aurora when direct connectivity is needed.

## IAM Roles Overview

This infrastructure creates several IAM roles with specific purposes and permissions:

### **🤖 `cloud-serverless-rds-dev-github-actions`**
- **Purpose**: GitHub Actions CI/CD automation via OIDC
- **Permissions**: Deploy and manage infrastructure through Terraform
- **Trust Policy**: GitHub OIDC provider (`token.actions.githubusercontent.com`)
- **Usage**: Automated deployments, infrastructure updates

### **🔧 `cloud-serverless-rds-dev-ci-tester`**
- **Purpose**: Local testing and administrative tasks
- **Permissions**: Limited access for safe local Terraform operations
- **Trust Policy**: Configurable principals (users/roles that can assume this role)
- **Usage**: Manual testing, troubleshooting, development validation
- **Configuration**: Set `ci_tester_principals` in `terraform.tfvars` with ARNs of users/roles allowed to assume this role

### **⚡ `cloud-serverless-rds-dev-lambda-role`**
- **Purpose**: Execution role for Lambda functions
- **Permissions**: VPC access, CloudWatch logs, RDS Proxy connection
- **Trust Policy**: Lambda service (`lambda.amazonaws.com`)
- **Usage**: Runtime execution of API handlers (get, post, delete)

### **🖥️ `cloud-serverless-rds-dev-ec2-role`**
- **Purpose**: EC2 bastion instance role
- **Permissions**: SSM Session Manager, RDS connection
- **Trust Policy**: EC2 service (`ec2.amazonaws.com`)
- **Usage**: Administrative access to Aurora via SSM port forwarding

### **🗄️ `cloud-serverless-rds-dev-db-proxy-role`**
- **Purpose**: RDS Proxy service role
- **Permissions**: Access to Secrets Manager for database credentials
- **Trust Policy**: RDS service (`rds.amazonaws.com`)
- **Usage**: Manages connection pooling and IAM authentication to Aurora

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

### Initial Setup

**Prerequisites**: Use AWS credentials from a user with admin permissions to create the backend, OIDC provider, and ci-tester role.

1. **Configure AWS Admin Profile and Project Variables**:
   ```bash
   # Configure admin profile (replace with your admin user info)
   aws configure --profile your-admin-user
   # Enter your Access Key ID, Secret Access Key, region (us-east-1), output format (json)
   ```

   Copy `terraform/terraform.tfvars.example` with project-specific values such as GitHub repository details and IAM principals.

2. **Create Terraform Backend** (S3 bucket for state):
   ```bash
   cd terraform

   # Comment out the S3 backend in terraform/versions.tf
   # (Comment the entire backend "s3" block)

   # Initialize without backend
   terraform init -backend=false

   # Plan and create only the S3 backend resources
   terraform plan -target=aws_s3_bucket.tf_state \
                  -target=aws_s3_bucket_public_access_block.tf_state \
                  -target=aws_s3_bucket_versioning.tf_state \
                  -target=aws_s3_bucket_server_side_encryption_configuration.tf_state \
                  -out=backend-plan
   terraform apply backend-plan

   # Uncomment the backend in terraform/versions.tf
   # Reconfigure to use the S3 backend
   terraform init -reconfigure
   ```

3. **Create GitHub OIDC Provider**:
   ```bash
   # Deploy the OIDC provider first (needed for GitHub Actions)
   terraform plan -target=module.github_oidc -out=oidc-plan
   terraform apply oidc-plan

   # Get the GitHub Actions role ARN
   terraform output -raw github_actions_role_arn
   ```

4. **Configure GitHub Repository Secrets**:

   Go to GitHub → Repository Settings → Secrets and variables → Actions

   **Secret 1:**
   - Click "New repository secret"
   - Name: `AWS_GITHUB_ROLE_ARN`
   - Value: Use the ARN from step 3

   **Secret 2:**
   - Click "New repository secret"
   - Name: `CI_TESTER_PRINCIPALS`
   - Value: Use the ARN of your admin account (same as terraform.tfvars)

5. **Create CI Tester Role**:
   ```bash
   # Create the testing role with limited permissions
   terraform plan -target=aws_iam_role.ci_tester \
                  -target=aws_iam_role_policy.ci_tester_inline \
                  -target=aws_iam_role_policy_attachment.ci_tester_managed \
                  -target=aws_iam_role_policy_attachment.ci_tester_rds_connect \
                  -out=ci-tester-plan
   terraform apply ci-tester-plan
   ```

6. **Configure AWS Profile for CI Tester Role**:

   Add the ci-tester profile to your AWS config file (`~/.aws/config`):
   ```ini
   [profile cloud-serverless-rds-ci-tester]
   role_arn = arn:aws:iam::YOUR-ACCOUNT-ID:role/cloud-serverless-rds-dev-ci-tester
   source_profile = your-admin-user
   region = us-east-1
   # Just in case you have configured MFA
   # mfa_serial = arn:aws:iam::YOUR-ACCOUNT-ID:mfa/your-admin-user
   ```

7. **Switch to CI Tester Role** (No more admin credentials needed):
   ```bash
   # Export credentials for the ci-tester role
   aws configure export-credentials --profile cloud-serverless-rds-ci-tester --format env

   # Or set the profile for Terraform
   export AWS_PROFILE=cloud-serverless-rds-ci-tester
   ```

8. **Deploy remaining infrastructure** (using ci-tester role):
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```


## Local Development & CI

- The repository includes a GitHub Actions workflow at `.github/workflows/gitops.yml` that runs `terraform fmt`, `terraform validate`, `tflint`, and `tfsec` on pull requests.
- Enable `pre-commit install` to mirror the same checks before committing.
- Lambda source lives under `terraform/modules/lambda/src`; update the Python handlers and rerun `terraform apply` to publish new logic.


## 🛠 Development Workflow

- Install the tooling once (`brew install pre-commit tflint tfsec libpq` or use the official binaries/pip) and link the PostgreSQL client (`brew link --force libpq`).
- Install the Session Manager plugin for AWS CLI (`brew install --cask session-manager-plugin`) to enable SSM port forwarding.
- Enable the hooks with `pre-commit install`; they enforce `terraform fmt`, `terraform validate`, `tflint` and `tfsec` before every commit.
- Run `pre-commit run --all-files` or `terraform fmt -recursive` locally to check formatting on demand.


## 🔐 Accessing Aurora via SSM Bastion

- Terraform provisions a private EC2 instance (SSM managed) and an Aurora PostgreSQL Serverless v2 cluster fronted by an RDS Proxy with IAM authentication.
- After deployment, retrieve outputs:
  ```bash
  terraform output ec2_instance_id
  terraform output database_endpoint
  terraform output database_proxy_endpoint
  terraform output database_master_username
  terraform output database_iam_token_username
  ```
- Establish an SSM port forwarding session against the cluster when you need to execute administrative commands:
  ```bash
  aws ssm start-session \
    --target <ec2_instance_id> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["<cluster-endpoint>"],"portNumber":["5432"],"localPortNumber":["5432"]}' \
    --region us-east-1
  ```

- **Connect to the cluster** (run this in a new terminal while SSM session is active):
  ```bash
  cd terraform

  # Get the master password from Secrets Manager
  SECRET_ARN=$(terraform output -raw database_credentials_secret_arn)

  MASTER_PASS=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --version-stage AWSCURRENT \
    --region us-east-1 \
    --query SecretString \
    --output text | jq -r '.password')

  # Connect using master credentials (for initial setup)
  PGPASSWORD="$MASTER_PASS" PGSSLMODE=require \
  psql "host=127.0.0.1 port=5432 dbname=app user=iam_db_user"
  ```

- **Setup database user, permissions, table and password** (one-time setup):
  ```sql
  -- Create IAM-enabled user
  CREATE USER iam_token_user WITH LOGIN;

  -- Create the animals table
  CREATE TABLE IF NOT EXISTS animals (
    name   TEXT PRIMARY KEY,
    weight NUMERIC(6,2) NOT NULL CHECK (weight > 0),
    height NUMERIC(6,2) NOT NULL CHECK (height > 0)
  );

  -- Grant database and schema permissions
  GRANT CONNECT ON DATABASE app TO iam_token_user;
  GRANT USAGE ON SCHEMA public TO iam_token_user;
  GRANT ALL PRIVILEGES ON SCHEMA public TO iam_token_user;
  GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO iam_token_user;

  -- Set password for the user (replace <PASSWORD> with actual password from Secrets Manager for iam_token_user)
  ALTER ROLE iam_token_user WITH LOGIN PASSWORD '<PASSWORD>';
  ```

- **Verify connection with iam_token_user** (test the setup):
  ```bash
  # Exit the current psql session (Ctrl+D or \q)
  # Then reconnect using the iam_token_user credentials
  PGPASSWORD='<PASSWORD>' PGSSLMODE=require \
  psql "host=127.0.0.1 port=5432 dbname=app user=iam_token_user"

  # Test basic operations
  \dt  # List tables
  SELECT * FROM animals;  # Query the table
  INSERT INTO animals (name, weight, height) VALUES ('TestAnimal', 100.50, 200.75);
  \q   # Exit
  ```

- **Test IAM Authentication via RDS Proxy** (validate IAM token authentication):
  ```bash
  # Get the proxy endpoint and instance ID
  PROXY_ENDPOINT=$(terraform output -raw database_proxy_endpoint)
  INSTANCE_ID=$(terraform output -raw ec2_instance_id)

  # Start SSM port forwarding to the RDS Proxy
  aws ssm start-session \
    --target $INSTANCE_ID \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"host\":[\"$PROXY_ENDPOINT\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5432\"]}" \
    --region us-east-1
  ```

  In a new terminal (while SSM session is active):
  ```bash
  cd terraform

  # Generate IAM authentication token for the proxy
  PROXY_ENDPOINT=$(terraform output -raw database_proxy_endpoint)

  TOKEN=$(aws rds generate-db-auth-token \
    --hostname $PROXY_ENDPOINT \
    --port 5432 \
    --region us-east-1 \
    --username iam_token_user)

  echo "Generated IAM token: $TOKEN"

  # Connect using IAM token authentication
  PGPASSWORD="$TOKEN" PGSSLMODE=require \
  psql "host=127.0.0.1 port=5432 dbname=app user=iam_token_user"

  # Test operations to verify IAM auth works
  SELECT current_user;
  SELECT * FROM animals;
  \q
  ```

## Post-Deploy Verification

- Run `terraform output` to capture key identifiers (API invoke URL, Lambda names, RDS proxy endpoint, bastion instance ID).
- Test the API Gateway endpoints using `curl`:
  ```bash
  INVOKE_URL=$(terraform output -raw api_gateway_invoke_url)

  # GET all animals
  curl "$INVOKE_URL/animals"

  # POST create a new animal (send JSON directly in body)
  curl -X POST "$INVOKE_URL/animals" -H 'Content-Type: application/json' \
       -d '{"name":"Lion","weight":400.00,"height":350.00}'

  # DELETE an animal by name (can use body or query parameter)
  curl -X DELETE "$INVOKE_URL/animals" -H 'Content-Type: application/json' \
       -d '{"name":"Lion"}'

  # Alternative DELETE using query parameter
  curl -X DELETE "$INVOKE_URL/animals?name=Lion"
  ```

## Cleanup

Destroy the environment when no longer needed to avoid ongoing AWS costs:

```bash
cd terraform
terraform destroy
```

## Future Enhancements

- **Implement VPC Endpoints for private networking**: Replace public subnets, Internet Gateway, and NAT Gateways with VPC Endpoints for AWS services (S3, Secrets Manager, SSM, etc.). This would eliminate internet access requirements and improve security by keeping all traffic within the AWS network backbone.

- **Enhanced monitoring and observability**:
  - CloudWatch dashboards for Lambda, RDS, and API Gateway metrics
  - Custom CloudWatch alarms for error rates, latency, and resource utilization
  - X-Ray tracing for end-to-end request tracking across Lambda functions
  - CloudWatch Insights queries for log analysis

- **Security hardening**:
  - AWS WAF integration with API Gateway for DDoS protection and request filtering
  - Secrets rotation automation for database credentials
  - VPC Flow Logs for network traffic analysis

- **Performance optimization**:
  - Lambda provisioned concurrency for consistent performance
  - RDS Performance Insights for database query optimization
  - API Gateway caching for frequently accessed endpoints
  - Lambda layer implementation for shared dependencies

- **Disaster recovery and backup**:
  - Automated database snapshots with lifecycle policies

- **DevOps and automation improvements**:
  - Automated integration tests that invoke the endpoints after deployment
  - Blue/green deployment strategy for zero-downtime updates
  - Canary deployments for Lambda functions

- **Cost optimization**:
  - S3 lifecycle policies for Terraform state and logs
  - Reserved capacity planning for predictable workloads (Savings plan)
