# Node.js CI/CD Pipeline Using Jenkins SSH Agent and Docker

This project demonstrates a **Jenkins CI/CD pipeline for a Node.js application** using two EC2 instances.

The Jenkins controller runs on the first EC2 instance, while the second EC2 instance acts as a **Jenkins SSH agent**. The application is built, containerized, pushed to Docker Hub, and deployed on the agent machine.

## Architecture

```text
                    GitHub
                       |
                       | Clone
                       v
              +------------------+
              | Jenkins Controller|
              |     EC2-1         |
              +------------------+
                       |
                       | SSH
                       |
                       v
              +------------------+
              | Jenkins Agent     |
              |     EC2-2         |
              | Java               |
              | Node.js + npm      |
              | Docker             |
              +------------------+
                       |
             +---------+---------+
             |                   |
             v                   v
        Docker Build       Docker Deploy
             |
             v
        Docker Hub
```

---

# 1. Project Flow

The pipeline performs the following steps:

```text
GitHub
   ↓
Jenkins Controller
   ↓
SSH Agent (EC2-2)
   ↓
Clone Code
   ↓
Install Node.js Dependencies
   ↓
Build Docker Image
   ↓
Login to Docker Hub
   ↓
Push Docker Image
   ↓
Run Docker Container
```

---

# 2. Prerequisites

You need:

* AWS account
* Two Ubuntu EC2 instances
* GitHub repository
* Docker Hub account
* Jenkins
* Java
* Node.js
* npm
* Docker

GitHub repository:

```text
https://github.com/Code-with-Shravani25/Node-App-Code.git
```

Docker Hub image:

```text
shravani2001/nodejsapp
```

---

# 3. EC2 Architecture

We will use two EC2 instances.

| EC2   | Purpose            | Software                   |
| ----- | ------------------ | -------------------------- |
| EC2-1 | Jenkins Controller | Java, Jenkins, Docker      |
| EC2-2 | Jenkins Agent      | Java, Node.js, npm, Docker |

The Jenkins controller connects to EC2-2 through **SSH**.

---

# 4. Launch EC2-1 — Jenkins Controller

Launch an Ubuntu EC2 instance.

Recommended:

```text
OS             : Ubuntu
Instance type  : t2.medium / t3.medium
Storage        : 20 GB
```

Security Group:

```text
SSH       22
Jenkins   8080
```

Connect:

```bash
ssh -i your-key.pem ubuntu@<CONTROLLER-IP>
```

Update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# 5. Install Java on Jenkins Controller

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

---

# 6. Install Jenkins

Add Jenkins repository key:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

Add repository:

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

Update:

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

Enable Jenkins:

```bash
sudo systemctl enable jenkins
```

Check:

```bash
sudo systemctl status jenkins
```

---

# 7. Access Jenkins

Open:

```text
http://<CONTROLLER-IP>:8080
```

Get the initial password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password and complete the Jenkins setup.

Select:

```text
Install suggested plugins
```

Create the Jenkins administrator account.

---

# 8. Install Docker on Jenkins Controller

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

---

# 9. Add Jenkins User to Docker Group

Jenkins needs Docker permissions if Docker commands are going to be executed on the controller.

Run:

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
docker
```

---

# 10. Generate SSH Key on Jenkins Controller

The Jenkins controller will use an SSH key to connect to EC2-2.

Switch to the Jenkins user:

```bash
sudo su - jenkins
```

Generate an SSH key:

```bash
ssh-keygen -t ed25519
```

When prompted:

```text
Enter file in which to save the key:
```

Press **Enter** to accept the default.

For the passphrase, press **Enter** if you want to use an empty passphrase for this Jenkins lab setup.

The keys will be created under:

```text
/var/lib/jenkins/.ssh/
```

Check:

```bash
ls -la ~/.ssh
```

You should see:

```text
id_ed25519
id_ed25519.pub
```

Important:

```text
id_ed25519      → PRIVATE KEY
id_ed25519.pub  → PUBLIC KEY
```

**Never share the private key.**

---

# 11. Copy Public Key

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

It will look similar to:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... jenkins@ip-xxx
```

Copy the entire line.

---

# 12. Launch EC2-2 — Jenkins Agent

Launch another Ubuntu EC2 instance.

Recommended:

