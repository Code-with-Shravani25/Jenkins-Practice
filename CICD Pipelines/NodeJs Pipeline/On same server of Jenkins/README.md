# Node.js CI/CD Pipeline with Jenkins and Docker

This project demonstrates a simple **CI/CD pipeline for a Node.js application** using:

* AWS EC2
* Jenkins
* Node.js & npm
* Docker
* Docker Hub
* GitHub

The Jenkins pipeline will:

**Clone → Install Dependencies → Build Docker Image → Login to Docker Hub → Push Image → Deploy Container**

---

## 1. Architecture

```text
GitHub Repository
       |
       | Clone
       v
    Jenkins
       |
       | npm install
       v
Node.js Application
       |
       | docker build
       v
 Docker Image
       |
       | docker push
       v
  Docker Hub
       |
       | docker run
       v
Docker Container
       |
       | Port 3000
       v
Node.js Application
```

---

## 2. Prerequisites

You need:

* AWS account
* EC2 instance
* GitHub repository
* Docker Hub account
* Jenkins
* Java
* Node.js
* npm
* Docker

GitHub repository used in this project:

```text
https://github.com/Code-with-Shravani25/Node-App-Code.git
```

Docker Hub image:

```text
shravani2001/nodejsapp
```

---

# 3. Launch EC2 Instance

Launch an EC2 instance with:

| Setting       | Value                  |
| ------------- | ---------------------- |
| OS            | Ubuntu                 |
| Instance type | t2.medium or t3.medium |
| Storage       | 20 GB recommended      |
| SSH           | Port 22                |
| Jenkins       | Port 8080              |
| Node.js App   | Port 3000              |

Add the following inbound rules to the Security Group:

```text
SSH       22      My IP
Jenkins   8080    Your IP / 0.0.0.0/0
Node.js   3000    Your IP / 0.0.0.0/0
```

For production environments, avoid opening ports to `0.0.0.0/0` unless required.

---

# 4. Connect to EC2

```bash
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

Update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# 5. Install Java

Jenkins requires Java.

Install OpenJDK:

```bash
sudo apt install openjdk-21-jdk -y
```

Verify:

```bash
java -version
```

Check Java location:

```bash
which java
```

---

# 6. Install Jenkins

Add the Jenkins repository key:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

Add the Jenkins repository:

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

# 7. Access Jenkins

Open:

```text
http://<EC2-PUBLIC-IP>:8080
```

Get the initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password and complete the Jenkins setup.

Select:

```text
Install suggested plugins
```

Then create the Jenkins administrator account.

---

# 8. Install Node.js and npm

Install Node.js and npm:

```bash
sudo apt install nodejs npm -y
```

Verify:

```bash
node -v
npm -v
```

However, Jenkins executes pipeline commands using the Jenkins environment. Verify that Jenkins can access Node.js:

```bash
sudo -u jenkins node -v
sudo -u jenkins npm -v
```

If Node.js is installed using a user-specific version manager such as `nvm`, configure Jenkins accordingly. For a simple EC2 setup, installing Node.js system-wide is easier.

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

Check Docker service:

```bash
sudo systemctl status docker
```

---

# 10. Add Jenkins User to Docker Group

By default, Jenkins may not have permission to execute Docker commands.

Add Jenkins to the Docker group:

```bash
sudo usermod -aG docker jenkins
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

You can verify the group:

```bash
groups jenkins
```

You should see:

```text
docker
```

Test Docker as Jenkins:

```bash
sudo -u jenkins docker ps
```

If you get a permission error, restart Jenkins and/or log out and back in before testing again.

---

# 11. Configure Jenkins Plugins

Open Jenkins:

```text
Manage Jenkins
→ Plugins
```

Install the required plugins.

### Required plugins

* Docker Pipeline
* Git
* Pipeline
* Credentials Binding

The Docker Pipeline plugin allows Jenkins pipelines to execute Docker-related operations.

---

# 12. Add Docker Hub Credentials

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
Password: <DockerHub Access Token>
ID: dockerhub
```

Use a **Docker Hub access token** rather than your Docker Hub account password.

The important part is:

```text
Credentials ID = dockerhub
```

This ID is referenced by the Jenkinsfile.

---

# 13. Create Jenkins Pipeline

Create a new Jenkins job:

```text
New Item
```

Enter:

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

Go to the **Pipeline** section.

Select:

```text
Definition: Pipeline script
```

Add the following Jenkinsfile:

```groovy
pipeline {

    agent any

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

Click:

```text
Save
```

---

# 14. Pipeline Stages

## Stage 1 — Clone

```groovy
stage('Clone') {
    steps {
        git branch: 'main',
            url: 'https://github.com/Code-with-Shravani25/Node-App-Code.git'
    }
}
```

Jenkins clones the application source code from GitHub.

---

## Stage 2 — Build

```groovy
stage('Build') {
    steps {
        sh '''
            npm ci
        '''
    }
}
```

`npm ci` installs the dependencies specified in `package-lock.json`.

It is commonly preferred in CI environments because it performs a clean, reproducible dependency installation.

> Note: `npm ci` requires a valid `package-lock.json` (or compatible lockfile) in the repository.

---

## Stage 3 — Docker Image

```groovy
stage('DockerImage') {
    steps {
        sh '''
            docker build -t ${IMAGE_NAME}:latest .
        '''
    }
}
```

This creates the Docker image:

```text
shravani2001/nodejsapp:latest
```

The `.` tells Docker to use the current workspace as the build context.

---

# 15. Docker Login

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'dockerhub',
        usernameVariable: 'DOCKER_USERNAME',
        passwordVariable: 'DOCKER_PASSWORD'
    )
])
```

Jenkins retrieves the Docker Hub credentials securely.

Then:

```bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
```

logs into Docker Hub without exposing the password directly in the command line.

---

# 16. Push Docker Image

```bash
docker push ${IMAGE_NAME}:latest
```

The image is pushed to Docker Hub:

```text
shravani2001/nodejsapp:latest
```

You can verify it in Docker Hub.

---

# 17. Deploy Container

First remove an existing container:

```bash
docker rm -f nodejsapp || true
```

The `|| true` prevents the pipeline from failing if the container doesn't already exist.

Then start the new container:

```bash
docker run -d \
    --name nodejsapp \
    -p 3000:3000 \
    ${IMAGE_NAME}:latest
