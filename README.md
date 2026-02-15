# AWS Infrastructure as Code Repository

This repository contains Terraform configurations for managing AWS infrastructure and GitHub Actions workflows for automated deployment and security scanning.

## Repository Structure

```
.
├── terraform/           # Terraform infrastructure modules
│   ├── ec2/            # EC2 instance configurations
│   ├── eks/            # EKS cluster configurations
│   ├── ecs/            # ECS service configurations
│   ├── iam/            # IAM roles and policies
│   └── bedrock/        # AWS Bedrock configurations
├── cloudtrail/         # CloudTrail logging configurations
├── .github/workflows/  # GitHub Actions CI/CD pipelines
└── install.sh          # Setup script

```

## Terraform Modules

### EC2 Module (`terraform/ec2/`)
Manages EC2 instances with associated networking resources including VPC, subnets, security groups, and internet gateways.

**Key Resources:**
- VPC with DNS support
- Public/Private subnets
- Internet Gateway
- Security Groups
- EC2 instances

### EKS Module (`terraform/eks/`)
Provisions Amazon Elastic Kubernetes Service clusters for container orchestration.

### ECS Module (`terraform/ecs/`)
Manages Amazon Elastic Container Service for Docker container deployments.

### IAM Module (`terraform/iam/`)
Centralized IAM role and policy management for AWS resources.

### Bedrock Module (`terraform/bedrock/`)
Configurations for AWS Bedrock AI/ML services.

## GitHub Actions Workflows

### Terraform Workflow (`.github/workflows/terraform.yml`)

**Purpose:** Automates Terraform infrastructure deployment with validation, planning, and approval gates.

**Triggers:**
- Manual dispatch (`workflow_dispatch`)
- Pull requests affecting `terraform/**` files
- Pushes to `master` branch

**Workflow Steps:**
1. **Checkout** - Retrieves repository code
2. **AWS Authentication** - Uses OIDC to assume AWS role (no long-lived credentials)
3. **Terraform Init** - Initializes backend and providers
4. **Terraform Format** - Validates code formatting
5. **Terraform Validate** - Checks configuration syntax
6. **Terraform Plan** - Generates execution plan
7. **PR Comment** - Posts plan output to pull request
8. **Manual Approval** - Requires approval before applying (master branch only)
9. **Terraform Apply** - Deploys infrastructure changes

**Security Features:**
- OIDC authentication (no static credentials)
- Manual approval gate for production changes
- Matrix strategy for parallel module deployment
- 15-minute timeout to prevent runaway jobs

### Checkov Security Scan (`.github/workflows/checkov.yml`)

**Purpose:** Performs static security analysis on Terraform code to identify misconfigurations and compliance violations.

**Triggers:**
- Pull requests to `master` branch
- Pushes to `master` branch

**Workflow Steps:**
1. **Checkout** - Retrieves repository code
2. **Run Checkov** - Scans Terraform configurations for security issues
3. **Check SARIF** - Verifies scan results file exists
4. **Upload Results** - Publishes findings to GitHub Security tab

**Security Checks:**
- Infrastructure misconfigurations
- Security best practices violations
- Compliance policy violations
- Results viewable in GitHub Security > Code scanning alerts

**Configuration:**
- Scans: `terraform/ec2` directory
- Output: CLI (logs) + SARIF (GitHub Security)
- Mode: `soft_fail` (doesn't block on findings)

## Setup Instructions

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository with Actions enabled
- Terraform >= 1.0

### AWS Configuration

1. **Create OIDC Provider in AWS:**
   ```bash
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list <github-thumbprint>
   ```

2. **Create IAM Role for GitHub Actions:**
   - Trust policy allowing GitHub OIDC
   - Attach necessary AWS permissions
   - Store role ARN in GitHub secret: `AWS_ROLE_ARN`

3. **Configure S3 Backend:**
   - Create S3 bucket for Terraform state
   - Enable versioning and encryption
   - Update `backend.tf` files with bucket name

### GitHub Secrets

Required secrets in repository settings:
- `AWS_ROLE_ARN` - IAM role ARN for OIDC authentication

### Running Terraform Locally

```bash
# Navigate to module directory
cd terraform/ec2

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Workflow Permissions

Both workflows use minimal required permissions:
- `id-token: write` - OIDC authentication
- `contents: read` - Repository access
- `pull-requests: write` - PR comments
- `security-events: write` - Security scan uploads

## Best Practices

1. **Always create pull requests** for infrastructure changes
2. **Review Terraform plans** before approving
3. **Address Checkov findings** before merging
4. **Use feature branches** for development
5. **Keep modules isolated** for independent deployment
6. **Monitor GitHub Actions logs** for deployment status

## Troubleshooting

### Terraform Apply Fails
- Check AWS credentials and permissions
- Verify backend state bucket exists
- Review Terraform plan output for errors

### Checkov Scan Failures
- Review security findings in GitHub Security tab
- Update configurations to address violations
- Consider exceptions for false positives

### Workflow Permission Errors
- Verify GitHub Actions permissions in repository settings
- Check AWS IAM role trust policy
- Ensure OIDC provider is configured correctly

## Contributing

1. Create feature branch from `master`
2. Make infrastructure changes
3. Test locally with `terraform plan`
4. Create pull request
5. Review Terraform plan in PR comments
6. Address Checkov security findings
7. Merge after approval

## Support

For issues or questions:
- Check GitHub Actions logs
- Review Terraform documentation
- Consult AWS service documentation