```text
OS             : Ubuntu
Instance type  : t2.medium / t3.medium
Storage        : 20 GB
```

Security Group:

```text
SSH 22
```

The controller must be able to SSH to this machine.

Connect to EC2-2:

```bash
ssh -i your-key.pem ubuntu@<AGENT-IP>
```

---

# 13. Install Java on EC2-2

Jenkins SSH agents require Java.

```bash
sudo apt update
```

```bash
sudo apt install openjdk-21-jdk -y
```

Verify:

```bash
java -version
```

---

# 14. Install Node.js and npm

Install:

```bash
sudo apt install nodejs npm -y
```

Verify:

```bash
node -v
```

```bash
npm -v
```

---

# 15. Install Docker on EC2-2

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

---

# 16. Add Jenkins User on EC2-2

The SSH agent process will run using the Jenkins user.

Create the user:

```bash
sudo adduser jenkins
```

You can leave optional account information blank by pressing Enter.

Add Jenkins to Docker group:

```bash
sudo usermod -aG docker jenkins
```

Verify:

```bash
groups jenkins
```

You should see:

```text
docker
```

---

# 17. Add Public Key to EC2-2

On EC2-2, switch to the Jenkins user:

```bash
sudo su - jenkins
```

Create `.ssh`:

```bash
mkdir -p ~/.ssh
```

Set permissions:

```bash
chmod 700 ~/.ssh
```

Open:

```bash
nano ~/.ssh/authorized_keys
```

Paste the **public key from EC2-1**.

Save the file.

Set permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

Exit:

```bash
exit
```

---

# 18. Test SSH Connection

On EC2-1, switch to Jenkins:

```bash
sudo su - jenkins
```

Test:

```bash
ssh jenkins@<AGENT-IP>
```

If successful, you should enter EC2-2 as:

```text
jenkins@<AGENT-IP>
```

Exit:

```bash
exit
```

You can also test using:

```bash
ssh -i ~/.ssh/id_ed25519 jenkins@<AGENT-IP>
```

---

# 19. Configure Jenkins Agent

Open Jenkins:

```text
Manage Jenkins
    ↓
Nodes
    ↓
New Node
```

Create:

```text
Node name: node-agent
```

Select:

```text
Permanent Agent
```

Click **Create**.

---

# 20. Configure Node Agent

Use:

```text
Name:
node-agent
```

Description:

```text
Node.js Docker Jenkins Agent
```

Number of executors:

```text
1
```

Remote root directory:

```text
/home/jenkins
```

Labels:

```text
node-agent
```

Usage:

```text
Only build jobs with matching label expressions
```

Launch method:

```text
Launch agents via SSH
```

Host:

```text
<AGENT-IP>
```

Credentials:

Click:

```text
Add → Jenkins
```

---

# 21. Add SSH Credentials

For the SSH credential:

```text
Kind: SSH Username with private key
```

Username:

```text
jenkins
```

Private Key:

Paste the contents of:

```bash
cat /var/lib/jenkins/.ssh/id_ed25519
```

The private key looks similar to:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
...
-----END OPENSSH PRIVATE KEY-----
```

Add an appropriate ID, for example:

```text
node-agent-ssh
```

Save the credential.

---

# 22. Complete Agent Configuration

Back in the node configuration, select:

```text
Credentials:
node-agent-ssh
```

Host Key Verification Strategy can be configured according to your environment. For a temporary lab setup, a non-verifying strategy is commonly used, but production environments should use proper host-key verification.

Save the configuration.

Jenkins should attempt to connect to EC2-2.

---

# 23. Verify Agent Connection

Go to:

```text
Manage Jenkins
→ Nodes
→ node-agent
```

The node should show:

```text
Connected
```

If it is connected, Jenkins can now execute pipeline commands on EC2-2.

---

# 24. Install Jenkins Plugins

Go to:

```text
Manage Jenkins
→ Plugins
```

Install:

```text
Docker Pipeline
Git
Pipeline
Credentials Binding
SSH Build Agents
```

Restart Jenkins if requested.

---

# 25. Add Docker Hub Credentials

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
Password: <DockerHub Access Token>
ID: dockerhub
```

The important value is:

```text
ID = dockerhub
```

The Jenkinsfile uses this ID.

---

# 26. Create Jenkins Pipeline