```

The mapping is:

```text
EC2 Port 3000 → Container Port 3000
```

---

# 18. Run the Pipeline

In Jenkins:

```text
NodeJS-Docker-Pipeline
→ Build Now
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

All stages should show:

```text
SUCCESS
```

---

# 19. Verify Docker Image

On EC2:

```bash
docker images
```

You should see:

```text
shravani2001/nodejsapp
```

---

# 20. Verify Container

Run:

```bash
docker ps
```

Expected:

```text
nodejsapp
```

You can also check:

```bash
docker logs nodejsapp
```

---

# 21. Test the Application

Open:

```text
http://<EC2-PUBLIC-IP>:3000
```

Your Node.js application should be accessible.

If it doesn't load, check:

```bash
docker ps
```

```bash
docker logs nodejsapp
```

and verify that EC2 Security Group allows TCP port `3000`.

---

# 22. Useful Docker Commands

Check running containers:

```bash
docker ps
```

Check all containers:

```bash
docker ps -a
```

View logs:

```bash
docker logs nodejsapp
```

Stop container:

```bash
docker stop nodejsapp
```

Remove container:

```bash
docker rm nodejsapp
```

Remove image:

```bash
docker rmi shravani2001/nodejsapp:latest
```

Check Docker images:

```bash
docker images
```

---

# 23. Troubleshooting

### Docker permission denied

If Jenkins shows:

```text
permission denied while trying to connect to the Docker daemon
```

Run:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Then test:

```bash
sudo -u jenkins docker ps
```

---

### npm command not found

Check:

```bash
node -v
npm -v
```

Then check specifically for Jenkins:

```bash
sudo -u jenkins node -v
sudo -u jenkins npm -v
```

If the commands are unavailable to Jenkins, make sure Node.js is installed system-wide or configure the Jenkins NodeJS tool/environment.

---

### `npm ci` fails

If you see an error related to the lockfile, verify that the repository contains:

```text
package.json
package-lock.json
```

If there is no `package-lock.json`, use:

```bash
npm install
```

instead, or generate and commit the lockfile:

```bash
npm install
git add package-lock.json
git commit -m "Add package lock"
git push
```

---

### Docker build fails

Check that the repository contains a:

```text
Dockerfile
```

You can test manually:

```bash
docker build -t nodejsapp .
```

---

### Docker push fails

Verify:

```bash
docker login
```

and make sure:

```text
Docker Hub username = shravani2001
Repository = nodejsapp
```

Also ensure the Docker Hub access token has permission to push to the repository.

---

### Application is not accessible

Check the container:

```bash
docker ps
```

Check logs:

```bash
docker logs nodejsapp
```

Check port mapping:

```bash
docker port nodejsapp
```

Expected:

```text
3000/tcp -> 0.0.0.0:3000
```

Also verify EC2 Security Group:

```text
TCP 3000 → Allowed
```

---

# 24. Complete CI/CD Flow

The complete flow is:

```text
Developer
    |
    | git push
    v
GitHub
    |
    | Jenkins Clone
    v
Jenkins
    |
    | npm ci
    v
Install Dependencies
    |
    | docker build
    v
Docker Image
    |
    | docker login
    v
Docker Hub
    |
    | docker push
    v
shravani2001/nodejsapp:latest
    |
    | docker run
    v
Node.js Container
    |
    v
Application :3000
```

---

# 25. Technologies Used

| Technology | Purpose                  |
| ---------- | ------------------------ |
| AWS EC2    | Jenkins/Docker server    |
| GitHub     | Source code repository   |
| Jenkins    | CI/CD automation         |
| Node.js    | Application runtime      |
| npm        | Dependency management    |
| Docker     | Containerization         |
| Docker Hub | Container image registry |

---

# 26. Final Result

After a successful Jenkins build:

1. Code is pulled from GitHub.
2. Node.js dependencies are installed.
3. Docker image is created.
4. Jenkins logs into Docker Hub.
5. Docker image is pushed to Docker Hub.
6. Existing application container is removed.
7. New container is started.
8. Application becomes available on port `3000`.

```text
GitHub
   ↓
Jenkins
   ↓
npm ci
   ↓
Docker Build
   ↓
Docker Hub
   ↓
Docker Run
   ↓
Node.js Application
```
