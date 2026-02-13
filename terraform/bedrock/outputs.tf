output "bedrock_agent_role_arn" {
  description = "ARN of the Bedrock agent role"
  value       = aws_iam_role.bedrock_agent.arn
}

output "bedrock_agent_id" {
  description = "ID of the Bedrock agent"
  value       = aws_bedrockagent_agent.main.agent_id
}

output "bedrock_agent_alias_id" {
  description = "ID of the Bedrock agent alias"
  value       = aws_bedrockagent_agent_alias.main.agent_alias_id
}