Create a new Jenkins job:

```text
New Item
```

Name:

```text
NodeJS-Docker-Pipeline
```

Select:

```text
Pipeline
```

Click:

```text
OK
```

Under **Pipeline**, select:

```text
Definition:
Pipeline script
```

---

# 27. Jenkinsfile

Use the following pipeline:

```groovy
pipeline {

    agent {
        label 'node-agent'
    }

    environment {
        IMAGE_NAME = 'shravani2001/nodejsapp'
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/Node-App-Code.git'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    npm ci
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
                    docker rm -f nodejsapp || true

                    docker run -d \
                        --name nodejsapp \
                        -p 3000:3000 \
                        ${IMAGE_NAME}:latest
                '''
            }
        }
    }
}
```

> Note: I corrected `npm install ci` to `npm ci`. `npm install ci` is not the standard command for a CI dependency installation.

---

# 28. Understand the Agent Configuration

The important part is:

```groovy
agent {
    label 'node-agent'
}
```

This tells Jenkins:

```text
Run this pipeline on the Jenkins node
whose label is node-agent.
```

Therefore, the Docker and npm commands execute on **EC2-2**, not on the Jenkins controller.

---

# 29. Stage 1 — Clone

```groovy
stage('Clone') {
    steps {
        git branch: 'main',
            url: 'https://github.com/Code-with-Shravani25/Node-App-Code.git'
    }
}
```

Jenkins clones the Node.js application from GitHub into the workspace on EC2-2.

---

# 30. Stage 2 — Build

```groovy
stage('Build') {
    steps {
        sh '''
            npm ci
        '''
    }
}
```

This installs the Node.js dependencies from the lockfile.

The agent must have:

```text
Node.js
npm
package.json
package-lock.json
```

---

# 31. Stage 3 — Docker Image

```groovy
stage('DockerImage') {
    steps {
        sh '''
            docker build -t ${IMAGE_NAME}:latest .
        '''
    }
}
```

The Docker image is created on **EC2-2**.

Image:

```text
shravani2001/nodejsapp:latest
```

---

# 32. Stage 4 — Docker Login

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'dockerhub',
        usernameVariable: 'DOCKER_USERNAME',
        passwordVariable: 'DOCKER_PASSWORD'
    )
])
```

Jenkins securely retrieves the Docker Hub credentials.

Then:

```bash
echo "$DOCKER_PASSWORD" | \
docker login -u "$DOCKER_USERNAME" --password-stdin
```

logs into Docker Hub.

---

# 33. Stage 5 — Docker Push

```groovy
stage('DockerPush') {
    steps {
        sh '''
            docker push ${IMAGE_NAME}:latest
        '''
    }
}
```

The image is pushed to:

```text
Docker Hub
    ↓
shravani2001/nodejsapp:latest
```

---

# 34. Stage 6 — Deploy

First remove the old container:

```bash
docker rm -f nodejsapp || true
```

Then start the new container:

```bash
docker run -d \
    --name nodejsapp \
    -p 3000:3000 \
    ${IMAGE_NAME}:latest
```

The application runs on EC2-2.

---

# 35. Run Pipeline

In Jenkins:

```text
NodeJS-Docker-Pipeline
        ↓
Build Now
```

The pipeline should execute:

```text
Clone
  ↓
Build
  ↓
DockerImage
  ↓
DockerLogin
  ↓
DockerPush
  ↓
