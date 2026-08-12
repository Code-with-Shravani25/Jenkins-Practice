# Jenkins CI/CD Pipeline with Docker Dynamic Agents

This project demonstrates a Jenkins CI/CD pipeline for a Java Maven
application using a **Docker Cloud dynamic agent**.

The pipeline:

1.  Checks out the Java Maven application from GitHub.
2.  Compiles the application.
3.  Runs unit tests.
4.  Packages the application with Maven.
5.  Builds a Docker image.
6.  Logs in to Docker Hub.
7.  Pushes the image to Docker Hub.
8.  Pulls the image back from Docker Hub.
9.  Runs the application as a Docker container.

> **Important:** The attached Jenkins Docker Cloud configuration uses
> the label `docker-agent`. Therefore, the pipeline below uses
> `label 'docker-agent'`. If you configure the cloud template with
> `docker-cloud` instead, change the pipeline label accordingly.

## Architecture

``` text
                    GitHub Repository
                           |
                           | Checkout
                           v
                    +--------------+
                    |    Jenkins   |
                    |  Controller  |
                    +--------------+
                           |
                           | Docker Cloud
                           | creates agent
                           v
              +-----------------------------+
              | Dynamic Docker Agent         |
              | jenkins-maven-docker-agent  |
              |                             |
              | Java 21                     |
              | Maven                       |
              | Docker CLI                  |
              +-----------------------------+
                           |
             +-------------+-------------+
             |                           |
             v                           v
       Maven Build/Test              Docker Build
                                         |
                                         v
                                   Docker Hub
                                         |
                                         | Pull
                                         v
                                  Docker Container
                                         |
                                         v
                                  Java Application
                                    Port 8081
```

## Prerequisites

-   AWS account
-   One EC2 instance
-   Ubuntu/Amazon Linux EC2 instance with sufficient CPU, RAM and disk
-   Java installed
-   Jenkins installed
-   Docker installed
-   GitHub repository containing the Java Maven application
-   Docker Hub account
-   Jenkins Docker-related plugins
-   Jenkins Docker Cloud configuration
-   Docker Hub Personal Access Token

## 1. Launch an EC2 Instance

Launch one EC2 instance to host:

-   Jenkins controller
-   Docker Engine
-   Docker daemon used by the Docker Cloud plugin
-   Dynamic Docker agents

Allow the required ports in the EC2 Security Group. For example:

  Port     Purpose
  -------- -----------------------------
  22       SSH
  8080     Jenkins
  8081     Java application deployment
  80/443   Optional, if required

Do not expose Jenkins or the application publicly unless required.
Restrict source IPs where possible.

Connect to the instance:

``` bash
ssh -i <key.pem> ubuntu@<EC2_PUBLIC_IP>
```

## 2. Install Java

For Ubuntu:

``` bash
sudo apt update
sudo apt install -y openjdk-21-jdk
```

Verify:

``` bash
java -version
```

Expected output should show Java 21.

## 3. Install Jenkins

Add the Jenkins repository and install Jenkins:

``` bash
sudo apt update
sudo apt install -y wget curl fontconfig
wget -O /tmp/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
sudo tee /usr/share/keyrings/jenkins-keyring.asc < /tmp/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
```

Start Jenkins:

``` bash
sudo systemctl enable --now jenkins
```

Check status:

``` bash
sudo systemctl status jenkins
```

Open Jenkins:

``` text
http://<EC2_PUBLIC_IP>:8080
```

## 4. Install Docker

Install Docker:

``` bash
sudo apt update
sudo apt install -y docker.io
```

Enable and start Docker:

``` bash
sudo systemctl enable --now docker
```

Verify:

``` bash
docker --version
sudo systemctl status docker
```

Test Docker:

``` bash
sudo docker run hello-world
```

## 5. Add Jenkins User to Docker Group

Jenkins must be able to communicate with the Docker daemon without using
`sudo`.

Run:

``` bash
sudo usermod -aG docker jenkins
```

Restart Jenkins:

``` bash
sudo systemctl restart jenkins
```

It can also be useful to restart Docker first:

``` bash
sudo systemctl restart docker
sudo systemctl restart jenkins
```

Verify the Jenkins user:

``` bash
groups jenkins
```

The output should include:

``` text
docker
```

You can also test Docker access as Jenkins:

``` bash
sudo -u jenkins docker ps
```

If this returns a permission error, check the Docker socket permissions
and restart Jenkins after adding the group.

## 6. Unlock Jenkins and Complete Setup

Get the initial administrator password:

``` bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open:

``` text
http://<EC2_PUBLIC_IP>:8080
```

Then:

1.  Enter the initial administrator password.
2.  Select **Install suggested plugins** or choose plugins manually.
3.  Create the Jenkins administrator user.
4.  Complete the setup.

## 7. Install Required Jenkins Plugins

Go to:

``` text
Manage Jenkins
→ Plugins
→ Available plugins
```

Install the plugins required for this setup, including:

-   Docker
-   Docker Pipeline
-   Maven Integration
-   Git
-   Credentials Binding
-   Pipeline

Depending on the Jenkins version/plugin architecture, Docker Cloud
functionality may be supplied by the Docker plugin and its dependencies.

Restart Jenkins if requested.

## 8. Configure Maven in Jenkins

Go to:

``` text
Manage Jenkins
→ Tools
```

Configure Maven if you want Jenkins to manage the Maven installation.

Example:

``` text
Name: Maven3
```

Alternatively, the dynamic Docker agent image used in this project
already contains Maven, so the pipeline can directly execute:

``` bash
mvn clean compile
mvn test
mvn package
```

## 9. Configure Docker Hub Credentials

Log in to Docker Hub and create a Personal Access Token.

Use the token instead of your Docker Hub password.

In Jenkins:

``` text
Manage Jenkins
→ Credentials
→ System
→ Global credentials
→ Add Credentials
```

Create:

``` text
Kind: Username with password
Username: <Docker Hub username>
Password: <Docker Hub Personal Access Token>
ID: dockerhub
```

The pipeline uses the credential ID:

``` text
dockerhub
```

## 10. Create the Docker Agent Image

Create a Dockerfile on the EC2 instance:

``` bash
mkdir -p ~/jenkins-docker-agent
cd ~/jenkins-docker-agent

nano Dockerfile
```

Use:

``` dockerfile
FROM jenkins/inbound-agent:jdk21

USER root

RUN apt-get update \
    && apt-get install -y \
        maven \
        docker.io \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
```

### Why this image is used

The image is used as the **dynamic Jenkins build agent**.

It contains:

-   Jenkins inbound agent support
-   Java 21
-   Maven
-   Docker CLI

The Docker CLI allows the pipeline running inside the agent to execute
commands such as:

``` bash
docker build
docker login
docker push
docker pull
docker run
```

The Docker daemon itself remains on the EC2 host. The Docker socket is
mounted into the dynamic agent.

### Build the agent image

``` bash
docker build -t jenkins-maven-docker-agent:latest .
```

Verify:

``` bash
docker images | grep jenkins-maven-docker-agent
```

## 11. Configure Docker Cloud in Jenkins

Go to:

``` text
Manage Jenkins
→ Clouds
→ New cloud
```

Select:

``` text
Docker
```

Configure the cloud as shown in the attached configuration.

### Docker Cloud details

Use:

``` text
Name:
Docker
```

Docker Host URI:

``` text
unix:///var/run/docker.sock
```

The Docker Cloud configuration shown in the attached document uses the
local Docker socket. fileciteturn0file0L1-L1

### Docker Agent Template

Create a Docker Agent Template with:

``` text
Labels:
docker-agent

Name:
Docker

Docker Image:
jenkins-maven-docker-agent:latest

