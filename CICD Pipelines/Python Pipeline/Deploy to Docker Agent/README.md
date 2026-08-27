# Python CI/CD Pipeline Deployment Using Jenkins Docker Agent

## Overview

This project demonstrates a Jenkins CI/CD pipeline for a Python application using a **Docker-based Jenkins agent**.

The pipeline performs the following:

1. Clone the Python application from GitHub.
2. Create a Python virtual environment.
3. Install dependencies.
4. Run unit tests using `pytest`.
5. Build a Docker image.
6. Login to Docker Hub.
7. Push the image to Docker Hub.
8. Deploy the application as a Docker container.

## Architecture

```text
GitHub
   |
   | Clone
   v
Jenkins Controller
   |
   | Docker Cloud
   v
Docker Agent
   |
   +--> Python virtual environment
   +--> Install dependencies
   +--> Run pytest
   +--> Build Docker image
   |
   v
Docker Hub
   |
   | Pull latest image
   v
Python Application Container
   |
   | Port 5000
   v
Application
```

---

## 1. Launch an EC2 Instance

Launch an EC2 instance that will be used as the Jenkins server.

Install Java, Jenkins, Docker, and required packages.

### Install Java

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
```

Verify:

```bash
java -version
```

### Install Jenkins

Add the Jenkins repository and install Jenkins:

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
```

Start Jenkins:

```bash
sudo systemctl enable --now jenkins
```

Check status:

```bash
sudo systemctl status jenkins
```

Jenkins is normally available on:

```text
http://<EC2-PUBLIC-IP>:8080
```

### Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
```

Start Docker:

```bash
sudo systemctl enable --now docker
```

Verify:

```bash
docker --version
```

### Add Jenkins User to Docker Group

The Jenkins user needs permission to communicate with the Docker daemon.

```bash
sudo usermod -aG docker jenkins
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

Verify:

```bash
groups jenkins
```

You should see:

```text
jenkins docker
```

You can also verify Docker access as Jenkins:

```bash
sudo -u jenkins docker ps
```

---

# 2. Create the Jenkins Docker Agent Image

Create a `Dockerfile`:

```dockerfile
FROM jenkins/inbound-agent:jdk21

USER root

RUN apt update && apt install -y \
    docker.io \
    python3 \
    python3-pip \
    python3-venv

USER jenkins
```

### Build the Docker Agent Image

Run:

```bash
docker build -t python-jenkins-agent .
```

Verify:

```bash
docker images
```

You should see:

```text
python-jenkins-agent
```

This image contains:

* Jenkins inbound agent
* Java 21
* Docker CLI
* Python 3
* pip
* Python virtual environment support

---

# 3. Configure Jenkins

Open Jenkins:

```text
http://<EC2-PUBLIC-IP>:8080
```

## Install Required Plugins

Go to:

```text
Manage Jenkins
→ Plugins
```

Install the required plugins, including:

* Docker
* Docker Pipeline
* Git
* Credentials Binding
* Pipeline

Restart Jenkins if required.

---

# 4. Add Docker Hub Credentials

Go to:

```text
Manage Jenkins
→ Credentials
→ System
→ Global credentials
→ Add Credentials
```

Select:

```text
Kind: Username with password
```

Enter:

```text
Username: <DockerHub username>
Password: <DockerHub password/token>
ID: dockerhub
```

The pipeline uses:

```text
dockerhub
```

as the credential ID.

> It is recommended to use a Docker Hub access token instead of your Docker Hub password.

---

# 5. Configure Docker Cloud / Docker Agent

Go to:

```text
Manage Jenkins
→ Clouds
→ New Cloud
```

Create a Docker cloud configuration.

Configure the Docker host/daemon used by Jenkins.

Create a Docker template with:

```text
Label: docker-agent
```

Use the previously created image:

```text
python-jenkins-agent
```

The label is important because the pipeline contains:

```groovy
agent {
    label 'docker-agent'
}
```

Therefore, Jenkins will execute the pipeline on an agent matching the `docker-agent` label.

### Important Docker Socket Configuration

The Docker agent needs access to the Docker daemon to execute:

```bash
docker build
docker login
docker push
docker run
```

If the Docker daemon is running on the EC2 host, the agent container generally needs access to:

```text
/var/run/docker.sock
```

Configure the Docker template to mount:

```text
/var/run/docker.sock:/var/run/docker.sock
```

This allows the Docker agent to communicate with the host Docker daemon.

---

# 6. Python Application Requirements

The GitHub repository used in this pipeline is:

```text
https://github.com/Code-with-Shravani25/python-code-with-test-cases.git
```

The repository should contain a `requirements.txt` file.

Example:

```text
pytest
```

The pipeline creates a virtual environment and installs the dependencies:

```bash
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

---

# 7. Jenkins Pipeline

Create a new Jenkins Pipeline job.

Select:

```text
Pipeline
```

Add the following Jenkinsfile:

```groovy
pipeline {

    agent {
        label 'docker-agent'
    }

    environment {
        IMAGE_NAME = 'shravani2001/python'
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/python-code-with-test-cases.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest -v
                '''
            }
        }

        stage('DockerImage') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('DockerLogin') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login -u "$DOCKER_USERNAME" --password-stdin
                    '''
                }
            }
        }

        stage('DockerPush') {
            steps {
                sh '''
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f python-app || true

                    docker run -d \
                        --name python-app \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:latest
                '''
            }
        }
    }
}
```

---

# 8. Pipeline Stages Explained

### Clone

```groovy
stage('Clone')
```

Downloads the application source code from GitHub.

### Build

```bash
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

Creates a Python virtual environment and installs application dependencies.

### Test

```bash
pytest -v
```

Runs the Python test cases.

If the tests fail, the pipeline stops and the Docker image is not pushed.

### DockerImage

```bash
docker build -t ${IMAGE_NAME}:latest .
```

Builds the application's Docker image.

The resulting image is:

```text
shravani2001/python:latest
```

### DockerLogin

Jenkins retrieves Docker Hub credentials securely using:

```groovy
withCredentials()
```

and logs into Docker Hub.

### DockerPush

```bash
docker push ${IMAGE_NAME}:latest
```

Pushes the image to Docker Hub.

### Deploy

First removes an existing container:

```bash
docker rm -f python-app || true
```

Then starts the new container:

```bash
docker run -d \
    --name python-app \
    -p 5000:5000 \
    ${IMAGE_NAME}:latest
```

The application is exposed on port `5000`.

---

# 9. Run the Pipeline

Click:

```text
Build Now
```

The expected pipeline flow is:

```text
Clone
  ↓
Build
  ↓
Test
  ↓
DockerImage
  ↓
DockerLogin
  ↓
DockerPush
  ↓
Deploy
```

If all stages succeed, verify the container:

```bash
docker ps
```

Example:

```text
python-app
```

Check Docker images:

```bash
docker images
```

You should see:

```text
shravani2001/python
```

---

# 10. Access the Application

If the Python application listens on port `5000`, access it using:

```text
http://<EC2-PUBLIC-IP>:5000
```

Make sure the EC2 Security Group allows inbound traffic on port:

```text
5000
```

---

# 11. Verify Docker Hub

After a successful pipeline execution, the image should be available in Docker Hub as:

```text
shravani2001/python:latest
```

You can verify it with:

```bash
docker pull shravani2001/python:latest
```

---

# 12. Troubleshooting

## Docker command not found

Check:

```bash
docker --version
```

Also verify that Docker is installed inside the agent image.

## Jenkins cannot access Docker

Check:

```bash
ls -l /var/run/docker.sock
```

Verify the Docker socket is mounted into the agent container.

Also check:

```bash
docker ps
```

from inside the Jenkins agent.

## Python virtual environment fails

Make sure the agent image contains:

```text
python3
python3-pip
python3-venv
```

## Docker Hub push fails

Verify:

* Docker Hub username
* Docker Hub access token
* Jenkins credential ID is `dockerhub`
* Repository exists
* Docker Hub credentials have permission to push

## Pipeline cannot find `docker-agent`

Verify that the Jenkins Docker cloud/template has:

```text
Label: docker-agent
```

and that the agent template is configured correctly.

---

# CI/CD Flow

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    v
Docker Agent
    |
    +---- Python Build
    |
    +---- Pytest
    |
    +---- Docker Build
    |
    v
Docker Hub
    |
    v
Docker Container
    |
    v
Python Application
```

## Technologies Used

* AWS EC2
* Jenkins
* Docker
* Docker Hub
* Python
* pytest
* GitHub
* Jenkins Pipeline
* Docker Agent
