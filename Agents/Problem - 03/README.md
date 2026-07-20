# Dynamic agents: Docker agent

There are 2 methods

## Docker Pipeline vs Docker Cloud

| Feature | Docker Pipeline (`agent { docker { image ... } }`) | Docker Cloud |
|---------|------------------------------------------------------|--------------|
| Creates container dynamically | ✅ Yes | ✅ Yes |
| Container exists only during build | ✅ Yes | ✅ Yes |
| Container removed after build | ✅ Yes | ✅ Yes |
| Easy to configure | ✅ Very easy | ❌ Requires more configuration |
| Uses Docker Pipeline plugin | ✅ Yes | ❌ No (uses Docker Plugin / Docker Cloud) |
| Creates a temporary Jenkins agent node | ❌ No | ✅ Yes |
| Better for large-scale environments | ⚠️ Limited | ✅ Yes |

# Create Jenkins pipeline that: Uses Docker agents dynamically
# Method 1: Using Docker Pipeline

## Overview

This project demonstrates how to configure **Jenkins Dynamic Docker Agents**. Instead of running builds directly on the Jenkins server, Jenkins automatically creates a temporary Docker container, executes the pipeline inside it, and removes the container once the build is complete.

---

## Architecture

```text
                +---------------------------+
                |      Jenkins Master       |
                |      EC2 Instance         |
                +------------+--------------+
                             |
                             | Docker API
                             |
               Creates Temporary Container
                             |
                    +--------v---------+
                    | Docker Agent     |
                    | Alpine Container |
                    | Executes Build   |
                    +--------+---------+
                             |
                    Container Removed
```

---

# Prerequisites

* AWS EC2 Instance
* Jenkins Installed
* Java Installed
* Internet Connectivity

---

# Step 1: Install Docker

Connect to the Jenkins EC2 instance.

```bash
ssh -i Demo.pem ec2-user@<Public-IP>
```

Update packages.

### Ubuntu

```bash
sudo apt update -y
```

Install Docker.

### Ubuntu

```bash
sudo apt install docker.io -y
```

Start Docker.

```bash
sudo systemctl start docker
```

Enable Docker.

```bash
sudo systemctl enable docker
```

Verify installation.

```bash
docker --version
```

Expected output

```text
Docker version xx.xx.x
```

---

# Step 2: Test Docker Installation

Run the Hello World container.

```bash
docker run hello-world
```

Expected output

```text
Hello from Docker!
```

---

# Step 3: Allow Jenkins to Access Docker

Check the Jenkins user.

```bash
id jenkins
```

Add Jenkins to the Docker group.

```bash
sudo usermod -aG docker jenkins
```

Restart Jenkins and Docker.

```bash
sudo systemctl restart jenkins
sudo systemctl restart docker
```

Logout.

```bash
exit
```

Reconnect to the EC2 instance.

Switch to the Jenkins user.

```bash
sudo su - jenkins
```

Verify Docker access.

```bash
docker ps
```

If no "permission denied" error appears, Jenkins can communicate with Docker successfully.

---

# Step 4: Install Docker Pipeline Plugin

Open Jenkins.

```
Manage Jenkins
    ↓
Plugins
    ↓
Available Plugins
```

Search for

```
Docker Pipeline
```

Install the plugin and restart Jenkins.

---

# Step 5: Create a Pipeline Job

Navigate to

```
New Item
    ↓
Pipeline
```

Provide a name for the pipeline and save it.

---

# Step 6: Create the First Docker Pipeline

Paste the following pipeline into the Pipeline Script section.

```groovy
pipeline {

    agent {
        docker {
            image 'alpine:latest'
        }
    }

    stages {

        stage('Check OS') {

            steps {

                sh 'hostname'
                sh 'cat /etc/os-release'
                sh 'pwd'
                sh 'sleep 120'

            }

        }

    }

}
```

Save the pipeline and click **Build Now**.

---

# Step 7: Verify Dynamic Docker Agent

Open another terminal while the build is running.

List running containers.

```bash
docker ps
```

Since the pipeline sleeps for 120 seconds, you should see a temporary Alpine container.

Example

```text
CONTAINER ID   IMAGE            STATUS
a12bc34de56    alpine:latest    Up 30 seconds
```

After approximately two minutes, execute:

```bash
docker ps
```

Expected output

```text
CONTAINER ID   IMAGE   STATUS
```

No running containers should be present because Jenkins automatically removes the container after the pipeline finishes.

---

# Understanding the Workflow

```text
Pipeline Started
        │
        ▼
Jenkins Pulls alpine Image
        │
        ▼
Creates Temporary Docker Container
        │
        ▼
Executes Pipeline Commands
        │
        ▼
Pipeline Completes
        │
        ▼
Container Automatically Removed
```

---

# Method 2: Using Cloud

# Jenkins CI/CD Pipeline Using Docker Cloud Dynamic Agents

## Project Overview

This project demonstrates how to configure Jenkins to use Docker Cloud Dynamic Agents. Instead of executing builds on the Jenkins controller, Jenkins dynamically creates a Docker container (agent) whenever a build starts. After the build completes, the container is automatically removed.

