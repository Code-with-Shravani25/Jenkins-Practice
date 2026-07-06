# Java Maven Web Application Deployment to Tomcat using Jenkins Pipeline

## Project Overview

This project demonstrates an end-to-end CI/CD pipeline where a Java Maven Web Application is stored in GitHub, built and tested using Jenkins, and automatically deployed to an Apache Tomcat server running on the same EC2 instance.

---

# Architecture

```
GitHub Repository
        │
        ▼
Jenkins Pipeline
        │
        ▼
Checkout Source Code
        │
        ▼
Maven Build
        │
        ▼
Run Unit Tests
        │
        ▼
Generate WAR File
        │
        ▼
Deploy WAR to Tomcat
        │
        ▼
Access Application in Browser
```

---

# Prerequisites

- AWS Account
- GitHub Account
- Java Maven Web Application (WAR Project)
- Jenkinsfile in GitHub Repository

---

# Step 1: Launch an EC2 Instance

Launch an Ubuntu EC2 instance.

Connect to the instance using SSH.

```bash
ssh -i <key.pem> ubuntu@<EC2-Public-IP>
```

Update the server.

```bash
sudo apt update
```

---

# Step 2: Install Java

```bash
sudo apt install openjdk-21-jdk -y
```

Verify Java installation.

```bash
java -version
```

Expected Output

```
openjdk version "21"
```

---

# Step 3: Install Jenkins

Import Jenkins Key

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

Add Jenkins Repository

```bash
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
```

Install Jenkins

```bash
sudo apt update
sudo apt install jenkins -y
```

Start Jenkins

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Check Status

```bash
sudo systemctl status jenkins
```

Open Security Group

Allow TCP Port

```
8080
```

Access Jenkins

```
http://<EC2-Public-IP>:8080
```

---

# Step 4: Install Maven

```bash
sudo apt install maven -y
```

Verify Installation

```bash
mvn -version
```

---

# Step 5: Install Apache Tomcat

Download Tomcat Binary

```bash
cd /opt

sudo wget https://downloads.apache.org/tomcat/tomcat-10/v10.1.44/bin/apache-tomcat-10.1.44.tar.gz
```

Extract

```bash
sudo tar -xvf apache-tomcat-10.1.44.tar.gz
```

Rename Directory

```bash
sudo mv apache-tomcat-10.1.44 tomcat
```

---

# Step 6: Change Tomcat Port (8080 → 8081)

Since Jenkins is already running on Port 8080, change Tomcat to Port 8081.

Open

```bash
sudo nano /opt/tomcat/conf/server.xml
```

Find

```xml
<Connector port="8080"
```

Replace with

```xml
<Connector port="8081"
           protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"/>
```

Save the file.

---

# Step 7: Give Execute Permission

```bash
sudo chmod +x /opt/tomcat/bin/*.sh
```

---

# Step 8: Start Tomcat

```bash
sudo /opt/tomcat/bin/startup.sh
```

Verify

```bash
ps -ef | grep tomcat
```

---

# Step 9: Open Port 8081

Edit the EC2 Security Group.

Add an inbound rule.

| Type | Port |
|------|------|
| Custom TCP | 8081 |

---

# Step 10: Verify Jenkins and Tomcat

Jenkins

```
http://<EC2-Public-IP>:8080
```

Tomcat

```
http://<EC2-Public-IP>:8081
```

Both applications should be accessible.

---

# Step 11: Configure Tomcat User Manager

Open

```bash
sudo nano /opt/tomcat/conf/tomcat-users.xml
```

Before the closing tag `</tomcat-users>`, add:

```xml
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="admin-gui"/>

<user username="admin"
      password="admin123"
      roles="manager-gui,manager-script,admin-gui"/>
```

Save the file.

---

# Step 12: Allow Remote Access to Tomcat Manager

Open

```bash
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
```

Comment the Valve section.

```xml
<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
allow="127\.\d+\.\d+\.\d+|::1"/>
-->
```

Save the file.

---

# Step 13: Configure Host Manager

Open

```bash
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
```

Comment the same Valve section.

```xml
<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
allow="127\.\d+\.\d+\.\d+|::1"/>
-->
```

Save the file.

---

# Step 14: Restart Tomcat

```bash
sudo /opt/tomcat/bin/shutdown.sh

sudo /opt/tomcat/bin/startup.sh
```

Access Tomcat Manager

```
http://<EC2-Public-IP>:8081/manager/html
```

Login using

Username

```
admin
```

Password

```
admin123
```

---

# Step 15: Give Jenkins Permission to Deploy

Since Jenkins copies the WAR file into Tomcat's `webapps` directory, it needs write permission.

```bash
sudo chown -R jenkins:jenkins /opt/tomcat/webapps
```

Verify

```bash
ls -ld /opt/tomcat/webapps
```

---

# Step 16: Configure Jenkins Tools

Open

```
Manage Jenkins
```

↓

```
Tools
```

Configure

- JDK
- Maven

Example

| Tool | Name |
|------|------|
| JDK | jdk21 |
| Maven | maven3 |

Save the configuration.

---

# Step 17: Create a Pipeline

Create a new Jenkins Pipeline.

Pipeline Configuration

- Definition → Pipeline script from SCM
- SCM → Git
- Repository URL → GitHub Repository
- Branch → main
- Script Path → Jenkinsfile

Save the pipeline.

OR 
pipeline
```bash
pipeline {

    agent any

    stages {

        stage('Clone') {
            steps {
                git ''
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
                sh '''
                cp target/*.war /opt/tomcat/webapps/
                '''
            }
        }
    }

    post {

        success {
            echo 'Application deployed successfully to Tomcat.'
        }

        failure {
            echo 'Pipeline failed.'
        }

        always {
            cleanWs()
        }
    }
}
```

---

# Step 18: Run the Pipeline

Click

```
Build Now
```

Pipeline Stages

```
Checkout

↓

Build

↓

Test

↓

Package

↓

Deploy
```

If successful, Jenkins generates a WAR file and copies it into Tomcat's `webapps` directory.

---

# Step 19: Verify Deployment

Check the deployed files.

```bash
ls /opt/tomcat/webapps
```

Expected Output

```
jenkins-demo-app.war

jenkins-demo-app/
```

---

# Step 20: Access the Application

Open

```
http://<EC2-Public-IP>:8081/jenkins-demo-app
```

The application should load successfully.

---

# Project Workflow

```
Developer
     │
     ▼
Push Code to GitHub
     │
     ▼
Jenkins Pipeline Triggered
     │
     ▼
Checkout Source Code
     │
     ▼
Maven Build
     │
     ▼
Run Unit Tests
     │
     ▼
Generate WAR
     │
     ▼
Deploy WAR to Tomcat
     │
     ▼
Tomcat Auto Deploys Application
     │
     ▼
Application Available in Browser
```

---

# Technologies Used

- AWS EC2
- Ubuntu Linux
- GitHub
- Git
- Java 17
- Maven
- Jenkins
- Apache Tomcat 10
- Jenkins Pipeline (Declarative)
- WAR Deployment
- CI/CD
