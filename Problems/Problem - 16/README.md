# Jenkins Pipeline to Execute Terraform Commands

## Overview

This project demonstrates how to use **Jenkins** to automate **Terraform** commands for provisioning AWS infrastructure.

### Architecture

```
Developer
    │
    │ Push Terraform Code
    ▼
 GitHub Repository
    │
    ▼
 Jenkins Pipeline
    │
    ├── Checkout Code
    ├── Terraform Init
    ├── Terraform Validate
    ├── Terraform Plan
    ├── Terraform Apply
    │
    ▼
 AWS Infrastructure
```

---

# Prerequisites

Before starting, ensure you have:

* EC2 Instance launched
* Java installed
* Jenkins installed

---

# Step 1: Install Git

SSH into the Jenkins EC2 instance.

```bash
sudo apt update
sudo apt install git -y
```

Verify installation:

```bash
git --version
```

Example Output:

```text
git version 2.43
```

---

# Step 2: Install Terraform

Download Terraform:

```bash
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
```

Install unzip:

```bash
sudo apt install unzip -y
```

Extract Terraform:

```bash
unzip terraform_1.9.8_linux_amd64.zip
```

Move Terraform binary:

```bash
sudo mv terraform /usr/local/bin/
```

Verify installation:

```bash
terraform version
```

Example Output:

```text
Terraform v1.9.8
```

---

# Step 3: Configure AWS Credentials

Terraform requires AWS credentials to provision infrastructure.

### Recommended Method

Attach an IAM Role to the Jenkins EC2 instance.

Example permissions:

* AmazonEC2FullAccess
* AmazonVPCFullAccess
* IAM (if creating IAM resources)
* AmazonS3FullAccess (if using remote backend)
* AmazonDynamoDBFullAccess (if using state locking)

Install AWS CLI if required:

```bash
sudo apt install awscli -y
```

Verify credentials:

```bash
aws sts get-caller-identity
```

---

# Step 4: Install Required Jenkins Plugins

Navigate to:

```
Manage Jenkins
        ↓
Plugins
```

Install:

* Git
* Pipeline
* Pipeline Stage View
* Credentials Binding
* Terraform Plugin (Optional)

Restart Jenkins after installation.

---

# Step 5: Push Terraform Code to GitHub

Example Repository Structure

```
TerraformPractice/

└── Problems/
    ├── Problem - 01/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── Problem - 02/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Push the repository to GitHub.

---

# Step 6: Create a Jenkins Pipeline Job

```
Dashboard

↓

New Item

↓

Terraform-Pipeline

↓

Pipeline

↓

Save
```

---

# Step 7: Jenkins Pipeline (Create Infrastructure)

```groovy
pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/TerraformPractice.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

    }
}
```

---

# Why do we use `dir()`?

When Jenkins clones the repository, it checks out the entire repository into its workspace.

Example workspace:

```
workspace/

└── TerraformPractice/
    └── Problems/
        └── Problem - 02/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

By default, every `sh` command executes from the workspace root.

For example:

```groovy
sh 'terraform init'
```

is executed from:

```
workspace/TerraformPractice/
```

Since the Terraform files are **inside** `Problems/Problem - 02`, Terraform cannot find any `.tf` files and returns:

```
No Terraform configuration files found.
```

To solve this, Jenkins provides the `dir()` step.

```groovy
dir('Problems/Problem - 02') {
    sh 'terraform init'
}
```

The `dir()` step changes the working directory for all commands inside its block.

Internally, Jenkins executes something similar to:

```bash
cd workspace/TerraformPractice/Problems/Problem\ -\ 02

terraform init
```

Now Terraform can locate:

* main.tf
* variables.tf
* outputs.tf

and executes successfully.

> **Note:** Writing `sh 'cd "Problems/Problem - 02"'` followed by another `sh 'terraform init'` does **not** work because each `sh` step runs in a separate shell process. The directory change is lost when the first shell exits.

---

# Jenkins Pipeline (Destroy Infrastructure)

```groovy
pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/TerraformPractice.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('Problems/Problem - 02') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

    }
}
```

---

# Pipeline Flow

```
Developer

↓

Push Code to GitHub

↓

Jenkins clones Repository

↓

Move into Terraform Directory

↓

terraform init

↓

terraform validate

↓

terraform plan

↓

terraform apply

↓

AWS Infrastructure Created
```

For destroying infrastructure:

```
Developer

↓

Trigger Destroy Pipeline

↓

Jenkins clones Repository

↓

Move into Terraform Directory

↓

terraform init

↓

terraform destroy

↓

AWS Infrastructure Removed
```

---

# Expected Interview Questions

### Why do we use `terraform init`?

It initializes the working directory and downloads the required providers and modules.

### Why do we run `terraform validate`?

To verify that the Terraform configuration is syntactically correct.

### Why do we run `terraform plan`?

To preview the infrastructure changes before applying them.

### Why do we use `terraform apply -auto-approve`?

It applies the planned changes without prompting for manual confirmation. This is useful in automated pipelines.

### Why do we use `dir()`?

Because the Terraform files are located in a subdirectory of the cloned repository. `dir()` changes Jenkins' working directory so Terraform can locate the configuration files.

### Why doesn't `cd` work across multiple `sh` steps?

Each `sh` step launches a new shell process. Any directory changes made in one shell are lost before the next `sh` step starts. `dir()` avoids this by setting the working directory for all enclosed steps.

### Why do we use an IAM Role instead of AWS access keys?

IAM Roles provide temporary credentials and eliminate the need to store long-lived AWS access keys on the Jenkins server, making the setup more secure.
