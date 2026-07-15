# Jenkins CI/CD Pipeline for Java Maven Web Application Deployment to Remote Apache Tomcat using SSH

## Project Overview

This project demonstrates an end-to-end CI/CD pipeline using **Jenkins** to automatically build, test, package, and deploy a Java Maven web application to an **Apache Tomcat server running on a remote AWS EC2 instance** using **SSH**.

The pipeline clones the source code from GitHub, compiles the application, executes JUnit test cases, packages the application into a WAR file, securely transfers the WAR file to the remote Tomcat server using SCP, and restarts Tomcat over SSH to deploy the latest version.

Using ssh from pipeline means SSH from Pipeline means Jenkins establishes a secure SSH connection to a remote server directly from a pipeline script to execute commands or transfer files.
---

# Project Architecture

```
                    GitHub Repository
                           │
                           │
                    Git Checkout
                           │
                           ▼
                 Jenkins Controller (EC2)
          Java 21 + Maven + Jenkins Installed
                           │
                           ▼
                  Build (Maven Compile)
                           │
                           ▼
                   Execute Unit Tests
                           │
                           ▼
                    Package WAR File
                           │
                           ▼
                SSH Agent Plugin (Credentials)
                           │
                  SCP WAR File to Remote EC2
                           │
                           ▼
                 Apache Tomcat Server (EC2)
                           │
               Copy WAR into webapps Folder
                           │
                           ▼
                 Restart Apache Tomcat
                           │
                           ▼
                  Application Successfully Deployed
```

---

# Technologies Used

- Jenkins
- Java 21
- Maven
- Apache Tomcat 9
- Git
- GitHub
- Ubuntu EC2
- SSH
- SCP
- AWS EC2

---

# Infrastructure

## EC2 Instance 1

**Purpose**

- Jenkins Controller

### Installed Software

- Java 21
- Maven
- Jenkins
- Git

---

## EC2 Instance 2

**Purpose**

- Apache Tomcat Server

### Installed Software

- Java 21
- Apache Tomcat

Tomcat Installation Directory

```
/opt/tomcat
```

Deployment Directory

```
/opt/tomcat/webapps
```

---

# Prerequisites

## Jenkins Server

Install

- Java
- Maven
- Jenkins

---

## Tomcat Server

Install

- Java
- Apache Tomcat

Move Tomcat

```
/opt/tomcat
```

Start Tomcat

```
cd /opt/tomcat/bin
./startup.sh
```

---

# Configure Tomcat Manager

Edit

```
/opt/tomcat/conf/tomcat-users.xml
```

Add

```xml
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="admin-gui"/>

<user
username="admin"
password="admin123"
roles="manager-gui,manager-script,admin-gui"/>
```

---

# Enable Remote Manager Access

Edit

```
/opt/tomcat/webapps/manager/META-INF/context.xml
```

Comment the Valve section

```xml
<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
allow="127\.\d+\.\d+\.\d+|::1"/>
-->
```

Repeat the same for

```
/opt/tomcat/webapps/host-manager/META-INF/context.xml
```

Restart Tomcat.

---

# Configure Passwordless SSH

Generate SSH key on Jenkins server

```
ssh-keygen
```

Copy public key

```
cat ~/.ssh/id_rsa.pub
```

Paste into

```
~/.ssh/authorized_keys
```

on the Tomcat server.

Verify

```
ssh ubuntu@<Tomcat-IP>
```

---

# Jenkins Configuration

## Configure Tools

Manage Jenkins

→ Tools

Configure

- JDK 21
- Maven 3

---

## Install Plugin

Install

- SSH Agent Plugin

---

## Configure Credentials

Manage Jenkins

→ Credentials

Add

**Kind**

```
SSH Username with private key
```

Username

```
ubuntu
```

Credential ID

```
tomcat
```

Paste the Jenkins private key.

---

# Pipeline Stages

## Checkout

Clone the project from GitHub.

---

## Build

Compile the Java source code.

```
mvn clean compile
```

---

## Test

Execute JUnit test cases.

```
mvn test
```

---

## Package

Generate the WAR file.

```
mvn package
```

---

## Deploy

- Connect to remote EC2 using SSH
- Copy WAR file using SCP
- Restart Tomcat

---

# Jenkins Pipeline

```groovy
pipeline {

    agent any

    tools {
        jdk 'java21'
        maven 'Maven3'
    }

    environment {
        REMOTE_HOST = "172.31.90.43"
        REMOTE_USER = "ubuntu"
        REMOTE_PATH = "/opt/tomcat/webapps"
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

        stage('Deploy to Tomcat') {
            steps {
                sshagent(credentials: ['tomcat']) {

                    sh """
                    scp -o StrictHostKeyChecking=no target/*.war ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}

                    ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
                    "cd /opt/tomcat/bin && ./shutdown.sh || true && sleep 5 && ./startup.sh"
                    """
                }
            }
        }

    }

    post {

        success {
            echo "Application deployed successfully."
        }

        failure {
            echo "Pipeline failed."
        }

    }

}
```

---

# Pipeline Workflow

```
Developer
      │
      ▼
GitHub Repository
      │
      ▼
Jenkins Pipeline
      │
      ├──────── Checkout
      │
      ├──────── Build
      │
      ├──────── Test
      │
      ├──────── Package
      │
      ├──────── SCP WAR File
      │
      └──────── SSH into Remote EC2
                     │
                     ▼
            Restart Apache Tomcat
                     │
                     ▼
           Application Deployed Successfully
```

---

# Project Features

- Fully automated CI/CD pipeline
- Maven build automation
- Automated JUnit testing
- WAR packaging
- Secure deployment using SSH
- Remote deployment using SCP
- Apache Tomcat deployment
- Jenkins Declarative Pipeline
- Jenkins Credentials for secure SSH authentication

---

# Learning Outcomes

After completing this project, you will understand:

- Jenkins Pipeline
- Continuous Integration
- Continuous Deployment
- Maven Build Lifecycle
- WAR Packaging
- JUnit Testing
- Jenkins Credentials
- SSH Agent Plugin
- Secure Remote Deployment
- Apache Tomcat Deployment
- SCP File Transfer
- AWS EC2-based CI/CD Pipeline

---

# Future Enhancements

- Deploy using the Tomcat Manager API instead of restarting the server.
- Add SonarQube for code quality analysis.
- Integrate Nexus Repository for artifact management.
- Scan artifacts with Trivy before deployment.
- Send email notifications after pipeline execution.
- Trigger the pipeline automatically using GitHub webhooks.
- Deploy to Docker containers or Kubernetes (Amazon EKS) for containerized applications.
