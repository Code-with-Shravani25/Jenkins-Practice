# Dynamic agents: Docker agent
# Create Jenkins pipeline that: Uses Docker agents dynamically
# Jenkins Dynamic Docker Agents - Hands-on Lab

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



