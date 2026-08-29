# Node.js Form Application Deployment Using Jenkins, Docker and MySQL

This project demonstrates how to deploy a **Node.js form application with MySQL** using **Jenkins and Docker**.

The setup uses **2 EC2 instances**:

* **EC2-1:** Jenkins Controller
* **EC2-2:** Jenkins Docker Agent where the application is built and deployed

## Architecture

```text
                    GitHub Repository
                           |
                           |
                           v
                  +------------------+
                  | Jenkins Controller|
                  |     EC2-1         |
                  | Java + Jenkins    |
                  +---------+--------+
                            |
                       SSH Connection
                            |
                            v
                  +------------------+
                  | Jenkins Agent     |
                  |     EC2-2         |
                  | Java              |
                  | Node.js + npm     |
                  | Docker            |
                  +---------+--------+
                            |
                 +----------+----------+
                 |                     |
                 v                     v
          Node.js Container      MySQL Container
             nodeapp                mysql
                 \                     /
                  \                   /
                   +-----------------+
                   | Docker Network  |
                   |     appnet      |
                   +-----------------+

                    Application
                   http://EC2-IP:3000
```

---

# 1. Launch Two EC2 Instances

Launch two Ubuntu EC2 instances.

### EC2-1 – Jenkins Controller

Install:

* Java
* Jenkins

This server will act as the **Jenkins Controller**.

### EC2-2 – Jenkins Agent

Install:

* Java
* Jenkins
* Node.js
* npm
* Docker

This server will act as the **Jenkins Docker Agent**.

## Security Group

Allow the required ports.

| Port | Purpose             |
| ---- | ------------------- |
| 22   | SSH                 |
| 8080 | Jenkins             |
| 3000 | Node.js application |

For testing purposes, these ports can be allowed from your IP address. Avoid exposing unnecessary ports publicly in a production environment.

---

# 2. Configure Jenkins Controller – EC2-1

SSH into the first EC2 instance.

```bash
ssh -i key.pem ubuntu@<JENKINS-EC2-IP>
```

## Install Java

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
```

Check Java:

```bash
java -version
```

## Install Jenkins

Add the Jenkins repository and install Jenkins.

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

```bash
sudo apt update
sudo apt install -y jenkins
```

Start Jenkins:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

Check status:

```bash
sudo systemctl status jenkins
```

Jenkins will be available at:

```text
http://<JENKINS-EC2-IP>:8080
```

---

# 3. Generate SSH Key on Jenkins Controller

Switch to the Jenkins user:

```bash
sudo su - jenkins
```

Generate an SSH key:

```bash
ssh-keygen -t rsa -b 4096
```

Press **Enter** for the default location.

The keys will be created under:

```text
/var/lib/jenkins/.ssh/
```

Check the files:

```bash
ls -la ~/.ssh
```

You should see:

```text
id_rsa
id_rsa.pub
```

Display the public key:

```bash
cat ~/.ssh/id_rsa.pub
```

Copy the complete public key.

It will look similar to:

```text
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... jenkins@server
```

---

# 4. Configure Jenkins Agent – EC2-2

SSH into the second EC2 instance:

```bash
ssh -i key.pem ubuntu@<AGENT-EC2-IP>
```

## Install Java

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
```

Verify:

```bash
java -version
```

---

## Install Jenkins

Install Jenkins on the second EC2 as well if it is required for the agent setup:

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

```bash
sudo apt update
sudo apt install -y jenkins
```

---

# 5. Install Node.js and npm

Install Node.js and npm:

```bash
sudo apt install -y nodejs npm
```

Verify:

```bash
node --version
npm --version
```

---

# 6. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
```

Start Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Check Docker:

```bash
docker --version
```

---

# 7. Add Ubuntu User to Docker Group

Add the `ubuntu` user to the Docker group:

```bash
sudo usermod -aG docker ubuntu
```

Apply the group change:

```bash
newgrp docker
```

Verify:

```bash
groups
```

You should see:

```text
ubuntu docker
```

Test Docker:

```bash
docker ps
```

If Docker works without `sudo`, the configuration is successful.

---

# 8. Add Jenkins Public Key to Agent

On **EC2-2**, switch to the Ubuntu user:

```bash
sudo su - ubuntu
```

Create the SSH directory:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Open the authorized keys file:

```bash
nano ~/.ssh/authorized_keys
```

Paste the **public key generated on EC2-1**.

Save the file.

Set the correct permissions:

```bash
chmod 600 ~/.ssh/authorized_keys
```

Now Jenkins Controller can connect to the Jenkins Agent using SSH.

---

# 9. Test SSH Connection

On EC2-1, switch to the Jenkins user:

```bash
sudo su - jenkins
```

Test SSH:

```bash
ssh ubuntu@<AGENT-EC2-IP>
```

If prompted to confirm the host:

```text
Are you sure you want to continue connecting?
```

Enter:

```text
yes
```

If the connection is successful, you should be logged into EC2-2.

Exit:

```bash
exit
```

---

# 10. Configure Jenkins

Open Jenkins:

```text
http://<JENKINS-EC2-IP>:8080
```

Complete the initial Jenkins setup.

---

# 11. Install Required Jenkins Plugins

Go to:

```text
Manage Jenkins
        ↓