User:
root
```

The attached configuration shows the Docker agent template using the
image `jenkins-maven-docker-agent:latest` and label `docker-agent`.
fileciteturn0file0L1-L1

### Container Mount

The Docker socket needs to be mounted into the dynamic agent:

``` text
type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock
```

This allows Docker commands executed inside the Jenkins agent container
to communicate with the Docker daemon running on the EC2 host.

The attached configuration shows this Docker socket bind mount under
**Mounts**. fileciteturn0file0L1-L1

### Remote File System Root

Set:

``` text
/home/jenkins/agent
```

The attached configuration shows `/home/jenkins/agent` as the remote
file system root. fileciteturn0file0L1-L1

### Usage

Use:

``` text
Only build jobs with label expressions matching this node
```

This ensures that the pipeline requesting `docker-agent` uses this
Docker Cloud template.

### Connect method

Use:

``` text
Attach Docker container
```

The attached configuration uses the **Attach Docker container**
connection method and indicates that the Docker image must contain Java.
fileciteturn0file0L1-L1

### Other recommended settings from the attached configuration

``` text
Container Cap: 100
Idle timeout: 10
Stop timeout: 10
Pull strategy: Never pull
Pull timeout: 300
```

The attached configuration also shows CPU period and CPU quota fields.
Do not enter `0` in fields that require a positive integer; leave them
empty unless you intentionally want to configure CPU limits.
fileciteturn0file0L1-L1

Click:

``` text
Apply
Save
```

## 12. Verify Docker Cloud

Go to:

``` text
Manage Jenkins
→ Clouds
→ Docker
→ Test Connection
```

The connection should be successful.

You can also verify Docker on the EC2 host:

``` bash
docker ps
```

When a pipeline starts, Jenkins should create a temporary Docker agent
container.

## 13. Prepare the Java Maven Application

The pipeline uses:

``` text
https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git
```

The project should contain a valid Maven structure, including:

``` text
pom.xml
src/
```

The Maven package must also produce the artifact expected by the
application's Dockerfile.

For example, if the project creates a WAR file, the application
Dockerfile should copy the WAR into Tomcat. If it creates a JAR file,
the Dockerfile should use a Java runtime image and copy the JAR.

## 14. Application Dockerfile

Create the application Dockerfile in the Java Maven project root.

For a WAR-based Tomcat application:

``` dockerfile
FROM tomcat:10.1-jdk21

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
```

This Dockerfile expects:

``` text
target/*.war
```

to exist after:

``` bash
mvn package
```

## 15. Jenkins Pipeline

Create a new Jenkins Pipeline job:

``` text
Dashboard
→ New Item
→ Pipeline
```

Select:

``` text
Pipeline
```

Under **Pipeline → Definition**, select:

``` text
Pipeline script
```

Use the following pipeline:

``` groovy
pipeline {

    agent {
        label 'docker-agent'
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

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push ${IMAGE_NAME}:latest'
            }
        }

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

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
```

## 16. Pipeline Stage Explanation

### Stage 1: Checkout

``` groovy
git branch: 'main',
    url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
```

Jenkins clones the source code from GitHub.

### Stage 2: Build

``` bash
mvn clean compile
```

This:

-   Deletes previous Maven build output.
-   Compiles the Java source code.

### Stage 3: Test

``` bash
mvn test
```

This runs the application's unit tests.

If tests fail, the pipeline stops and the Docker image is not created.

### Stage 4: Package

``` bash
mvn package
```

This packages the application.

For a WAR project, the output is normally placed under:

``` text
target/
```

### Stage 5: Docker Build

``` bash
docker build -t ${IMAGE_NAME}:latest .
```

Jenkins builds the application Docker image.

Example:

``` text
shravani2001/javademo:latest
```

### Stage 6: Docker Login

Jenkins retrieves the Docker Hub username and Personal Access Token from
the Jenkins credential:

``` text
dockerhub
```

The token is passed securely through:

``` bash
--password-stdin
```

### Stage 7: Push Image

``` bash
docker push shravani2001/javademo:latest
```

The image is pushed to Docker Hub.

### Stage 8: Deploy

The pipeline:

1.  Stops the previous container.
2.  Removes the previous container.
3.  Pulls the latest image from Docker Hub.
4.  Starts a new container.

``` bash
docker pull ${IMAGE_NAME}:latest

docker run -d \
    --name java-app \
    -p 8081:8080 \
    ${IMAGE_NAME}:latest
```

The application is exposed on:

``` text
http://<EC2_PUBLIC_IP>:8081
```

## 17. Run the Pipeline

Click:

``` text
Build Now
```

Watch:

``` text
Build Now
→ Console Output
```

You should see the stages:

``` text
Checkout
Build
Test
Package
Docker Build
Docker Login
Push Image
Deploy
```

## 18. Verify Dynamic Docker Agent

On the EC2 instance, run:

``` bash
docker ps
```

While the pipeline is executing, you should see the dynamically created
Jenkins agent container.

The agent is temporary and is created for the Jenkins job according to
the Docker Cloud template.

After the job finishes, Jenkins can remove the agent depending on the
configured cloud/agent lifecycle settings.

## 19. Verify Docker Image

On the EC2 instance:

``` bash
docker images
```

You should see:

``` text
shravani2001/javademo
```

Verify Docker Hub by checking the repository:

``` text
shravani2001/javademo
```

## 20. Verify Running Container

Run:

``` bash
docker ps
```

Expected container:

``` text
java-app
```

Check logs:

``` bash
docker logs java-app
```

For a Tomcat application, you should see Tomcat startup messages.

## 21. Verify Application

Open:

``` text
http://<EC2_PUBLIC_IP>:8081
```

The port mapping is:

``` text
EC2:8081 → Container:8080
```

Therefore:

``` text
Browser
   |
   | :8081
   v
EC2 Docker Host
   |
   | 8081:8080
   v
Java Application Container
   |
   | :8080
   v
Tomcat / Java Application
```

## 22. Useful Troubleshooting Commands

### Check Jenkins

``` bash
sudo systemctl status jenkins
```

### Check Docker

``` bash
sudo systemctl status docker
```

### Check Jenkins Docker permission

``` bash
sudo -u jenkins docker ps
```

### Check Docker socket

``` bash
ls -l /var/run/docker.sock
```

### Check Jenkins group

``` bash
groups jenkins
```

### Check running containers

``` bash
docker ps
```

### Check all containers

``` bash
docker ps -a
```

### Check agent image

``` bash
docker images | grep jenkins-maven-docker-agent
```

### Check application image

``` bash
docker images | grep javademo
```

### Check application logs

``` bash
docker logs java-app
```

### Check application port

``` bash
curl http://localhost:8081
```

## 23. Common Problems

### Problem 1: `docker: permission denied`

Check:

``` bash
groups jenkins
```

If `docker` is missing:

``` bash
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins
```

### Problem 2: Jenkins does not find `docker-agent`

Make sure the Docker Cloud template label and pipeline label match.

Cloud template:

``` text
docker-agent
```

Pipeline:

``` groovy
agent {
    label 'docker-agent'
}
```

Do not use `docker-cloud` in the pipeline unless the cloud template is
actually configured with that label.

### Problem 3: `mvn: not found`

Verify Maven exists in the agent:

``` bash
docker run --rm jenkins-maven-docker-agent:latest mvn -version
```

If it is missing, rebuild the agent image.

### Problem 4: `docker: not found` inside the agent

Verify Docker CLI:

``` bash
docker run --rm jenkins-maven-docker-agent:latest docker --version
```

The agent image must contain Docker CLI.

### Problem 5: Docker commands inside the agent cannot connect to Docker

Verify that the Docker socket is mounted:

``` text
type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock
```

Also verify the Docker daemon is running on the EC2 host:

``` bash
sudo systemctl status docker
```

### Problem 6: Docker push authentication failed

Verify:

-   Docker Hub username is correct.
-   Personal Access Token is valid.
-   Jenkins credential ID is `dockerhub`.
-   The Docker Hub repository exists or your account has permission to
    create/push to it.
-   The token has appropriate repository permissions.

### Problem 7: `COPY target/*.war` fails

Run:

``` bash
mvn package
ls -l target/
```

Check whether the project produces:

``` text
target/*.war
```

If it produces a JAR instead, update the application Dockerfile
accordingly.

### Problem 8: Port 8081 is already in use

Check:

``` bash
sudo ss -lntp | grep 8081
```

Or:

``` bash
docker ps
```

Stop the conflicting container/process before deployment.

## 24. Important Security Note

The Docker socket mount:

``` text
/var/run/docker.sock
```

gives the Jenkins agent access to the host Docker daemon. This is
powerful and should be treated as a privileged capability.

Use this setup for a controlled lab/learning environment or carefully
secure it for production.

Also:

-   Do not store Docker Hub passwords directly in the Jenkinsfile.
-   Use Jenkins Credentials.
-   Use Docker Hub Personal Access Tokens.
-   Do not commit tokens to GitHub.
-   Restrict EC2 Security Group access.
-   Prefer immutable image tags such as build numbers or Git commit SHA
    for production deployments instead of relying only on `latest`.

## 25. End-to-End Flow

``` text
Developer
    |
    v
GitHub
    |
    | Checkout
    v
Jenkins
    |
    | Docker Cloud
    v
Dynamic Docker Agent
    |
    +--> mvn clean compile
    |
    +--> mvn test
    |
    +--> mvn package
    |
    +--> docker build
    |
    +--> docker login
    |
    +--> docker push
    |
    v
Docker Hub
    |
    | docker pull
    v
EC2 Docker Host
    |
    | docker run
    v
Java Application Container
    |
    v
Port 8081
```

## 26. Final Result

After a successful Jenkins build:

``` text
GitHub
   ↓
Checkout
   ↓
Compile
   ↓
Test
   ↓
Package
   ↓
Build Docker Image
   ↓
Login to Docker Hub
   ↓
Push Image
   ↓
Pull Image
   ↓
Run Container
   ↓
Java Maven Application
```

The key concept demonstrated by this project is that Jenkins does
**not** execute the build directly on a permanent build node. Instead,
Jenkins uses Docker Cloud to create a temporary Docker-based agent,
performs the Maven and Docker operations inside that agent, and then
deploys the resulting image through the Docker daemon on the EC2 host.
