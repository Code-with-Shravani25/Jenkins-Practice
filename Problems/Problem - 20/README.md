# Jenkins Pipeline with Manual Approval Before Production Deployment

## Objective

This project demonstrates how to build a Java Maven application using Jenkins and pause the pipeline for **manual approval** before deploying to the production environment.

---

## Prerequisites

* AWS EC2 Instance (Amazon Linux/Ubuntu)
* Java (JDK)
* Jenkins
* Maven
* Git
* Internet connectivity

---

## Architecture

```text
GitHub Repository
        │
        ▼
     Jenkins
        │
        ├── Clone Source Code
        ├── Build Application
        ├── Run Unit Tests
        ├── Package Application
        ├── Manual Approval
        └── Deploy to Production
```

---

## Step 1: Launch an EC2 Instance

Launch an EC2 instance and install the following software:

* Java (JDK)
* Jenkins
* Maven
* Git

Verify the installations:

```bash
java -version
jenkins --version
mvn -version
git --version
```

Start Jenkins and access it through:

```
http://<EC2-Public-IP>:8080
```

---

## Step 2: Configure JDK and Maven in Jenkins

Navigate to:

```
Manage Jenkins
    └── Tools
```

### Configure JDK

* Name: JDK21 (or any preferred name)
* JAVA_HOME: //usr/lib/jvm/java-21-openjdk-amd64

### Configure Maven

* Name: Maven3
* Install automatically (recommended) or provide the Maven installation path

Save the configuration.

---

## Step 3: Create a Pipeline Job

1. Click **New Item**
2. Enter a job name
3. Select **Pipeline**
4. Click **OK**

Scroll to the **Pipeline** section and paste the following Jenkinsfile.

```groovy
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Approve Deployment to Production',
                      ok: 'Approve'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deployed to Production'
            }
        }
    }
}
```

Save the pipeline.

---

## Pipeline Stages

### 1. Clone

Clones the Maven project from the GitHub repository.

```bash
git clone
```

---

### 2. Build

Compiles the Java source code.

```bash
mvn clean compile
```

---

### 3. Test

Executes all unit test cases.

```bash
mvn test
```

---

### 4. Package

Creates the application artifact (JAR file).

```bash
mvn package
```

The generated artifact is stored in the `target/` directory.

---

### 5. Approval

Pauses the pipeline and waits for manual approval.

```groovy
input message: 'Approve Deployment to Production',
      ok: 'Approve'
```

* Clicking **Approve** continues the pipeline.
* Clicking **Abort** stops the pipeline.

---

### 6. Deploy

Simulates deployment to the production environment.

```groovy
echo 'Deployed to Production'
```

In a real-world project, this stage would typically:

* Copy the JAR/WAR file to a server
* Restart the application service
* Deploy to Tomcat
* Deploy to Docker/Kubernetes
* Deploy to AWS Elastic Beanstalk, ECS, or another production platform

---

## Pipeline Flow

```text
Clone
   │
   ▼
Build
   │
   ▼
Test
   │
   ▼
Package
   │
   ▼
Manual Approval
   │
Approve / Abort
   │
   ▼
Deploy to Production
```

---

## Expected Output

```text
Started by user

Stage: Clone
✓ Success

Stage: Build
✓ Success

Stage: Test
✓ Success

Stage: Package
✓ Success

Stage: Approval
Waiting for user approval...

Approve Deployment to Production?
[Approve] [Abort]

Stage: Deploy
Deployed to Production

Finished: SUCCESS
```

---

## Key Jenkins Concepts Covered

* Declarative Pipeline
* Pipeline Stages
* Git Integration
* Maven Build Lifecycle
* Unit Testing
* Packaging Maven Applications
* Manual Approval using `input`
* Production Deployment Workflow

---

### What happens when the pipeline reaches the `input` step?

The pipeline pauses and waits for a user to approve or abort the deployment.

---

### Why is manual approval used before production deployment?

It introduces a human validation checkpoint to ensure the application has been reviewed and is ready for deployment, reducing the risk of accidental or faulty production releases.
