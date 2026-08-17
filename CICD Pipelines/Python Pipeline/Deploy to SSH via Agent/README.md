# Python CI/CD Pipeline with Jenkins, Docker and SSH Agent

This project demonstrates a complete **CI/CD pipeline for a Python application** using:

* AWS EC2
* Jenkins
* Jenkins SSH Agent
* Python
* pytest
* Docker
* Docker Hub
* GitHub

The Jenkins Controller runs on one EC2 instance, while the Jenkins Agent runs on a separate EC2 instance where Python and Docker are installed.

---

## Architecture

```text
                         GitHub Repository
                                |
                                | Clone
                                v
                    +-----------------------+
                    |   EC2-1               |
                    |   Jenkins Controller  |
                    |                       |
                    |   Java                |
                    |   Jenkins             |
                    |   Git                 |
                    +----------+------------+
                               |
                               | SSH
                               v
                    +-----------------------+
                    |   EC2-2               |
                    |   Jenkins Agent       |
                    |                       |
                    |   Java                |
                    |   Python              |
                    |   pip                 |
                    |   Git                 |
                    |   Docker              |
                    +----------+------------+
                               |
                               | Docker Build
                               v
                       +---------------+
                       | Docker Image  |
                       +-------+-------+
                               |
                               | Docker Push
                               v
                         +-----------+
                         | DockerHub |
                         +-----+-----+
                               |
                               | Docker Pull
                               v
                    +-----------------------+
                    | Docker Container      |
                    | python-app             |
                    +-----------------------+
```

---

# 1. Project Repository

GitHub repository:

```text
https://github.com/Code-with-Shravani25/python-code-with-test-cases.git
```

The Jenkins pipeline clones the `main` branch.

---

# 2. EC2 Infrastructure

Create two Ubuntu EC2 instances.

## EC2-1: Jenkins Controller

Install:

* Java
* Jenkins
* Git
* SSH client

Jenkins will run on:

```text
http://<JENKINS-IP>:8080
```

Allow the following inbound ports in the Security Group:

```text
22    SSH
8080  Jenkins
```

---

# 3. Install Java on Jenkins Controller

Connect to EC2-1:

```bash
ssh -i your-key.pem ubuntu@<JENKINS-IP>
```

Update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

Install Java:

```bash
sudo apt install fontconfig openjdk-21-jre -y
```

Verify:

```bash
java -version
```

---

# 4. Install Jenkins

Install Jenkins on EC2-1.

After installation:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Check:

```bash
sudo systemctl status jenkins
```

Get the initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open:

```text
http://<JENKINS-IP>:8080
```

Complete the Jenkins setup wizard.

---

# 5. Generate SSH Key for Jenkins

Switch to the Jenkins user:

```bash
sudo su - jenkins
```

Verify:

```bash
whoami
```

Expected:

```text
jenkins
```

Generate an SSH key:

```bash
ssh-keygen -t ed25519
```

Press **Enter** for the default location and press **Enter** twice for an empty passphrase.

Check the key:

```bash
ls -la ~/.ssh
```

You should have:

```text
id_ed25519
id_ed25519.pub
```

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the complete public key.

> Never copy or expose `id_ed25519`. Only copy `id_ed25519.pub`.

---

# 6. Launch EC2-2 Jenkins Agent

Launch another Ubuntu EC2 instance.

Connect:

```bash
ssh -i your-key.pem ubuntu@<AGENT-IP>
```

Install Java:

```bash
sudo apt update
sudo apt install openjdk-21-jre -y
```

Verify:

```bash
java -version
```

---

# 7. Install Python

Install Python, pip and virtual environment support:

```bash
sudo apt install python3 python3-pip python3-venv -y
```

Verify:

```bash
python3 --version
pip3 --version
```

---

# 8. Install Git

```bash
sudo apt install git -y
```

Verify:

```bash
git --version
```

---

# 9. Install Docker

Install Docker:

```bash
sudo apt install docker.io -y
```

Start Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Check:

```bash
sudo systemctl status docker
```

Verify:

```bash
docker --version
```

---

# 10. Allow Docker Without sudo

Add the Ubuntu user to the Docker group:

```bash
sudo usermod -aG docker ubuntu
```

