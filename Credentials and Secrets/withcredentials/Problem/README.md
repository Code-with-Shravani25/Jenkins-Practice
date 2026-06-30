# Jenkins Pipeline: Securely Pull a Docker Image Using `withCredentials`

## Objective

This project demonstrates how to securely authenticate to Docker Hub using Jenkins Credentials and pull a Docker image without hardcoding sensitive information such as usernames and passwords.

---

# Architecture

```
Developer
    │
    ▼
 Jenkins Pipeline
    │
    ▼
Jenkins Credentials Store
    │
    ▼
Docker Login
    │
    ▼
Pull Docker Image
    │
    ▼
Verify Image
```

---

# Prerequisites

- AWS EC2 Instance
- Java
- Jenkins
- Docker
- Docker Hub Account
- Docker image already pushed to Docker Hub (Example: `shravani2001/webapp`)

---

# Step 1: Launch an EC2 Instance

Launch an EC2 instance and install:

- Java
- Jenkins
- Docker

Verify the installations:

```bash
java -version
```

```bash
jenkins --version
```

```bash
docker --version
```

---

# Step 2: Add the Jenkins User to the Docker Group

By default, Docker commands can only be executed by the root user or members of the Docker group.

Add the Jenkins user to the Docker group:

```bash
sudo usermod -aG docker jenkins
```

Restart Docker:

```bash
sudo systemctl restart docker
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

Verify:

```bash
groups jenkins
```

Expected output:

```
jenkins : jenkins docker
```

---

# Step 3: Add Docker Hub Credentials to Jenkins

Navigate to:

```
Manage Jenkins
        ↓
Credentials
        ↓
System
        ↓
Global Credentials
        ↓
Add Credentials
```

Choose:

| Field | Value |
|--------|-------|
| Kind | Username with password |
| Username | Docker Hub Username |
| Password | Docker Hub Password or Personal Access Token |
| ID | `dockerhub-creds` |
| Description | Docker Hub Credentials |

Save the credential.

---

# Step 4: Create a Jenkins Pipeline

Create a new Pipeline project and paste the following Jenkinsfile.

```groovy
pipeline {
    agent any

    stages {

        stage('Login to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "Logging in to Docker Hub..."

                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin
                    '''
                }
            }
        }

        stage('Pull Docker Image') {
            steps {
                sh '''
                    docker pull shravani2001/webapp:latest
                '''
            }
        }

        stage('Verify Image') {
            steps {
                sh '''
                    docker images
                '''
            }
        }
    }
}
```

Click **Build Now**.

---

# Pipeline Explanation

## `agent any`

```groovy
agent any
```

Runs the pipeline on any available Jenkins agent.

---

## `stage`

A pipeline is divided into stages.

This pipeline contains three stages:

- Login to Docker Hub
- Pull Docker Image
- Verify Image

---

# Login to Docker Hub Stage

```groovy
withCredentials([
```

`withCredentials` tells Jenkins to temporarily fetch credentials from the Jenkins Credentials Store.

The credentials are available only inside this block.

Once the block ends, Jenkins automatically removes them.

---

## `usernamePassword`

```groovy
usernamePassword(
```

Specifies that the credential type is **Username with Password**.

---

## `credentialsId`

```groovy
credentialsId: 'dockerhub-creds'
```

This tells Jenkins which credential to retrieve from the Credentials Store.

---

## `usernameVariable`

```groovy
usernameVariable: 'DOCKER_USER'
```

Stores the Docker Hub username inside an environment variable called:

```
DOCKER_USER
```

---

## `passwordVariable`

```groovy
passwordVariable: 'DOCKER_PASS'
```

Stores the Docker Hub password (or Personal Access Token) inside:

```
DOCKER_PASS
```

> **Note:** `DOCKER_USER` and `DOCKER_PASS` are user-defined variable names. You can choose any valid names. However, the attributes `usernameVariable` and `passwordVariable` are fixed Jenkins parameters and cannot be renamed.

Example:

```groovy
usernameVariable: 'USER'
passwordVariable: 'PASS'
```

also works.

---

# Docker Login Command

```bash
echo "$DOCKER_PASS" | docker login \
-u "$DOCKER_USER" \
--password-stdin
```

Let's understand it step by step.

### Step 1

```bash
echo "$DOCKER_PASS"
```

Prints the value stored inside `DOCKER_PASS`.

---

### Step 2

```bash
|
```

The pipe (`|`) takes the output of the command on the left and sends it as the input to the command on the right.

Instead of displaying the password on the terminal, it passes it directly to Docker.

---

### Step 3

```bash
docker login
```

Starts the Docker login process.

---

### Step 4

```bash
-u "$DOCKER_USER"
```

Supplies the Docker Hub username.

Example:

```
shravani2001
```

---

### Step 5

```bash
--password-stdin
```

Instructs Docker to read the password from **standard input (stdin)** instead of the command line.

This is the recommended and secure authentication method.

---

# Why Not Use `-p`?

Avoid using:

```bash
docker login -u shravani2001 -p password
```

This is insecure because:

- The password is visible on the command line.
- It may appear in shell history.
- Other users may see it using:

```bash
ps -ef
```

or similar process-list commands.

---

# Why Use `--password-stdin`?

Using:

```bash
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
```

ensures:

- Password is not passed as a command-line argument.
- Password is not exposed in the process list.
- Docker reads the password securely from stdin.
- This is the recommended approach for CI/CD pipelines.

---

# Pull Docker Image Stage

```groovy
docker pull shravani2001/webapp:latest
```

Downloads the Docker image from Docker Hub.

---

# Verify Image Stage

```groovy
docker images
```

Displays all Docker images available on the Jenkins server.

Example:

```
REPOSITORY                 TAG      IMAGE ID
shravani2001/webapp        latest   abc123456
```

---

# Pipeline Flow

```
Pipeline Starts
       │
       ▼
Read Docker Hub Credentials
from Jenkins Credentials Store
       │
       ▼
Create Temporary Variables

DOCKER_USER

DOCKER_PASS
       │
       ▼
Docker Login
       │
       ▼
Remove Temporary Variables
       │
       ▼
Pull Docker Image
       │
       ▼
Verify Image
       │
       ▼
Pipeline Completed
```

---

# Best Practices

- Never hardcode usernames or passwords in the Jenkinsfile.
- Store all secrets in the Jenkins Credentials Store.
- Use `withCredentials` whenever credentials are required for a limited scope.
- Use `--password-stdin` instead of `docker login -p`.
- Use Docker Personal Access Tokens instead of passwords whenever possible.
- Regularly rotate credentials and update them in Jenkins.

---

# Summary

This project demonstrates how to:

- Install and configure Jenkins with Docker.
- Grant Docker access to the Jenkins user.
- Securely store Docker Hub credentials in Jenkins.
- Use `withCredentials` to inject credentials temporarily.
- Authenticate to Docker Hub securely using `--password-stdin`.
- Pull a Docker image from Docker Hub.
- Verify the downloaded image.

This approach follows security best practices and is widely used in production CI/CD pipelines.