Deploy
```

All stages should become:

```text
SUCCESS
```

---

# 36. Verify Docker on EC2-2

SSH into EC2-2:

```bash
ssh -i your-key.pem ubuntu@<AGENT-IP>
```

Check Docker images:

```bash
docker images
```

You should see:

```text
shravani2001/nodejsapp
```

Check containers:

```bash
docker ps
```

You should see:

```text
nodejsapp
```

---

# 37. Check Application Logs

Run:

```bash
docker logs nodejsapp
```

If the application starts successfully, the Node.js server should be listening on its configured port.

---

# 38. Access the Application

Make sure EC2-2's Security Group allows:

```text
TCP 3000
```

Then open:

```text
http://<AGENT-PUBLIC-IP>:3000
```

The Node.js application should be accessible.

---

# 39. Troubleshooting

## Jenkins Agent Offline

Check:

```text
Manage Jenkins
→ Nodes
→ node-agent
```

Verify:

* EC2-2 is running
* Port 22 is accessible
* Java is installed on EC2-2
* SSH username is `jenkins`
* Private key is correct
* Public key exists in `~/.ssh/authorized_keys`
* Remote root directory exists
* Agent label is exactly `node-agent`

---

## SSH Permission Denied

On EC2-2:

```bash
sudo chmod 700 /home/jenkins/.ssh
```

```bash
sudo chmod 600 /home/jenkins/.ssh/authorized_keys
```

Check ownership:

```bash
sudo chown -R jenkins:jenkins /home/jenkins/.ssh
```

Test:

```bash
ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
jenkins@<AGENT-IP>
```

---

## Docker Permission Denied

On EC2-2:

```bash
sudo usermod -aG docker jenkins
```

Restart or start a new Jenkins agent session so the new group membership takes effect.

Verify:

```bash
sudo -u jenkins docker ps
```

---

## `node` or `npm` Not Found

Check:

```bash
node -v
npm -v
```

Then:

```bash
sudo -u jenkins node -v
sudo -u jenkins npm -v
```

If Node.js is installed only for another user, Jenkins will not necessarily have access to it. Install Node.js system-wide or configure the Jenkins NodeJS tool.

---

## `npm ci` Error

Make sure the repository contains:

```text
package.json
package-lock.json
```

If there is no lockfile, either create and commit one or use:

```bash
npm install
```

instead of:

```bash
npm ci
```

---

## Docker Build Error

Check that the repository contains a valid:

```text
Dockerfile
```

Test manually on EC2-2:

```bash
docker build -t nodejsapp .
```

---

## Docker Push Error

Verify:

```text
Docker Hub username
Docker Hub repository
Docker Hub access token
Jenkins credential ID
```

The Jenkins credential ID must match:

```groovy
credentialsId: 'dockerhub'
```

---

# 40. Useful Commands

### Jenkins Controller

```bash
sudo systemctl status jenkins
```

```bash
sudo systemctl restart jenkins
```

```bash
sudo journalctl -u jenkins -f
```

### Docker

```bash
docker ps
```

```bash
docker ps -a
```

```bash
docker images
```

```bash
docker logs nodejsapp
```

```bash
docker rm -f nodejsapp
```

### Node.js

```bash
node -v
```

```bash
npm -v
```

### SSH

```bash
ssh jenkins@<AGENT-IP>
```

---

# 41. Important Security Notes

For this lab:

* Keep the Jenkins controller and agent in a controlled environment.
* Do not share the SSH private key.
* Use a Docker Hub access token instead of your Docker Hub password.
* Do not hard-code Docker Hub credentials inside the Jenkinsfile.
* Restrict SSH access using Security Groups.
* Prefer proper SSH host-key verification for production.
* Avoid exposing Jenkins port `8080` publicly when possible.

---

# 42. Final Architecture

```text
                     GitHub
                        |
                        |
                        v
             +----------------------+
             | Jenkins Controller   |
             | EC2-1                |
             |                      |
             | Java                 |
             | Jenkins              |
             | Docker               |
             +----------+-----------+
                        |
                        | SSH
                        | Private Key
                        v
             +----------------------+
             | Jenkins Agent        |
             | EC2-2                |
             | Label: node-agent    |
             |                      |
             | Java                 |
             | Node.js              |
             | npm                  |
             | Docker               |
             +----------+-----------+
                        |
             +----------+----------+
             |                     |
             v                     v
       Docker Build          Docker Deploy
             |
             v
        Docker Hub
             |
             v
shravani2001/nodejsapp:latest
             |
             v
     Node.js Container
        Port 3000
```

# 43. CI/CD Summary

```text
Developer
    |
    | Push Code
    v
GitHub
    |
    | Clone
    v
Jenkins Controller
    |
    | SSH
    v
Jenkins Agent - EC2-2
    |
    +---- npm ci
    |
    +---- docker build
    |
    +---- docker login
    |
    +---- docker push
    |
    +---- docker run
    |
    v
Node.js Application
    |
    v
Port 3000
```

This setup separates the **Jenkins controller** from the **application build/deployment environment**, with all Node.js and Docker pipeline stages running on the `node-agent` EC2 instance.
