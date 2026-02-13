# Terraform GitHub Actions Setup

## Prerequisites

### 1. Configure AWS OIDC Provider

Create an OIDC provider in AWS IAM for GitHub Actions:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. Create IAM Role

Create a role with trust policy for GitHub:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:vegatros/q:*"
        }
      }
    }
  ]
}
```

Attach appropriate permissions (e.g., PowerUserAccess or custom policy).

### 3. Add GitHub Secret

Go to your repo settings → Secrets and variables → Actions → New repository secret:

- Name: `AWS_ROLE_ARN`
- Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME`

## Workflow Behavior

- **Pull Requests**: Runs `terraform plan` and comments results on PR
- **Push to master**: Runs `terraform apply -auto-approve`
- Runs for all directories: bedrock, ec2, ecs, eks, iam

## Usage

1. Create a branch and make Terraform changes
2. Open a PR - workflow runs plan
3. Review plan in PR comments
4. Merge to master - workflow applies changes
