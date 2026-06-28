# Jenkins Pipeline – Upload Maven Artifact to Amazon S3

## Project Overview

This project demonstrates how to use a Jenkins Declarative Pipeline to:

* Clone a Maven project from GitHub.
* Build the application using Maven.
* Generate a JAR artifact.
* Upload the generated artifact to an Amazon S3 bucket using the AWS CLI.

---

## Architecture

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins Pipeline
    │
    ├── Checkout Source Code
    │
    ├── Build using Maven
    │
    ├── Generate JAR Artifact
    │
    └── Upload Artifact to Amazon S3
                         │
                         ▼
                  Amazon S3 Bucket
```

---

# Prerequisites

Before running the pipeline, ensure the following components are available:

* AWS Account
* EC2 Instance
* Jenkins Installed
* Java Installed
* Maven Installed
* Git Installed
* AWS CLI Installed
* IAM Role attached to the EC2 instance with S3 permissions

---

# Step 1: Launch an EC2 Instance

Launch an Ubuntu EC2 instance and install Jenkins.

---

# Step 2: Install AWS CLI

Update the package list:

```bash
sudo apt update
```

Install AWS CLI:

```bash
sudo apt install awscli -y
```

Verify the installation:

```bash
aws --version
```

Example output:

```text
aws-cli/2.x.x
```

---

# Step 3: Create an S3 Bucket

Create an S3 bucket.

Example bucket name:

```text
mycompany-artifacts
```

Example bucket structure:

```text
mycompany-artifacts
│
├── app.jar
├── reports/
└── backups/
```

---

# Step 4: Configure IAM Permissions

Attach an IAM Role to the Jenkins EC2 instance.

For practice, attach:

```text
AmazonS3FullAccess
```

For production environments, create a custom IAM policy with only the required permissions.

---

# Step 5: Create the Jenkins Pipeline

```groovy
pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Upload Artifact') {
            steps {
                sh '''
                aws s3 cp target/*.jar s3://mycompany-artifacts/
                '''
            }
        }
    }
}
```

---

# Pipeline Stages

## Checkout

Downloads the source code from the GitHub repository.

---

## Build

Executes the Maven build.

```bash
mvn clean package
```

The generated JAR file is created inside:

```text
target/
```

Example:

```text
target/demo-0.0.1-SNAPSHOT.jar
```

---

## Upload Artifact

Uploads the generated JAR file to Amazon S3.

```bash
aws s3 cp target/*.jar s3://mycompany-artifacts/
```

---

# Expected Pipeline Flow

```text
GitHub Repository
        │
        ▼
Checkout Source Code
        │
        ▼
Maven Build
        │
        ▼
Generate JAR
        │
        ▼
Upload JAR to S3
        │
        ▼
Amazon S3
```

---

# Verify the Upload

List the contents of the S3 bucket:

```bash
aws s3 ls s3://mycompany-artifacts/
```

Example output:

```text
2026-06-28 12:45:22 demo-0.0.1-SNAPSHOT.jar
```

---

# Technologies Used

* Jenkins
* Git
* GitHub
* Maven
* Java
* Amazon S3
* AWS CLI
* IAM
* EC2

---

# Key Learning Outcomes

* Configure Jenkins on an EC2 instance.
* Install and use the AWS CLI.
* Use IAM Roles for secure AWS authentication.
* Build Java applications using Maven.
* Automate artifact uploads to Amazon S3.
* Create CI pipelines using Jenkins Declarative Pipeline syntax.

---

# Interview Questions

### Why upload artifacts to Amazon S3?

Amazon S3 provides durable, centralized, and highly available storage for build artifacts, making them accessible for deployments and future use.

---

### Why use an IAM Role instead of AWS Access Keys?

IAM Roles eliminate the need to store long-term AWS credentials on the Jenkins server, improving security and simplifying credential management.

---

### Which AWS CLI command uploads a file to S3?

```bash
aws s3 cp <source-file> s3://bucket-name/
```

---

### Where is the Maven artifact generated?

Inside the project's `target/` directory after running:

```bash
mvn clean package
```

---

### What happens if the S3 bucket does not exist?

The upload command fails with an error indicating that the specified bucket cannot be found.

---

### How does Jenkins authenticate with AWS?

Jenkins uses the IAM Role attached to the EC2 instance. The AWS CLI automatically retrieves temporary credentials from the instance metadata service.
