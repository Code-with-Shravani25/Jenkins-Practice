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

---

# Step 1: Launch an EC2 Instance

- Launch an Ubuntu EC2 instance 
- Install Java,Jenkins,Maven.

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

---

# Step 3: Create an S3 Bucket

Create an S3 bucket.

Example bucket name:

```text
mycompany-artifacts
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

