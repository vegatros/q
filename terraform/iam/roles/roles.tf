resource "aws_iam_role" "AdminDomainJoiner" {
  name                = "AdminDomainJoiner"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "Allows EC2 instances to call AWS services on your behalf."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}

resource "aws_iam_role" "aks_node_group_1" {
  name                = "aks-node-group-1"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "Allows EC2 instances to call AWS services on your behalf."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy","arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly","arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

resource "aws_iam_role" "aks_test_2_cluster" {
  name                = "aks-test-2-cluster"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "Allows the cluster Kubernetes control plane to manage AWS resources on your behalf."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

resource "aws_iam_role" "AmazonEKSAutoClusterRole" {
  name                = "AmazonEKSAutoClusterRole"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":["sts:AssumeRole","sts:TagSession"]}]})
  description         = "Allows access to other AWS service resources that are required to operate Auto Mode clusters managed by EKS."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy","arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy","arn:aws:iam::aws:policy/AmazonEKSComputePolicy","arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy","arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"]
}

resource "aws_iam_role" "AmazonEKSAutoNodeRole" {
  name                = "AmazonEKSAutoNodeRole"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "Allows EKS nodes to connect to EKS Auto Mode clusters and to pull container images from ECR."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy","arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"]
}

resource "aws_iam_role" "AmazonEKSPodIdentityExternalDNSRole" {
  name                = "AmazonEKSPodIdentityExternalDNSRole"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"pods.eks.amazonaws.com"},"Action":["sts:AssumeRole","sts:TagSession"]}]})
  description         = "Allows pods running in Amazon EKS cluster to access AWS resources."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
}

resource "aws_iam_role" "AmazonSageMaker_ExecutionRole_20251209T174394" {
  name                = "AmazonSageMaker-ExecutionRole-20251209T174394"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"sagemaker.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker execution role created from the SageMaker AWS Management Console."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess","arn:aws:iam::aws:policy/AmazonSageMakerCanvasSMDataScienceAssistantAccess","arn:aws:iam::aws:policy/AmazonSageMakerCanvasAIServicesAccess","arn:aws:iam::aws:policy/AmazonSageMakerCanvasFullAccess","arn:aws:iam::aws:policy/AmazonSageMakerCanvasDataPrepFullAccess"]
}

resource "aws_iam_role" "AmazonSagemakerCanvasBedrockRole_20251209T174393" {
  name                = "AmazonSagemakerCanvasBedrockRole-20251209T174393"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Sid":"BedrockAssumeRole","Effect":"Allow","Principal":{"Service":"bedrock.amazonaws.com"},"Action":"sts:AssumeRole","Condition":{"StringEquals":{"aws:SourceAccount":"925185632967"}}}]})
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerCanvasBedrockAccess"]
}

resource "aws_iam_role" "AmazonSageMakerCanvasEMRSExecutionAccess_20251209T174393" {
  name                = "AmazonSageMakerCanvasEMRSExecutionAccess-20251209T174393"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Sid":"EMRServerlessTrustPolicy","Effect":"Allow","Principal":{"Service":"emr-serverless.amazonaws.com"},"Action":"sts:AssumeRole","Condition":{"StringEquals":{"aws:SourceAccount":"925185632967"}}}]})
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerCanvasEMRServerlessExecutionRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsApiGatewayRole" {
  name                = "AmazonSageMakerServiceCatalogProductsApiGatewayRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"apigateway.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS ApiGateway within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsApiGatewayServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCloudformationRole" {
  name                = "AmazonSageMakerServiceCatalogProductsCloudformationRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"cloudformation.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS CloudFormation within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsCloudformationServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCodeBuildRole" {
  name                = "AmazonSageMakerServiceCatalogProductsCodeBuildRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"codebuild.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS CodeBuild within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerServiceCatalogProductsCodeBuildServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCodePipelineRole" {
  name                = "AmazonSageMakerServiceCatalogProductsCodePipelineRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Sid":"","Effect":"Allow","Principal":{"Service":"codepipeline.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS CodePipeline within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsCodePipelineServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsEventsRole" {
  name                = "AmazonSageMakerServiceCatalogProductsEventsRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Sid":"","Effect":"Allow","Principal":{"Service":"events.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS Events within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsEventsServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsExecutionRole" {
  name                = "AmazonSageMakerServiceCatalogProductsExecutionRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"sagemaker.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS SageMaker within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsFirehoseRole" {
  name                = "AmazonSageMakerServiceCatalogProductsFirehoseRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"firehose.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS Firehose within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsFirehoseServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsGlueRole" {
  name                = "AmazonSageMakerServiceCatalogProductsGlueRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"glue.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS Glue within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsGlueServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsLambdaRole" {
  name                = "AmazonSageMakerServiceCatalogProductsLambdaRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role will grant permissions required to use AWS Lambda within the Amazon SageMaker portfolio of products."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsLambdaServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsLaunchRole" {
  name                = "AmazonSageMakerServiceCatalogProductsLaunchRole"
  path                = "/service-role/"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"servicecatalog.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  description         = "SageMaker role created from the SageMaker AWS Management Console. This role has the permissions required to launch the Amazon SageMaker portfolio of products from AWS ServiceCatalog."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSageMakerAdmin-ServiceCatalogProductsServiceRolePolicy"]
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsUseRole" {
  name               = "AmazonSageMakerServiceCatalogProductsUseRole"
  path               = "/service-role/"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["cloudformation.amazonaws.com","lambda.amazonaws.com","states.amazonaws.com","glue.amazonaws.com","apigateway.amazonaws.com","events.amazonaws.com","sagemaker.amazonaws.com","codebuild.amazonaws.com","firehose.amazonaws.com","codepipeline.amazonaws.com"]},"Action":"sts:AssumeRole"}]})
  description        = "SageMaker role created from the SageMaker AWS Management Console. This role has the permissions required to use the Amazon SageMaker portfolio of products from AWS ServiceCatalog."
}

