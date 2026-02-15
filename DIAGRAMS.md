# Infrastructure Visualization Guide

This document contains Mermaid diagrams that explain the repository's infrastructure and workflows. You can view these diagrams on GitHub or using any Mermaid-compatible viewer.

## Table of Contents
1. [Repository Structure](#repository-structure)
2. [Terraform Workflow](#terraform-workflow)
3. [Checkov Security Scan](#checkov-security-scan)
4. [AWS Infrastructure Architecture](#aws-infrastructure-architecture)
5. [GitHub Actions OIDC Authentication](#github-actions-oidc-authentication)
6. [Complete CI/CD Pipeline](#complete-cicd-pipeline)

---

## Repository Structure

```mermaid
graph TD
    A[Repository Root] --> B[terraform/]
    A --> C[.github/workflows/]
    A --> D[cloudtrail/]
    A --> E[install.sh]
    
    B --> B1[ec2/]
    B --> B2[eks/]
    B --> B3[ecs/]
    B --> B4[iam/]
    B --> B5[bedrock/]
    
    B1 --> B1A[main.tf]
    B1 --> B1B[variables.tf]
    B1 --> B1C[outputs.tf]
    B1 --> B1D[backend.tf]
    
    C --> C1[terraform.yml]
    C --> C2[checkov.yml]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e8f5e9
    style B1 fill:#fce4ec
```

---

## Terraform Workflow

### High-Level Flow

```mermaid
flowchart TD
    Start([Developer Push/PR]) --> Trigger{Trigger Type?}
    
    Trigger -->|Pull Request| PR[PR to master]
    Trigger -->|Push| Push[Push to master]
    Trigger -->|Manual| Manual[workflow_dispatch]
    
    PR --> Checkout[Checkout Code]
    Push --> Checkout
    Manual --> Checkout
    
    Checkout --> Auth[AWS OIDC Authentication]
    Auth --> Init[Terraform Init]
    Init --> Format[Terraform Format Check]
    Format --> Validate[Terraform Validate]
    Validate --> Plan[Terraform Plan]
    
    Plan --> IsPR{Is Pull Request?}
    IsPR -->|Yes| Comment[Post Plan to PR]
    IsPR -->|No| IsMaster{Is Master Branch?}
    Comment --> End1([End])
    
    IsMaster -->|Yes| Approval[Wait for Manual Approval]
    IsMaster -->|No| End2([End])
    
    Approval --> Apply[Terraform Apply]
    Apply --> Deploy[Deploy to AWS]
    Deploy --> End3([Success])
    
    style Start fill:#4caf50
    style End1 fill:#2196f3
    style End2 fill:#2196f3
    style End3 fill:#4caf50
    style Approval fill:#ff9800
    style Deploy fill:#9c27b0
```

### Detailed Terraform Workflow Steps

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant GHA as GitHub Actions
    participant AWS as AWS
    participant S3 as S3 Backend
    
    Dev->>GH: Push code / Create PR
    GH->>GHA: Trigger workflow
    
    GHA->>GHA: Checkout code
    GHA->>AWS: Request OIDC token
    AWS-->>GHA: Return temporary credentials
    
    GHA->>S3: terraform init (load state)
    S3-->>GHA: Return current state
    
    GHA->>GHA: terraform fmt -check
    GHA->>GHA: terraform validate
    GHA->>GHA: terraform plan
    
    alt Pull Request
        GHA->>GH: Post plan as PR comment
        GH-->>Dev: Notify developer
    else Push to Master
        GHA->>GH: Create approval issue
        GH-->>Dev: Request approval
        Dev->>GH: Approve deployment
        GHA->>AWS: terraform apply
        AWS-->>GHA: Resources created
        GHA->>S3: Update state file
    end
```

---

## Checkov Security Scan

### Checkov Workflow

```mermaid
flowchart LR
    A([PR/Push to Master]) --> B[Checkout Code]
    B --> C[Run Checkov Scan]
    C --> D{Scan terraform/ec2}
    
    D --> E[Check Security Issues]
    E --> F[Check Compliance]
    F --> G[Generate Reports]
    
    G --> H[CLI Output]
    G --> I[SARIF File]
    
    I --> J{File Exists?}
    J -->|Yes| K[Upload to GitHub Security]
    J -->|No| L[Skip Upload]
    
    K --> M[View in Security Tab]
    H --> N[View in Logs]
    
    M --> O([End])
    N --> O
    L --> O
    
    style A fill:#4caf50
    style C fill:#ff9800
    style K fill:#2196f3
    style M fill:#9c27b0
```

### Security Checks Performed

```mermaid
mindmap
  root((Checkov Security))
    Infrastructure
      VPC Configuration
      Subnet Settings
      Security Groups
      Network ACLs
    Compute
      EC2 Instance Settings
      IAM Roles
      Key Management
      Encryption
    Compliance
      CIS Benchmarks
      PCI DSS
      HIPAA
      SOC 2
    Best Practices
      Tagging
      Logging
      Monitoring
      Backup
```

---

## AWS Infrastructure Architecture

### EC2 Module Architecture

```mermaid
graph TB
    subgraph AWS Cloud
        subgraph VPC[VPC - 10.0.0.0/16]
            IGW[Internet Gateway]
            
            subgraph PublicSubnet[Public Subnet - 10.0.1.0/24]
                EC2Public[EC2 Instance]
                SG1[Security Group]
            end
            
            subgraph PrivateSubnet[Private Subnet - 10.0.2.0/24]
                EC2Private[EC2 Instance]
                SG2[Security Group]
            end
            
            RT[Route Table]
        end
    end
    
    Internet((Internet)) --> IGW
    IGW --> RT
    RT --> PublicSubnet
    RT --> PrivateSubnet
    
    EC2Public -.->|Protected by| SG1
    EC2Private -.->|Protected by| SG2
    
    style VPC fill:#e3f2fd
    style PublicSubnet fill:#c8e6c9
    style PrivateSubnet fill:#ffccbc
    style IGW fill:#fff9c4
```

### Multi-Module Infrastructure

```mermaid
graph LR
    subgraph Terraform Modules
        A[EC2 Module] --> AWS1[EC2 Instances]
        B[EKS Module] --> AWS2[Kubernetes Cluster]
        C[ECS Module] --> AWS3[Container Service]
        D[IAM Module] --> AWS4[Roles & Policies]
        E[Bedrock Module] --> AWS5[AI/ML Services]
    end
    
    subgraph AWS Account
        AWS1
        AWS2
        AWS3
        AWS4
        AWS5
    end
    
    AWS4 -.->|Provides Access| AWS1
    AWS4 -.->|Provides Access| AWS2
    AWS4 -.->|Provides Access| AWS3
    AWS4 -.->|Provides Access| AWS5
    
    style A fill:#4caf50
    style B fill:#2196f3
    style C fill:#ff9800
    style D fill:#9c27b0
    style E fill:#e91e63
```

---

## GitHub Actions OIDC Authentication

### OIDC Authentication Flow

```mermaid
sequenceDiagram
    participant GHA as GitHub Actions
    participant GH as GitHub OIDC Provider
    participant AWS as AWS STS
    participant IAM as IAM Role
    participant Resources as AWS Resources
    
    GHA->>GH: Request OIDC token
    GH-->>GHA: Return JWT token
    
    GHA->>AWS: AssumeRoleWithWebIdentity
    Note over GHA,AWS: JWT token + Role ARN
    
    AWS->>IAM: Validate trust policy
    IAM-->>AWS: Trust validated
    
    AWS->>AWS: Verify token signature
    AWS->>AWS: Check token claims
    
    AWS-->>GHA: Temporary credentials
    Note over AWS,GHA: Access Key, Secret Key, Session Token<br/>(Valid for 1 hour)
    
    GHA->>Resources: Access AWS resources
    Resources-->>GHA: Perform operations
    
    Note over GHA,Resources: No long-lived credentials stored!
```

### OIDC Trust Relationship

```mermaid
graph TD
    A[GitHub Actions Workflow] -->|1. Request Token| B[GitHub OIDC Provider]
    B -->|2. Issue JWT| A
    A -->|3. Present JWT + Role ARN| C[AWS STS]
    
    C -->|4. Validate| D{Trust Policy Check}
    D -->|Check Issuer| E[token.actions.githubusercontent.com]
    D -->|Check Audience| F[sts.amazonaws.com]
    D -->|Check Subject| G[repo:owner/repo:ref:refs/heads/master]
    
    E --> H{Valid?}
    F --> H
    G --> H
    
    H -->|Yes| I[Issue Temporary Credentials]
    H -->|No| J[Deny Access]
    
    I --> K[Access AWS Resources]
    
    style A fill:#4caf50
    style C fill:#ff9800
    style I fill:#2196f3
    style J fill:#f44336
    style K fill:#9c27b0
```

---

## Complete CI/CD Pipeline

### End-to-End Pipeline

```mermaid
graph TB
    Start([Developer Commits Code]) --> Branch{Branch?}
    
    Branch -->|Feature Branch| FB[Feature Branch]
    Branch -->|Master Branch| MB[Master Branch]
    
    FB --> PR[Create Pull Request]
    PR --> Trigger1[Trigger Workflows]
    
    Trigger1 --> TF1[Terraform Workflow]
    Trigger1 --> CV1[Checkov Scan]
    
    TF1 --> Plan[Generate Plan]
    Plan --> Comment[Comment on PR]
    
    CV1 --> Scan1[Security Scan]
    Scan1 --> Report1[Post Results]
    
    Comment --> Review[Code Review]
    Report1 --> Review
    
    Review --> Approve{Approved?}
    Approve -->|No| Fix[Fix Issues]
    Fix --> PR
    Approve -->|Yes| Merge[Merge to Master]
    
    MB --> Trigger2[Trigger Workflows]
    Merge --> Trigger2
    
    Trigger2 --> TF2[Terraform Workflow]
    Trigger2 --> CV2[Checkov Scan]
    
    TF2 --> Plan2[Generate Plan]
    Plan2 --> Approval[Manual Approval Required]
    
    Approval --> Wait{Approved?}
    Wait -->|No| Cancel[Cancel Deployment]
    Wait -->|Yes| Apply[Terraform Apply]
    
    Apply --> Deploy[Deploy to AWS]
    
    CV2 --> Scan2[Security Scan]
    Scan2 --> Security[Update Security Tab]
    
    Deploy --> Success([Deployment Complete])
    Security --> Success
    Cancel --> End([Cancelled])
    
    style Start fill:#4caf50
    style Success fill:#4caf50
    style Deploy fill:#9c27b0
    style Approval fill:#ff9800
    style Cancel fill:#f44336
    style End fill:#757575
```

### Parallel Execution Strategy

```mermaid
gantt
    title Terraform Workflow Execution Timeline
    dateFormat  YYYY-MM-DD
    section Checkout & Auth
    Checkout Code           :a1, 2024-01-01, 1d
    AWS Authentication      :a2, after a1, 1d
    
    section EC2 Module
    Init EC2               :b1, after a2, 1d
    Validate EC2           :b2, after b1, 1d
    Plan EC2               :b3, after b2, 1d
    
    section EKS Module
    Init EKS               :c1, after a2, 1d
    Validate EKS           :c2, after c1, 1d
    Plan EKS               :c3, after c2, 1d
    
    section ECS Module
    Init ECS               :d1, after a2, 1d
    Validate ECS           :d2, after d1, 1d
    Plan ECS               :d3, after d2, 1d
    
    section Approval & Deploy
    Manual Approval        :crit, e1, after b3, 2d
    Apply Changes          :e2, after e1, 1d
```

---

## Workflow Permissions Model

```mermaid
graph TD
    subgraph GitHub Actions Workflow
        W[Workflow Execution]
    end
    
    subgraph Permissions
        P1[id-token: write]
        P2[contents: read]
        P3[pull-requests: write]
        P4[security-events: write]
    end
    
    subgraph Actions
        A1[Request OIDC Token]
        A2[Read Repository Code]
        A3[Comment on PRs]
        A4[Upload Security Scans]
    end
    
    W --> P1
    W --> P2
    W --> P3
    W --> P4
    
    P1 -.->|Enables| A1
    P2 -.->|Enables| A2
    P3 -.->|Enables| A3
    P4 -.->|Enables| A4
    
    A1 --> AWS[AWS Authentication]
    A2 --> Code[Access Code]
    A3 --> PR[PR Comments]
    A4 --> Sec[Security Tab]
    
    style W fill:#4caf50
    style P1 fill:#2196f3
    style P2 fill:#2196f3
    style P3 fill:#2196f3
    style P4 fill:#2196f3
```

---

## State Management

```mermaid
graph LR
    subgraph Local Development
        Dev[Developer]
        Local[Local Terraform]
    end
    
    subgraph GitHub Actions
        GHA[GitHub Actions Runner]
        TF[Terraform]
    end
    
    subgraph AWS
        S3[(S3 State Bucket)]
        Lock[(DynamoDB Lock Table)]
    end
    
    Dev -->|terraform init| Local
    Local <-->|Read/Write State| S3
    Local <-->|Acquire Lock| Lock
    
    GHA -->|terraform init| TF
    TF <-->|Read/Write State| S3
    TF <-->|Acquire Lock| Lock
    
    S3 -.->|Versioning Enabled| S3V[State History]
    S3 -.->|Encryption| S3E[AES-256]
    
    style S3 fill:#ff9800
    style Lock fill:#f44336
    style S3V fill:#4caf50
    style S3E fill:#2196f3
```

---

## How to View These Diagrams

### On GitHub
Simply view this file on GitHub - Mermaid diagrams render automatically in markdown files.

### Using Mermaid Live Editor
1. Visit https://mermaid.live/
2. Copy any diagram code block
3. Paste into the editor
4. Export as PNG or SVG

### Using VS Code
1. Install "Markdown Preview Mermaid Support" extension
2. Open this file
3. Use Ctrl+Shift+V (Cmd+Shift+V on Mac) for preview

### Using CLI
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate PNG from markdown
mmdc -i DIAGRAMS.md -o diagrams.pdf
```

---

## Diagram Legend

- 🟢 **Green**: Start/Success states
- 🔵 **Blue**: Process steps
- 🟠 **Orange**: Warning/Approval required
- 🔴 **Red**: Error/Failure states
- 🟣 **Purple**: Deployment/Critical actions
- ⬜ **Gray**: End/Cancelled states

---

## Additional Resources

- [Mermaid Documentation](https://mermaid.js.org/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