Log out:

```bash
exit
```

Reconnect to EC2-2:

```bash
ssh -i your-key.pem ubuntu@<AGENT-IP>
```

Test:

```bash
docker ps
```

Docker should work without `sudo`.

---

# 11. Configure SSH Authentication

On EC2-2:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Open:

```bash
nano ~/.ssh/authorized_keys
```

Paste the public key copied from the Jenkins Controller:

```text
ssh-ed25519 AAAA...
```

Save the file.

Set permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

# 12. Test SSH Connection

On EC2-1, switch to Jenkins:

```bash
sudo su - jenkins
```

Connect to EC2-2:

```bash
ssh ubuntu@<AGENT-IP>
```

Test:

```bash
whoami
```

Expected:

```text
ubuntu
```

Also test:

```bash
python3 --version
docker --version
```

If these commands work, Jenkins can communicate with the agent.

---

# 13. Jenkins Plugins

Open:

```text
Jenkins
→ Manage Jenkins
→ Plugins
```

Install the required plugins:

* SSH Build Agents
* Docker Pipeline
* Pipeline
* Git
* Credentials Binding

Restart Jenkins if required.

---

# 14. Configure Jenkins Agent

Go to:

```text
Manage Jenkins
→ Nodes
→ New Node
```

Create a node named:

```text
python-agent
```

Select:

```text
Permanent Agent
```

Configure:

```text
Remote root directory:
/home/ubuntu/jenkins
```

Label:

```text
python-agent
```

Launch method:

```text
Launch agents via SSH
```

Host:

```text
<AGENT-IP>
```

Configure SSH credentials for the `ubuntu` user using the private key corresponding to the public key placed in:

```text
/home/ubuntu/.ssh/authorized_keys
```

Save the configuration.

The node should become:

```text
python-agent
    Connected
```

---