resource "aws_iam_role" "AmazonWamMarketplace_Default_Role" {
  name               = "AmazonWamMarketplace_Default_Role"
  assume_role_policy = jsonencode({"Version":"2008-10-17","Statement":[{"Sid":"","Effect":"Allow","Principal":{"Service":"wam.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  inline_policy {
    name   = "WamMarketplaceAccess"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:GetObject"],"Resource":"arn:aws:s3:::aws-wam-marketplace/*"}]})
  }
}

resource "aws_iam_role" "AWSControlTowerExecution" {
  name                = "AWSControlTowerExecution"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::002667640586:root"},"Action":"sts:AssumeRole","Condition":{}}]})
  description         = "Control Tower enrollment"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role" "cloudtrailrole_forcloudwatch" {
  name               = "cloudtrailrole_forcloudwatch"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"cloudtrail.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  inline_policy {
    name   = "CloudTrailCloudWatchLogsPolicy"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["logs:CreateLogStream","logs:PutLogEvents"],"Resource":"arn:aws:logs:*:925185632967:log-group:*:log-stream:*"}]})
  }
}

resource "aws_iam_role" "eks" {
  name                = "eks"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"AIDA5O2K4NLD6BL4I7TRO"},"Action":"sts:AssumeRole"}]})
  description         = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess","arn:aws:iam::aws:policy/AmazonEKSClusterPolicy","arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy","arn:aws:iam::aws:policy/AmazonEKSServicePolicy","arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
}

resource "aws_iam_role" "eventbridge_route53_changes_role_d57y4wry" {
  name               = "eventbridge-route53-changes-role-d57y4wry"
  path               = "/service-role/"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]})
}

resource "aws_iam_role" "geodesic" {
  name                = "geodesic"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"AIDA5O2K4NLD6BL4I7TRO"},"Action":"sts:AssumeRole"}]})
  description         = "dev.cloudposse.co"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role" "Gitlab_Eks" {
  name                = "Gitlab-Eks"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com","AWS":"AIDA5O2K4NLD6BL4I7TRO"},"Action":"sts:AssumeRole"}]})
  description         = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
  inline_policy {
    name   = "gitlab-eks-cluster"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["eks:*"],"Resource":"*"}]})
  }
  inline_policy {
    name   = "gitlab-eks-service"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["eks:*"],"Resource":"*"}]})
  }
}

resource "aws_iam_role" "OrganizationAccountAccessRole" {
  name                = "OrganizationAccountAccessRole"
  assume_role_policy  = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::002667640586:root"},"Action":"sts:AssumeRole"}]})
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role" "SNSFailureFeedback" {
  name               = "SNSFailureFeedback"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"sns.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  inline_policy {
    name   = "oneClick_SNSFailureFeedback_1606959426736"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],"Resource":"*"}]})
  }
}

resource "aws_iam_role" "SNSSuccessFeedback" {
  name               = "SNSSuccessFeedback"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"sns.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  inline_policy {
    name   = "oneClick_SNSSuccessFeedback_1606959426736"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],"Resource":"*"}]})
  }
}

resource "aws_iam_role" "vmimport" {
  name               = "vmimport"
  assume_role_policy = jsonencode({"Version":"2012-10-17","Statement":[{"Sid":"","Effect":"Allow","Principal":{"Service":"vmie.amazonaws.com"},"Action":"sts:AssumeRole","Condition":{"StringEquals":{"sts:ExternalId":"vmimport"}}}]})
  inline_policy {
    name   = "vmimport-policy"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:GetBucketLocation","s3:GetObject","s3:ListBucket"],"Resource":["arn:aws:s3:::*"]},{"Effect":"Allow","Action":["ec2:ModifySnapshotAttribute","ec2:CopySnapshot","ec2:RegisterImage","ec2:Describe*"],"Resource":"*"}]})
  }
}

resource "aws_iam_role" "workspaces_DefaultRole" {
  name               = "workspaces_DefaultRole"
  assume_role_policy = jsonencode({"Version":"2008-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"workspaces.amazonaws.com"},"Action":"sts:AssumeRole"}]})
  inline_policy {
    name   = "SkyLightSelfServiceAccess"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["workspaces:*"],"Resource":"*"}]})
  }
  inline_policy {
    name   = "SkyLightServiceAccess"
    policy = jsonencode({"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["ec2:*","workspaces:*"],"Resource":"*"}]})
  }
}
