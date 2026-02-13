variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "agent_name" {
  description = "Name of the Bedrock agent"
  type        = string
  default     = "my-bedrock-agent"
}

variable "agent_instruction" {
  description = "Instructions for the Bedrock agent"
  type        = string
  default     = "You are a helpful AI assistant that provides accurate and concise responses."
}
