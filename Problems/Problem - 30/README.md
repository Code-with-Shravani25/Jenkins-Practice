# Jenkins Pipeline – Git Tag-Based Deployment Using GitHub Webhook

## Project Overview

This project demonstrates how to configure a Jenkins Pipeline that automatically deploys an application whenever a Git tag is pushed to a GitHub repository.

The pipeline is triggered using a GitHub webhook. When a new tag (for example, `v1.0` or `v2.0`) is pushed, GitHub sends a webhook notification to Jenkins. Jenkins then checks out the tagged version of the code, executes the pipeline, builds the application, and performs the deployment.

This approach is commonly used for production releases because Git tags represent fixed versions of the source code.

---

# Objectives

* Learn Git tag-based deployments.
* Trigger Jenkins using GitHub Webhooks.
* Deploy only tagged versions of the application.
* Understand version-based release deployments.
* Practice a real-world CI/CD deployment workflow.

---

# Prerequisites

Before starting, ensure the following are available:

* AWS EC2 instance
* Java installed
* Jenkins installed and running
* Git installed
* GitHub repository
* Public IP of the Jenkins server
* Port **8080** opened in the EC2 Security Group
* Git Plugin
* GitHub Plugin
* Pipeline Plugin

---

# Project Architecture

```text
Developer
    │
    │ git tag v1.0
    │ git push origin v1.0
    ▼
GitHub Repository
    │
    ▼
GitHub Webhook
    │
    ▼
Jenkins Pipeline
    │
    ▼
Checkout Tagged Version
    │
    ▼
Build
    │
    ▼
Deploy
```

---

# Project Structure

```text
tag-demo/
│
├── Jenkinsfile
└── index.html
```

---

# Jenkins Job Configuration

## Create Pipeline Job

* Open Jenkins Dashboard.
* Click **New Item**.
* Enter a job name (for example, `tag-deployment`).
* Select **Pipeline**.
* Click **OK**.

---

## Build Trigger

Enable:

```
GitHub hook trigger for GITScm polling
```

Do not enable **Poll SCM**.

---

## Pipeline Configuration

Select:

```
Pipeline script from SCM
```

SCM:

```
Git
```

Repository URL:

```text
https://github.com/<your-username>/tag-demo.git
```

Branch Specifier:

```text
refs/tags/*
```

This instructs Jenkins to build only Git tags instead of regular branches.

---

# GitHub Webhook Configuration

Navigate to:

```
GitHub Repository
    ↓
Settings
    ↓
Webhooks
    ↓
Add Webhook
```

Configure the webhook as follows:

**Payload URL**

```text
http://<EC2-PUBLIC-IP>:8080/github-webhook/
```

**Content Type**

```text
application/json
```

**Events**

```
Just the push event
```

Save the webhook configuration.

---

# Jenkinsfile

```groovy
pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Show Tag') {
            steps {
                sh 'git describe --tags'
            }
        }

        stage('Build') {
            steps {
                echo "Building application..."
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying application..."
            }
        }
    }
}
```

---

# Creating a Release

Create a Git tag.

```bash
git tag v1.0
```

Verify the tag.

```bash
git tag
```

Push the tag.

```bash
git push origin v1.0
```

GitHub sends a webhook request to Jenkins.

Jenkins checks out the tagged version and starts the deployment pipeline.

---

# Expected Pipeline Flow

```text
Git Tag Created
        │
        ▼
GitHub Receives Tag
        │
        ▼
Webhook Triggered
        │
        ▼
Jenkins Receives Request
        │
        ▼
Checkout Tag
        │
        ▼
Build Application
        │
        ▼
Deploy Application
```

---

# Sample Console Output

```text
Checking out Revision...

git checkout refs/tags/v1.0

Building application...

Deploying application...
```

---

# Advantages of Git Tag-Based Deployment

* Deploys only approved application versions.
* Ensures reproducible and consistent releases.
* Prevents accidental deployment of unfinished code.
* Makes rollback easier by redeploying an older tag.
* Improves release traceability.
* Commonly used for production deployments.

---

# Common Use Cases

* Production releases
* Versioned software deployments
* Release candidate deployments
* Hotfix deployments
* Continuous Delivery (CD) pipelines

---

# Notes

* Git tags represent immutable snapshots of the source code.
* A standard GitHub Push event includes both branch pushes and tag pushes.
* Depending on the Jenkins job type and plugin behavior, a simple Pipeline job may not always trigger reliably for tag pushes.
* In production environments, a **Multibranch Pipeline** with **Discover Tags** enabled is generally the recommended approach for Git tag-based deployments.

---

# Learning Outcomes

After completing this project, you will understand:

* Git tags and their purpose.
* GitHub Webhook integration with Jenkins.
* Tag-based deployment pipelines.
* Jenkins Pipeline configuration.
* Release management using Git tags.
* Basic CI/CD deployment workflow.
