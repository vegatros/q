#!/bin/bash

# GitHub repository secret setup
# Run this script to add AWS_ROLE_ARN secret to your GitHub repository

REPO_OWNER="vegatros"
REPO_NAME="q"
SECRET_NAME="AWS_ROLE_ARN"
SECRET_VALUE="arn:aws:iam::925185632967:role/GitHubActionsRole"

echo "To add the secret to your GitHub repository, you have two options:"
echo ""
echo "Option 1: Manual (via GitHub UI)"
echo "1. Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Name: ${SECRET_NAME}"
echo "4. Value: ${SECRET_VALUE}"
echo "5. Click 'Add secret'"
echo ""
echo "Option 2: Using GitHub CLI (if installed)"
echo "gh secret set ${SECRET_NAME} --body \"${SECRET_VALUE}\" --repo ${REPO_OWNER}/${REPO_NAME}"
echo ""
echo "Role ARN: ${SECRET_VALUE}"