Plugins
        ↓
Available Plugins
```

Install the required plugins, especially:

* Pipeline
* Git
* SSH Build Agents
* Credentials Binding
* Docker Pipeline

Restart Jenkins if required.

---

# 12. Add SSH Credentials

Go to:

```text
Manage Jenkins
        ↓
Credentials
        ↓
System
        ↓
Global credentials
        ↓
Add Credentials
```

Select:

```text
Kind: SSH Username with private key
```

Configure:

```text
Username: ubuntu
Private Key: Jenkins private SSH key
```

The private key can be obtained from EC2-1:

```bash
sudo cat /var/lib/jenkins/.ssh/id_rsa
```

Copy the complete private key and add it to Jenkins credentials.

Example:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

Give the credential an ID, for example:

```text
docker-agent-ssh
```

---

# 13. Add Jenkins Agent Node

Go to:

```text
Manage Jenkins
        ↓
Nodes
        ↓
New Node
```

Create a node named:

```text
docker-agent
```

Select:

```text
Permanent Agent
```

Configure:

```text
Name: docker-agent

Remote root directory:
/home/ubuntu

Labels:
docker-agent

Launch method:
Launch agents via SSH
```

Configure the SSH connection:

```text
Host:
<AGENT-EC2-IP>

Credentials:
docker-agent-ssh

Host Key Verification Strategy:
Accept first connection
```

Save the configuration.

Jenkins should establish an SSH connection with EC2-2.

The node should become:

```text
docker-agent    Connected
```

---

# 14. Create Jenkins Pipeline

Create a new Jenkins Pipeline job.

Go to:

```text
New Item
    ↓
Pipeline
```

Select:

```text
Pipeline script
```

Use the following Jenkinsfile:

```groovy
pipeline {

    agent {
        label 'docker-agent'
    }

    environment {
        IMAGE_NAME = "node-form-app"
        SQL_CONTAINER_NAME = "mysql"
        NETWORK_NAME = "appnet"
        CONTAINER_NAME = "nodeapp"
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/HTMLform_NodeApp.git'
            }
        }

        stage('InstallDependencies') {
            steps {
                sh '''
                    npm install
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Docker Network') {
            steps {
                sh '''
                    docker network inspect ${NETWORK_NAME} >/dev/null 2>&1 || \
                    docker network create ${NETWORK_NAME}
                '''
            }
        }

        stage('Run MySQL Container') {
            steps {
                sh '''
                    docker rm -f ${SQL_CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                      --name ${SQL_CONTAINER_NAME} \
                      --network ${NETWORK_NAME} \
                      -e MYSQL_ROOT_PASSWORD=rootpass \
                      -e MYSQL_DATABASE=mydb \
                      mysql:8
                '''
            }
        }

        stage('Run Node App') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      --network ${NETWORK_NAME} \
                      -p 3000:3000 \
                      -e DB_HOST=${SQL_CONTAINER_NAME} \
                      -e DB_USER=root \
                      -e DB_PASSWORD=rootpass \
                      -e DB_NAME=mydb \
                      ${IMAGE_NAME}:latest
                '''
            }
        }
    }
}
```

---

# 15. Run the Pipeline

Click:

```text
Build Now
```

The pipeline will execute the following stages:

```text
Clone
   ↓
InstallDependencies
   ↓
Build Image
   ↓
Docker Network
   ↓
Run MySQL Container
   ↓
