# Jenkins Pipeline – Deploy AWS CloudFormation Stack

## Project Overview

This project demonstrates how to automate AWS infrastructure deployment using a Jenkins Declarative Pipeline and AWS CloudFormation.

The pipeline performs the following tasks:

* Clones a CloudFormation template from GitHub.
* Executes the AWS CLI CloudFormation deploy command.
* Creates or updates AWS infrastructure such as EC2, VPC, S3, IAM, and other supported AWS resources.

---

# Architecture

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins
    │
    ▼
CloudFormation Template
    │
    ▼
AWS CLI
aws cloudformation deploy
    │
    ▼
AWS CloudFormation
    │
    ▼
AWS Resources
(EC2, VPC, S3, IAM, etc.)
```

# Step 1: Launch an EC2 Instance

Launch an Ubuntu EC2 instance.

Install Jenkins and complete the initial setup.

Verify Jenkins is running:

```bash
sudo systemctl status jenkins
```

---

# Step 2: Install AWS CLI

Update packages:

```bash
sudo apt update
```

Install AWS CLI:

```bash
sudo apt install awscli -y
```

Verify installation:

```bash
aws --version
```

Example output:

```text
aws-cli/2.x.x
```

---

# Step 3: Attach an IAM Role to the EC2 Instance

Attach an IAM Role to the Jenkins EC2 instance.

For learning purposes, attach:

```text
CloudFormationFullAccess
AmazonEC2FullAccess
```

> **Note:** If your CloudFormation template creates resources such as EC2, VPC, S3, IAM, or RDS, the IAM role also requires permissions for those AWS services. CloudFormation can only create resources that the caller is authorized to create.

---

# Step 4: Repository Structure

```text
Cloud-formation-Template-Practice/
│
├── Jenkinsfile
├── Problem1.yaml
└── README.md
```

---

# Step 5: Jenkins Pipeline

```groovy
pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Code-with-Shravani25/Cloud-formation-Template-Practice.git'
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                sh '''
                aws cloudformation deploy \
                --template-file Problem1.yaml \
                --stack-name DemoStack
                '''
            }
        }
    }
}
```
---

# Pipeline Flow

```text
GitHub Repository
        │
        ▼
Checkout Source Code
        │
        ▼
CloudFormation Template
        │
        ▼
aws cloudformation deploy
        │
        ▼
AWS CloudFormation
        │
        ▼
Infrastructure Created / Updated
```

---

# Verify the Stack

List all CloudFormation stacks:

```bash
aws cloudformation list-stacks
```

Describe the deployed stack:

```bash
aws cloudformation describe-stacks \
--stack-name DemoStack
```

---

# Delete the Stack

```bash
aws cloudformation delete-stack \
--stack-name DemoStack
```

---
