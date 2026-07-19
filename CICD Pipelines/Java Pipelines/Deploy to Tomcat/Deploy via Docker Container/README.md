# Jenkins CI/CD Pipeline: Java Maven Application with Docker & Docker Hub

## Project Overview

This project demonstrates a complete Jenkins CI/CD pipeline that:

- Pulls source code from GitHub
- Builds the Java Maven application
- Runs JUnit test cases
- Packages the application into a WAR file
- Builds a Docker image
- Pushes the Docker image to Docker Hub
- Pulls the latest image from Docker Hub
- Deploys the application as a Docker container

---

# Architecture

```text
                GitHub Repository
                        │
                        ▼
                  Jenkins Pipeline
                        │
        ┌───────────────┼────────────────┐
        ▼               ▼                ▼
   Build (Maven)     Test (JUnit)    Package (WAR)
                        │
                        ▼
               Build Docker Image
                        │
                        ▼
               Push to Docker Hub
                        │
                        ▼
              Pull Latest Docker Image
                        │
                        ▼
               Run Docker Container
                        │
                        ▼
             Access Application on Browser
```

---

# Prerequisites

- AWS EC2 (Ubuntu)
- Java 21
- Maven
- Jenkins
- Docker
- Git
- Docker Hub Account
- GitHub Repository

---

# Step 1: Launch an EC2 Instance

Launch an Ubuntu EC2 instance.

Recommended Configuration:

- Ubuntu 24.04 LTS
- t2.medium
- 20 GB Storage

### Open the following ports in the Security Group

| Port | Purpose |
|------|---------|
| 22 | SSH |
| 8080 | Jenkins |
| 8081 | Application |

Connect to the instance:

```bash
ssh -i key.pem ubuntu@<EC2-Public-IP>
```

---

# Step 2: Install Java

```bash
sudo apt update
sudo apt install openjdk-21-jdk -y

java -version
```

---

# Step 3: Install Maven

```bash
sudo apt install maven -y

mvn -version
```

---

# Step 4: Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update

sudo apt install jenkins -y

sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Verify Jenkins:

```bash
sudo systemctl status jenkins
```

Retrieve the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open Jenkins:

```
http://<EC2-Public-IP>:8080
```

Install Suggested Plugins and create an admin user.

---

# Step 5: Install Docker

```bash
sudo apt install docker.io -y

sudo systemctl enable docker
sudo systemctl start docker

docker --version
```

---

# Step 6: Add Jenkins User to Docker Group

```bash
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

sudo systemctl restart jenkins
```

Verify:

```bash
sudo su - jenkins

docker ps
```

---

# Step 7: Configure Jenkins

## Install Plugins

Go to:

**Manage Jenkins → Plugins**

Install:

- Docker
- Docker Pipeline
- Git
- Pipeline
- Credentials Binding

Restart Jenkins.

---

## Configure Tools

Go to:

**Manage Jenkins → Tools**

### JDK

```
Name: java21
```

Install automatically or configure the installed JDK.

### Maven

```
Name: Maven3
```

Install automatically.

---

# Step 8: Configure Docker Hub Credentials

Login to Docker Hub.

Navigate to:

```
Account Settings
    ↓
Personal Access Tokens
```

Generate a Personal Access Token with:

- Read
- Write
- Delete

Copy the generated token.

In Jenkins:

```
Manage Jenkins
      ↓
Credentials
      ↓
Global
      ↓
Add Credentials
```

Choose:

```
Kind:
Username with Password
```

Fill in:

```
Username : <DockerHub Username>

Password : <DockerHub Personal Access Token>

ID : dockerhub
```

Save the credentials.

---

# Step 9: Dockerfile

Create a `Dockerfile` in the root of your repository.

```dockerfile
FROM tomcat:10.1-jdk21

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
```

---

# Step 10: Jenkins Pipeline

Create a `Jenkinsfile` in the repository.

```groovy
pipeline {

    agent any

    tools {
        jdk 'java21'
        maven 'Maven3'
    }

    environment {
        IMAGE_NAME = "shravani2001/javademo"
    }

    stages {

        stage('Checkout') {
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

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    docker push ${IMAGE_NAME}:latest

                    docker logout
                    '''
                }
            }
        }
# echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin securely logs in to Docker Hub.
# Jenkins first retrieves the Docker Hub username and Personal Access Token from the configured Jenkins credentials and stores them in the environment variables DOCKER_USER and DOCKER_PASS.
# The echo command outputs the token, and the pipe (|) passes it as input to the docker login command.
# The --password-stdin option tells Docker to read the password or token from standard # input instead of prompting for it or exposing it on the command line
# We use docker logout as a security best practice. After pushing the Docker image, the pipeline no longer needs Docker Hub access.
# Logging out removes the stored authentication information from the Docker client, reducing the risk of credential misuse on shared Jenkins servers

        stage('Deploy') {
            steps {
                sh '''
                docker stop java-app || true

                docker rm java-app || true 

                docker pull ${IMAGE_NAME}:latest

                docker run -d \
                  --name java-app \
                  -p 8081:8080 \
                  ${IMAGE_NAME}:latest
                '''
            }
        }

    }
# Stops the running container named java-app.
# Docker cannot create another container with the same name while one already exists. And if There is no container named java-app then the error is ignored by || true
# docker stop java-app || true means "try to stop the container; if it doesn't exist or the command fails, execute true so the pipeline continues instead of failing.
    post {

        success {
            echo 'Pipeline executed successfully!'
        }

        failure {
            echo 'Pipeline execution failed!'
        }

        always {
            cleanWs()
        }
    }
}
```

---

# Step 11: Create Jenkins Pipeline Job

1. Click **New Item**
2. Enter a job name
3. Select **Pipeline**
4. Click **OK**
5. Under **Pipeline**, select **Pipeline script from SCM**
6. SCM → **Git**
7. Repository URL:

```
https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git
```

8. Branch:

```
main
```

9. Script Path:

```
Jenkinsfile
```

10. Save the job.

---

# Step 12: Run the Pipeline

Click **Build Now**.

Pipeline stages:

- Checkout
- Build
- Test
- Package
- Build Docker Image
- Push Docker Image
- Pull Docker Image
- Deploy Container

---

# Step 13: Verify Deployment

Check Docker container:

```bash
docker ps
```

Expected output:

```
CONTAINER ID   IMAGE                         STATUS
xxxxxxx        shravani2001/javademo:latest  Up
```

---

# Step 14: Access the Application

Open:

```
http://<EC2-Public-IP>:8081/
```

---

# Pipeline Workflow

```text
Developer
     │
     ▼
Push Code to GitHub
     │
     ▼
Jenkins Trigger
     │
     ▼
Checkout Source Code
     │
     ▼
Build Java Application
     │
     ▼
Run JUnit Tests
     │
     ▼
Package WAR File
     │
     ▼
Build Docker Image
     │
     ▼
Push Image to Docker Hub
     │
     ▼
Pull Latest Image
     │
     ▼
Stop Existing Container
     │
     ▼
Run New Container
     │
     ▼
Application Available on Port 8081
```

---

# Notes

- The application is packaged as a **WAR** file.
- Apache Tomcat runs inside the Docker container.
- The WAR file is renamed to **ROOT.war**, allowing access from the root context.
- The Docker image is pushed to Docker Hub before deployment.
- Ensure that **port 8081** is allowed in the EC2 Security Group.
