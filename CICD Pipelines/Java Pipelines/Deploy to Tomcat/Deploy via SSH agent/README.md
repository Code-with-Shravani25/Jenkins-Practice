# Jenkins CI/CD Pipeline using SSH Agent (Static Agent)

## Project Overview

This project demonstrates how to create a Jenkins CI/CD pipeline that performs the following tasks:

* Checkout source code from GitHub
* Build a Java Maven application
* Run unit tests
* Package the application as a WAR file
* Deploy the WAR file to an Apache Tomcat server

In this approach, the Jenkins pipeline runs on a **Jenkins SSH Agent (Static Agent)** instead of the Jenkins Controller.

---

# Architecture

```
                    GitHub
                       │
                       ▼
             Jenkins Controller (EC2-1)
                    │
              SSH (Port 22)
                    ▼
          Jenkins SSH Agent (EC2-2)
     Java + Git + Maven + Tomcat
                    │
        Checkout → Build → Test
                    │
               Package WAR
                    │
             Deploy to Tomcat
```

---

# Infrastructure

## EC2-1 (Jenkins Controller)

Install:

* Java
* Jenkins

Purpose:

* Manages Jenkins
* Schedules pipeline execution
* Connects to SSH Agent

---

## EC2-2 (SSH Agent + Tomcat)

Install:

* Java
* Git
* Maven
* Apache Tomcat

Purpose:

* Executes the complete pipeline
* Builds the application
* Deploys the application to Tomcat

---

# Prerequisites

* AWS EC2 Instances
* GitHub Repository
* Jenkins Installed
* Java Installed
* Maven Installed
* Apache Tomcat Installed
* SSH Enabled
* Port 22 Open
* Port 8080/8081 Open
* GitHub Repository containing Java Maven project

---

# Step 1 - Install Jenkins Controller

Install Java

```bash
sudo apt update
sudo apt install openjdk-21-jdk -y
```

Install Jenkins

```bash
sudo apt install jenkins -y

sudo systemctl enable jenkins

sudo systemctl start jenkins
```

Verify

```bash
java -version

systemctl status jenkins
```

---

# Step 2 - Configure SSH Agent Server

Install Java

```bash
sudo apt install openjdk-21-jdk -y
```

Install Git

```bash
sudo apt install git -y
```

Install Maven

```bash
sudo apt install maven -y
```

Install Apache Tomcat.

Verify

```bash
java -version

git --version

mvn -version
```

---

# Step 3 - Configure Passwordless SSH

Generate SSH Key on Jenkins Controller

```bash
ssh-keygen
```

Keys generated

```
~/.ssh/id_rsa

~/.ssh/id_rsa.pub
```

Display public key

```bash
cat ~/.ssh/id_rsa.pub
```

Copy the output.

On SSH Agent

```bash
mkdir -p ~/.ssh

nano ~/.ssh/authorized_keys
```

Paste the public key.

Give permissions

```bash
chmod 700 ~/.ssh

chmod 600 ~/.ssh/authorized_keys
```

Test SSH

```bash
ssh ubuntu@<SSH-Agent-IP>
```

Successful login means passwordless SSH is configured.

---

# Step 4 - Configure Jenkins SSH Agent

Go to

```
Manage Jenkins

↓

Nodes

↓

New Node
```

Enter

```
Node Name

linux-agent
```

Choose

```
Permanent Agent
```

Remote Root Directory

```
/home/ubuntu/jenkins
```

Labels

```
linux
```

Launch Method

```
Launch agents via SSH
```

Host

```
<SSH-Agent-IP>
```

Credentials

```
SSH Username with Private Key
```

Username

```
ubuntu
```

Private Key

```
Paste id_rsa
```

Save.

The node should become **Online**.

---

# Step 5 - Configure Jenkins Tools

Go to

```
Manage Jenkins

↓

Tools
```

Configure

* JDK
* Maven

---

# Step 6 - Create Pipeline Job

Create

```
New Item

↓

Pipeline
```

Configure Git repository.

Use the Jenkinsfile from the repository.

---

# Step 7 - Jenkins Pipeline

```groovy
pipeline {

    agent {
        label 'ssh'
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

        stage('Deploy') {
            steps {
                sh '''
                cp target/*.war /opt/tomcat/webapps/

                cd /opt/tomcat/bin

                ./shutdown.sh || true

                sleep 5

                ./startup.sh
                '''
            }
        }

    }

}
```

---

# Pipeline Execution Flow

### Stage 1

Checkout source code from GitHub.

---

### Stage 2

Compile Java source code.

```
mvn clean compile
```

---

### Stage 3

Run unit tests.

```
mvn test
```

---

### Stage 4

Package application.

```
mvn package
```

WAR file is generated.

```
target/*.war
```

---

### Stage 5

Deploy WAR file.

The WAR is copied into

```
/opt/tomcat/webapps/
```

Tomcat is restarted.

---

# Verification

Open

```
http://<Tomcat-IP>:8080/<application-name>
```

or

```
http://<Tomcat-IP>:8081/<application-name>
```

depending on your Tomcat configuration.

---

# Pipeline Flow Diagram

```
Developer
     │
     ▼
GitHub Repository
     │
     ▼
Jenkins Controller
     │
     │ SSH
     ▼
SSH Agent
     │
     ├── Checkout
     ├── Build
     ├── Test
     ├── Package
     └── Deploy to Tomcat
```

---

# Advantages of SSH Agent

* Distributed builds
* Offloads build workload from Jenkins Controller
* Better scalability
* Easier maintenance
* Suitable for multiple build servers
* Supports different operating systems and build environments

---

# Key Difference from SSH Deployment

| SSH Agent                                                        | SSH from Pipeline                                                                |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Entire pipeline runs on the remote Jenkins agent.                | Pipeline runs on the Jenkins controller.                                         |
| Jenkins connects to the agent using SSH before the build starts. | SSH is used only during deployment.                                              |
| Build, Test, Package, and Deploy execute on the agent.           | Build, Test, and Package execute on the controller; deployment uses `ssh`/`scp`. |
| Ideal for distributed builds.                                    | Ideal for simple VM-based deployments.                                           |