---

# Architecture

```
                   GitHub Repository
                          │
                          ▼
                 Jenkins Controller
          (Java + Jenkins + Docker)
                          │
                  Docker Cloud Plugin
                          │
         Creates Dynamic Docker Agent
                          │
          Jenkins Inbound Agent Container
                          │
           Executes Pipeline Stages
                          │
          Container Removed After Build
```

---

# Prerequisites

- AWS EC2 Ubuntu Instance
- Java 21
- Jenkins
- Docker
- Internet Connectivity

---

# Step 1: Install Java

```bash
sudo apt update

sudo apt install openjdk-21-jdk -y

java -version
```

---

# Step 2: Install Jenkins

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

Check status

```bash
systemctl status jenkins
```

---

# Step 3: Install Docker

```bash
sudo apt install docker.io -y

sudo systemctl enable docker

sudo systemctl start docker
```

Verify Docker

```bash
docker --version
```

---

# Step 4: Allow Jenkins to Access Docker

Add Jenkins user to Docker group.

```bash
sudo usermod -aG docker jenkins
```

Restart services.

```bash
sudo systemctl restart docker

sudo systemctl restart jenkins
```

Verify

```bash
sudo su - jenkins

docker ps
```

No permission denied error should appear.

---

# Step 5: Unlock Jenkins

Open

```
http://<EC2-Public-IP>:8080
```

Retrieve the initial password.

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Install Suggested Plugins and create the admin user.

---

# Step 6: Install Required Plugins

Navigate to:

Manage Jenkins

↓

Plugins

Install:

- Docker
- Docker Pipeline
- Docker Commons
- Git

Restart Jenkins.

---

# Step 7: Configure Docker Cloud

Navigate to:

Manage Jenkins

↓

Nodes and Clouds

↓

Clouds

↓

New Cloud

↓

Docker

Configure:

Docker Host URI

```
unix:///var/run/docker.sock
```

Click **Test Connection**.

Expected:

```
Docker API Connected
```

---

# Step 8: Configure Docker Agent Template

Inside Docker Cloud click:

Add Docker Template

Configure:

Docker Image

```
jenkins/inbound-agent:jdk21
```

Label

```
docker-agent
```

Name

```
Docker
```

Remote File System Root

```
/home/jenkins/agent
```

Usage

```
Only build jobs with label expressions matching this node
```

Enable the template and Save.

---

# Step 9: Create Pipeline Job

New Item

↓

Pipeline

Provide a project name.

---

# Step 10: Jenkins Pipeline

```groovy
pipeline {

    agent {
        label 'docker-agent'
    }

    stages {

        stage('Verify Dynamic Agent') {

            steps {

                sh 'hostname'

                sh 'whoami'

                sh 'pwd'

                sh 'java -version'

            }

        }

    }

}
```

Save the pipeline.

---

# Step 11: Build Pipeline

Click

```
Build Now
```

---

# Step 12: Verify Dynamic Docker Agent

While the pipeline is running, execute:

```bash
docker ps
```

Expected:

```
CONTAINER ID

IMAGE

jenkins/inbound-agent:jdk21

STATUS

Up 15 seconds
```

This confirms Jenkins has created a temporary Docker agent.

---

After the build completes:

```bash
docker ps
```

Expected:

```
No running containers
```

The Docker agent is automatically removed.

---

# Pipeline Execution Flow

```
Pipeline Started
        │
        ▼
Jenkins Controller
        │
        ▼
Docker Cloud Plugin
        │
        ▼
Creates Temporary Docker Agent
        │
        ▼
Agent Connects to Jenkins
        │
        ▼
Pipeline Executes
        │
        ▼
Build Completes
        │
        ▼
Docker Agent Removed
```

---

# Difference Between Docker Pipeline Agent and Docker Cloud Agent

| Docker Pipeline | Docker Cloud |
|-----------------|--------------|
| Uses `agent { docker { image ... } }` | Uses `agent { label 'docker-agent' }` |
| Creates a temporary Docker container | Creates a temporary Jenkins agent container |
| Easier to configure | More scalable for enterprise use |
| Suitable for simple pipelines | Suitable for multiple concurrent builds |

---

# Advantages

- Clean build environment for every execution.
- No dependency conflicts between builds.
- Automatic creation and deletion of agents.
- Better resource utilization.
- Easily scalable by adding more Docker agent templates.

---

# Future Enhancements

After verifying the Docker Cloud setup, the same dynamic agent can be extended to:

- Clone source code from GitHub.
- Build a Java Maven project.
- Execute unit tests.
- Package the application.
- Build a Docker image.
- Push the image to Docker Hub.
- Pull and run the Docker image.
- Replace Docker Cloud with Kubernetes Dynamic Agents for production-grade scalability.

---

# Conclusion

Docker Cloud Dynamic Agents allow Jenkins to provision temporary Docker-based build agents on demand. Each build executes inside an isolated container, ensuring a clean environment. After the build finishes, Jenkins automatically removes the agent, making this approach efficient, scalable, and well-suited for CI/CD pipelines.