Run Node App
```

The pipeline runs on the Jenkins agent because of:

```groovy
agent {
    label 'docker-agent'
}
```

---

# 16. Verify Docker Containers

SSH into EC2-2:

```bash
ssh ubuntu@<AGENT-EC2-IP>
```

Check running containers:

```bash
docker ps
```

You should see:

```text
mysql
nodeapp
```

Example:

```text
CONTAINER ID   IMAGE              NAMES
xxxxxxxx       node-form-app     nodeapp
xxxxxxxx       mysql:8            mysql
```

---

# 17. Verify Docker Network

Check the network:

```bash
docker network ls
```

You should see:

```text
appnet
```

Inspect it:

```bash
docker network inspect appnet
```

Both containers should be connected to:

```text
appnet
```

The Node.js application connects to MySQL using:

```text
DB_HOST=mysql
```

Docker's internal DNS resolves the container name `mysql` to the MySQL container.

---

# 18. Access the Application

Open a browser and enter:

```text
http://<AGENT-EC2-IP>:3000
```

The Node.js form application should open.

Enter data into the form and submit it.

---

# 19. Verify Data in MySQL

Check the MySQL container:

```bash
docker exec -it mysql mysql -uroot -prootpass
```

Select the database:

```sql
USE mydb;
```

Show tables:

```sql
SHOW TABLES;
```

Check the data:

```sql
SELECT * FROM <table_name>;
```

The data submitted through the Node.js application should be available in MySQL.

---

# 20. Troubleshooting

If the application is not accessible, first check the containers:

```bash
docker ps -a
```

Check Node.js application logs:

```bash
docker logs nodeapp
```

Check MySQL logs:

```bash
docker logs mysql
```

Follow Node.js logs:

```bash
docker logs -f nodeapp
```

Follow MySQL logs:

```bash
docker logs -f mysql
```

---

## Restart Node.js Container

```bash
docker restart nodeapp
```

## Restart MySQL Container

```bash
docker restart mysql
```

## Restart Both Containers

```bash
docker restart mysql nodeapp
```

---

# 21. Check Port 3000

Verify that the Node.js container is exposing port 3000:

```bash
docker port nodeapp
```

Expected:

```text
3000/tcp -> 0.0.0.0:3000
```

Also verify the EC2 Security Group allows:

```text
TCP 3000
```

---

# 22. Check Container Connectivity

Check the network:

```bash
docker network inspect appnet
```

Both containers should be listed.

You can also test from the Node container:

```bash
docker exec -it nodeapp sh
```

Then check connectivity to MySQL:

```bash
ping mysql
```

If `ping` is not installed, use an application/database connectivity test instead.

---

# 23. Common Problems

### Jenkins Agent Offline

Check:

```text
Manage Jenkins
    ↓
Nodes
    ↓
docker-agent
```

Verify:

* EC2-2 is running
* SSH port 22 is allowed
* Public key exists in `~/.ssh/authorized_keys`
* Jenkins has the correct private key
* Username is `ubuntu`
* Agent IP address is correct

---

### Docker Permission Denied

If Jenkins cannot execute Docker commands:

```text
permission denied while trying to connect to the Docker daemon
```

Check:

```bash
groups ubuntu
```

Make sure `docker` is present.

You may need to reconnect the SSH session after:

```bash
sudo usermod -aG docker ubuntu
```

Then verify:

```bash
docker ps
```

---

### Node Application Not Accessible

Check:

```bash
docker ps
```

Then:

```bash
docker logs nodeapp
```

Check EC2 Security Group:

```text
Inbound Rule
TCP 3000
```

Then access:

```text
http://<AGENT-EC2-IP>:3000
```

---

### MySQL Connection Error

Check MySQL:

```bash
docker ps
docker logs mysql
```

Check the Node.js environment variables:

```bash
docker inspect nodeapp
```

The application should use:

```text
DB_HOST=mysql
DB_USER=root
DB_PASSWORD=rootpass
DB_NAME=mydb
```

Both containers must be on:

```text
appnet
```

---

# 24. Complete Flow

```text
1. Launch EC2-1
        |
        +-- Install Java
        +-- Install Jenkins
        +-- Switch to Jenkins user
        +-- Generate SSH key
        |
        v
2. Launch EC2-2
        |
        +-- Install Java
        +-- Install Jenkins
        +-- Install Node.js
        +-- Install npm
        +-- Install Docker
        +-- Add ubuntu to docker group
        |
        v
3. Copy Jenkins public key
        |
        v
4. Add public key to EC2-2
   ~/.ssh/authorized_keys
        |
        v
5. Configure Jenkins
        |
        +-- Install plugins
        +-- Add SSH credentials
        +-- Add docker-agent node
        |
        v
6. Run Pipeline
        |
        +-- Clone GitHub repository
        +-- npm install
        +-- Build Docker image
        +-- Create Docker network
        +-- Run MySQL container
        +-- Run Node.js container
        |
        v
7. Access Application
        |
        v
http://<EC2-2-IP>:3000
        |
        v
8. Submit Form
        |
        v
9. Verify Data in MySQL
        |
        v
10. If application fails
        |
        +-- docker ps -a
        +-- docker logs nodeapp
        +-- docker logs mysql
        +-- docker restart nodeapp mysql
```

# Conclusion

This setup demonstrates a basic **Jenkins CI/CD deployment using a dedicated SSH Docker agent**.

The Jenkins Controller manages the pipeline, while the Jenkins Agent performs the actual:

* Git checkout
* Node.js dependency installation
* Docker image build
* Docker network creation
* MySQL container deployment
* Node.js application deployment

The final application is accessible through:

```text
http://<AGENT-EC2-IP>:3000
```
