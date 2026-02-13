terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_policy" "cloudberry_role_policy" {
  name = "cloudberry-role-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListAllMyBuckets"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::cada-cloudberry/*",
          "arn:aws:s3:::cada-cloudberry"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_read" {
  name = "ec2-read"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeVpnConnections",
          "ec2:GetEbsEncryptionByDefault",
          "ec2:GetCapacityReservationUsage",
          "ec2:DescribeVolumesModifications",
          "ec2:GetHostReservationPurchasePreview",
          "ec2:DescribeFastSnapshotRestores",
          "ec2:GetConsoleScreenshot",
          "ec2:GetReservedInstancesExchangeQuote",
          "ec2:GetConsoleOutput",
          "ec2:GetPasswordData",
          "ec2:GetLaunchTemplateData",
          "ec2:DescribeScheduledInstances",
          "ec2:DescribeScheduledInstanceAvailability",
          "ec2:GetEbsDefaultKmsKeyId",
          "ec2:DescribeElasticGpus"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_cloudwatch" {
  name        = "CloudTrailPolicyForCloudWatchLogs_d32d46dd-e86b-4460-8295-f763b8acfe6c"
  path        = "/service-role/"
  description = "CloudTrail role to send logs to CloudWatch Logs"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailCreateLogStream2014110"
        Effect = "Allow"
        Action = ["logs:CreateLogStream"]
        Resource = [
          "arn:aws:logs:us-east-1:925185632967:log-group:aws-cloudtrail-logs-925185632967-67d830fe:log-stream:925185632967_CloudTrail_us-east-1*"
        ]
      },
      {
        Sid    = "AWSCloudTrailPutLogEvents20141101"
        Effect = "Allow"
        Action = ["logs:PutLogEvents"]
        Resource = [
          "arn:aws:logs:us-east-1:925185632967:log-group:aws-cloudtrail-logs-925185632967-67d830fe:log-stream:925185632967_CloudTrail_us-east-1*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cadwad_gitlab_eks" {
  name = "cadwad-gitlab-eks-role"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:*",
          "cloudformation:*",
          "ec2:*",
          "eks:*",
          "iam:*",
          "ssm:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sts_eks_role" {
  name = "sts-eks-role"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "sts:GetSessionToken",
          "sts:DecodeAuthorizationMessage",
          "sts:GetAccessKeyInfo",
          "sts:GetCallerIdentity",
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
      },
      {
        Sid      = "VisualEditor1"
        Effect   = "Allow"
        Action   = "sts:*"
        Resource = "arn:aws:iam::925185632967:role/eks"
      }
    ]
  })
}