# 15. Configure Docker Hub Credentials

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
Password: <DockerHub access token>
```

Set the credential ID to:

```text
dockerhub
```

The Jenkinsfile uses this credential ID:

```groovy
credentialsId: 'dockerhub'
```

Using a Docker Hub access token instead of your account password is recommended.

---

# 16. Docker Image

The pipeline creates:

```text
shravani2001/python:latest
```

The image is pushed to Docker Hub.

Make sure the Docker Hub repository exists and that the credentials have permission to push to it.

---

# 17. Dockerfile

The project should contain a `Dockerfile`.

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

The `CMD` and exposed port must match the actual Python application.

For example, if the application uses another entry point or port, modify the Dockerfile and deployment command accordingly.

---

# 18. Jenkins Pipeline

Create a new Jenkins Pipeline job:

```text
Jenkins
→ New Item
→ python-cicd
→ Pipeline
```

Select:

```text
Pipeline
→ Definition
→ Pipeline script
```

Use the following Jenkinsfile:

```groovy
pipeline {

    agent {
        label 'python-agent'
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
# here if we don't use venv then the build will fail because the Jenkins user may not have enough permissions to use the pip
# So on using venv our python project gets separate env and it has its own pip when activated, rather than system pip so our build wont fail
        stage('Build') {
            steps {
                sh '''
                    python3 -m venv venv # 

                    . venv/bin/activate

                    pip install -r requirements.txt
                '''
            }
        }
# Here we are activating is again, because each jenkins sh run in separate shell and doesnot keep the vitual env activated for next stage
# when sh command finishes, that shell exits. so we reactivate it in test stage. And as venv is already created we just activate it again.
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
                        docker login \
                        -u "$DOCKER_USERNAME" \
                        --password-stdin
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

# 19. Pipeline Flow

The pipeline executes the following stages:

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

---

## Stage 1 — Clone

```groovy
stage('Clone') {
    steps {
        git branch: 'main',
            url: 'https://github.com/Code-with-Shravani25/python-code-with-test-cases.git'
    }
}
```

Jenkins clones the GitHub repository into the Jenkins workspace.

---

## Stage 2 — Build

```bash
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

This creates a Python virtual environment:

```text
venv/
```

and installs the project's dependencies.

---

## Stage 3 — Test

```bash
. venv/bin/activate
pytest -v
```

The test cases are executed using pytest.

If the tests fail, the pipeline stops.

```text
Build
  ↓
Test
  ↓
FAIL
  ↓
Pipeline stops
```

Therefore, a Docker image will not be created when the tests fail.

---

# 20. Docker Image Stage

The pipeline executes:

```bash
docker build -t ${IMAGE_NAME}:latest .
```

Because the pipeline uses:

```groovy
agent {
    label 'python-agent'
}
```

the Docker build happens on **EC2-2**, not the Jenkins Controller.

The image will be:

```text
shravani2001/python:latest
```

---

# 21. Docker Login

Jenkins retrieves the credentials stored with ID:

```text
dockerhub
```

The password/token is injected into:

```text
DOCKER_PASSWORD
```

The username is injected into:

```text
DOCKER_USERNAME
```

Then:

```bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
```

logs Docker into Docker Hub without putting the password directly into the Jenkinsfile.

---

# 22. Docker Push

The image is pushed using:

```bash
docker push ${IMAGE_NAME}:latest
```

Result:

```text
EC2-2
   |
   | docker push
   v
Docker Hub
   |
   v
shravani2001/python:latest
```

---

# 23. Deploy

The existing container is removed:

```bash
docker rm -f python-app || true
```

The new container is started:

```bash
docker run -d \
    --name python-app \
    -p 5000:5000 \
    ${IMAGE_NAME}:latest
```

The application is now running inside a Docker container on EC2-2.

---

# 24. Verify Deployment

SSH into EC2-2:

```bash
ssh -i your-key.pem ubuntu@<AGENT-IP>
```

Check the container:

```bash
docker ps
```

You should see:

```text
python-app
```

Check logs:

```bash
docker logs python-app
```

Check the image:

```bash
docker images
```

You should see:

```text
shravani2001/python
```

---

# 25. Access the Application

If your Python application listens on port `5000`, allow port `5000` in the EC2-2 Security Group.

Add:

```text
Type: Custom TCP
Port: 5000
Source: Your IP
```

Then access:

```text
http://<AGENT-PUBLIC-IP>:5000
```

---

# 26. Complete CI/CD Process

The final process is:

```text
Developer
    |
    | git push
    v
GitHub
    |
    | Clone
    v
Jenkins Controller
    |
    | SSH
    v
Jenkins Agent
    |
    +-------------------+
    |                   |
    v                   v
 Python Build        Python Test
                         |
                         | Test Passed
                         v
                  Docker Build
                         |
                         v
                    Docker Login
                         |
                         v
                    Docker Push
                         |
                         v
                    Docker Hub
                         |
                         | Pull/Deploy
                         v
                  Docker Container
                         |
                         v
                  Python Application
```

---

# 27. Important Concepts Learned

This project demonstrates:

### Jenkins

* Jenkins Controller
* Jenkins Agent
* Pipeline
* Declarative Pipeline
* Jenkins credentials
* Pipeline stages

### Git

* GitHub repository
* Branch checkout
* Source-code cloning

### Python

* Python virtual environment
* pip
* requirements.txt
* pytest
* Python application packaging

### SSH

* SSH key generation
* Public/private key authentication
* Jenkins-to-agent communication
* `authorized_keys`

### Docker

* Dockerfile
* Docker image
* Docker build
* Docker login
* Docker push
* Docker run
* Docker container deployment

### Docker Hub

```text
Jenkins Agent
      |
      | docker push
      v
Docker Hub
      |
      | image
      v
Production Container
```

---

# 28. Final Environment

| Component     |        EC2-1 |            EC2-2 |
| ------------- | -----------: | ---------------: |
| Ubuntu        |            ✅ |                ✅ |
| Java          |            ✅ |                ✅ |
| Jenkins       |            ✅ |                ❌ |
| Git           |            ✅ |                ✅ |
| Python        | Not required |                ✅ |
| pip           | Not required |                ✅ |
| Docker        |            ❌ |                ✅ |
| Jenkins Agent |   Controller |   `python-agent` |
| Application   |            ❌ | Docker container |

---

# 29. Final Pipeline

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

The important design principle is that **Jenkins Controller manages the pipeline, while the `python-agent` EC2 performs the actual Python and Docker work**.
