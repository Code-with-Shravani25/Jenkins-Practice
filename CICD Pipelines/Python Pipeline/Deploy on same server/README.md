# Python Application CI/CD Pipeline with Jenkins, Docker and DockerHub

## 1. Project Overview

This project demonstrates a complete **CI/CD pipeline for a Python application** using:

* AWS EC2
* Jenkins
* Python
* GitHub
* Docker
* DockerHub
* Pytest

The pipeline performs the following operations:

**GitHub → Clone → Python Environment → Install Dependencies → Test → Docker Build → DockerHub Login → Push Image → Deploy Container**

---

## 2. Architecture

```text
                    GitHub Repository
                           |
                           | git clone
                           v
                    +--------------+
                    |    Jenkins   |
                    |     EC2      |
                    +--------------+
                           |
              +------------+------------+
              |            |            |
              v            v            v
          Python/venv    Pytest      Docker
              |            |            |
              +------------+------------+
                           |
                           v
                    Docker Image
                           |
                           v
                       DockerHub
                           |
                           | docker pull/run
                           v
                   Python App Container
                           |
                           v
                     Port 5000
```

---

# 3. GitHub Repository

Application source code:

```text
https://github.com/Code-with-Shravani25/python-code-with-test-cases.git
```

The repository contains the Python application, test cases, `requirements.txt`, and Dockerfile.

---

# 4. Launch EC2 Instance

Launch one Ubuntu EC2 instance.

Recommended configuration for practice:

```text
AMI       : Ubuntu
Instance  : t2.medium / t3.medium
Storage   : 20 GB
```

Configure the Security Group with:

| Port | Purpose            |
| ---- | ------------------ |
| 22   | SSH                |
| 8080 | Jenkins            |
| 5000 | Python application |

For better security, restrict SSH to **My IP** instead of opening it to the entire internet.

Connect to the EC2 instance:

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

# 5. Update the Server

```bash
sudo apt update
sudo apt upgrade -y
```

---

# 6. Install Java

Jenkins requires Java.

Install Java:

```bash
sudo apt install openjdk-21-jdk -y
```

Verify:

```bash
java -version
```

Expected:

```text
openjdk version "21..."
```

Check Java path:

```bash
readlink -f $(which java)
```

---

# 7. Install Jenkins

Add the Jenkins repository key:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

Add the repository:

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

Update packages:

```bash
sudo apt update
```

Install Jenkins:

```bash
sudo apt install jenkins -y
```

Start Jenkins:

```bash
sudo systemctl start jenkins
```

Enable Jenkins at boot:

```bash
sudo systemctl enable jenkins
```

Check status:

```bash
sudo systemctl status jenkins
```

---

# 8. Access Jenkins

Open:

```text
http://<EC2_PUBLIC_IP>:8080
```

Get the initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password and complete the Jenkins setup.

Create your Jenkins administrator account.

---

# 9. Install Docker

Install Docker:

```bash
sudo apt install docker.io -y
```

Start Docker:

```bash
sudo systemctl start docker
```

Enable Docker:

```bash
sudo systemctl enable docker
```

Verify:

```bash
docker --version
```

Test Docker:

```bash
sudo docker run hello-world
```

---

# 10. Give Jenkins Permission to Use Docker

By default, the Jenkins user cannot access the Docker daemon.

Check:

```bash
ls -l /var/run/docker.sock
```

Add Jenkins to the Docker group:

```bash
sudo usermod -aG docker jenkins
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

You can also restart Docker:

```bash
sudo systemctl restart docker
```

Verify Jenkins belongs to the Docker group:

```bash
groups jenkins
```

You should see:

```text
jenkins docker
```

### Why is this required?

Your pipeline executes commands such as:

```bash
docker build
docker login
docker push
docker run
```

These commands communicate with the Docker daemon.

The Jenkins process runs as the `jenkins` user, so that user needs permission to access Docker.

---

# 11. Install Python

Install Python:

```bash
sudo apt install python3 python3-pip python3-venv -y
```

Verify:

```bash
python3 --version
```

```bash
pip3 --version
```

Verify virtual environment support:

```bash
python3 -m venv --help
```

---

# 12. Configure Jenkins Plugins

Go to:

```text
Jenkins
→ Manage Jenkins
→ Plugins
```

Install the following plugins:

```text
Docker Pipeline
Git
Credentials Binding
Pipeline
```

If Git is already installed, no additional installation is required.

Restart Jenkins if requested.

---

# 13. Add DockerHub Credentials

Go to:

```text
Jenkins
→ Manage Jenkins
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
Password: <DockerHub password/access token>
ID: dockerhub
```

The important part is:

```text
ID = dockerhub
```

because the Jenkinsfile references:

```groovy
credentialsId: 'dockerhub'
```

For DockerHub, using an **access token** instead of your account password is recommended.

---

# 14. Dockerfile

The project needs a Dockerfile.

Example:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python3", "app.py"]
```

Make sure the startup command matches the actual Python application in your repository.

For example, if the application uses Flask and the main file is `app.py`:

```dockerfile
CMD ["python3", "app.py"]
```

---

# 15. Jenkins Pipeline

Create a new Jenkins Pipeline job:

```text
Jenkins
→ New Item
→ Pipeline
```

Give it a name such as:

```text
Python-CI-CD
```

Select:

```text
Pipeline
```

Then select:

```text
Pipeline
→ Definition
→ Pipeline script
```

Use the following Jenkinsfile:

```groovy
pipeline {

    agent any

    environment {
        IMAGE_NAME = 'shravani2001/pythonapp'
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
                    python3 -m venv pythonapp
                    . pythonapp/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    . pythonapp/bin/activate
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

        stage('LoginImage') {
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

        stage('PushImage') {
            steps {
                sh '''
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f pythonapp || true

                    docker run -d \
                        --name pythonapp \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:latest
                '''
            }
        }
    }
}
```

---

# 16. Understand the Pipeline

## Stage 1: Clone

```groovy
stage('Clone')
```

Jenkins downloads the source code from GitHub.

```groovy
git branch: 'main',
    url: 'https://github.com/Code-with-Shravani25/python-code-with-test-cases.git'
```

---

## Stage 2: Build

```bash
python3 -m venv pythonapp
```

Creates a Python virtual environment:

```text
pythonapp/
├── bin/
├── lib/
└── ...
```

Then:

```bash
. pythonapp/bin/activate
```

activates the virtual environment.

Then:

```bash
pip install -r requirements.txt
```

installs the application's Python dependencies.

---

## Stage 3: Test

```bash
. pythonapp/bin/activate
pytest -v
```

The virtual environment is activated again because **each Jenkins `sh` step runs in a separate shell**.

Therefore, activation from the previous `Build` stage does not remain active in the `Test` stage.

This is why you have:

```bash
. pythonapp/bin/activate
```

in both stages.

---

## Stage 4: Docker Image

```bash
docker build -t ${IMAGE_NAME}:latest .
```

Docker reads the Dockerfile and creates:

```text
shravani2001/pythonapp:latest
```

---

## Stage 5: DockerHub Login

Jenkins retrieves the credentials stored under:

```text
dockerhub
```

and performs:

```bash
docker login
```

The password is passed through standard input:

```bash
--password-stdin
```

so it is not directly placed in the command line.

---

## Stage 6: Push Image

```bash
docker push ${IMAGE_NAME}:latest
```

The image is uploaded to DockerHub.

DockerHub repository:

```text
shravani2001/pythonapp
```

---

# 17. Deploy Stage

First:

```bash
docker rm -f pythonapp || true
```

This removes the previous container if it exists.

The:

```bash
|| true
```

prevents the pipeline from failing when the container doesn't exist.

Then:

```bash
docker run -d \
    --name pythonapp \
    -p 5000:5000 \
    ${IMAGE_NAME}:latest
```

creates and starts the new container.

The port mapping is:

```text
EC2 port 5000
        |
        v
Container port 5000
```

---

# 18. Run the Pipeline

Go to:

```text
Jenkins
→ Python-CI-CD
→ Build Now
```

Jenkins executes:

```text
Clone
  ↓
Build
  ↓
Test
  ↓
DockerImage
  ↓
LoginImage
  ↓
PushImage
  ↓
Deploy
```

If all stages are successful, the pipeline finishes with:

```text
Finished: SUCCESS
```

---

# 19. Verify Docker Image

On the EC2 instance:

```bash
docker images
```

You should see:

```text
shravani2001/pythonapp
```

---

# 20. Verify Running Container

```bash
docker ps
```

Expected:

```text
pythonapp
```

You can also run:

```bash
docker ps -a
```

---

# 21. Check Container Logs

```bash
docker logs pythonapp
```

This is useful if the application does not start correctly.

Follow the logs:

```bash
docker logs -f pythonapp
```

---

# 22. Test the Application

Open:

```text
http://<EC2_PUBLIC_IP>:5000
```

If the application is working, the Python application's response should appear.

You can also test from the EC2 machine:

```bash
curl http://localhost:5000
```

---

# 23. Verify DockerHub

Go to your DockerHub repository and verify that the image was pushed:

```text
shravani2001/pythonapp
```

The repository should contain:

```text
latest
```

tag.

---

# 24. Complete CI/CD Flow

```text
Developer
    |
    | git push
    v
GitHub
    |
    | checkout
    v
Jenkins
    |
    +---- Build Python virtual environment
    |
    +---- Install dependencies
    |
    +---- Run pytest
    |
    +---- Build Docker image
    |
    +---- Login to DockerHub
    |
    +---- Push Docker image
    |
    +---- Remove old container
    |
    +---- Run new container
    |
    v
Python Application
    |
    v
EC2:5000
```

---

# 25. Useful Verification Commands

### Check Jenkins

```bash
sudo systemctl status jenkins
```

### Check Docker

```bash
sudo systemctl status docker
```

### Check Python

```bash
python3 --version
```

### Check Docker version

```bash
docker --version
```

### Check Jenkins Docker permission

```bash
groups jenkins
```

### Check Docker images

```bash
docker images
```

### Check containers

```bash
docker ps
```

### Check application logs

```bash
docker logs pythonapp
```

### Test application

```bash
curl http://localhost:5000
```

---

# 26. Common Problems

## Problem 1: `docker: permission denied`

Check:

```bash
groups jenkins
```

If `docker` is missing:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

## Problem 2: `python3: command not found`

Install:

```bash
sudo apt install python3 python3-pip python3-venv -y
```

---

## Problem 3: `pytest: command not found`

Make sure the virtual environment is activated:

```bash
. pythonapp/bin/activate
```

Then install dependencies:

```bash
pip install -r requirements.txt
```

---

## Problem 4: Docker build fails

Check:

```bash
ls
```

Make sure the Dockerfile exists:

```bash
ls Dockerfile
```

Then test manually:

```bash
docker build -t test-python-app .
```

---

## Problem 5: DockerHub authentication failure

Verify that:

```text
credentialsId = dockerhub
```

matches the Jenkins credential ID.

Also verify the DockerHub username and access token.

---

## Problem 6: Container immediately stops

Check:

```bash
docker ps -a
```

Then:

```bash
docker logs pythonapp
```

Usually this means the command in the Dockerfile does not correctly start the application.

---

## Problem 7: Cannot access port 5000

Check the EC2 Security Group and make sure inbound TCP port `5000` is allowed.

Also check:

```bash
docker ps
```

and confirm:

```text
0.0.0.0:5000->5000/tcp
```

---

# 27. Final Result

After successfully running the pipeline:

```text
GitHub
   ↓
Jenkins
   ↓
Python Build
   ↓
Pytest
   ↓
Docker Image
   ↓
DockerHub
   ↓
Docker Container
   ↓
Python Application
```

This gives you a complete **Python CI/CD implementation using Jenkins and Docker**, where every successful pipeline execution creates a Docker image, pushes it to DockerHub, and deploys the latest image as a Docker container on the EC2 instance.
