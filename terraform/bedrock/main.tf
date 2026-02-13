terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "bedrock_agent" {
  name = "bedrock-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_agent" {
  name = "bedrock-agent-policy"
  role = aws_iam_role.bedrock_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel"
      ]
      Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-text-express-v1"
    }]
  })
}

resource "aws_bedrockagent_agent" "main" {
  agent_name              = var.agent_name
  agent_resource_role_arn = aws_iam_role.bedrock_agent.arn
  foundation_model        = "amazon.titan-text-express-v1"
  instruction             = var.agent_instruction
}

resource "aws_bedrockagent_agent_alias" "main" {
  agent_alias_name = "prod"
  agent_id         = aws_bedrockagent_agent.main.agent_id
}
