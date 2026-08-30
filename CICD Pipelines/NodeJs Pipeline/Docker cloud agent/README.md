# Jenkins Dynamic Docker Cloud Agent – Node.js + MySQL Deployment

This project demonstrates how to configure **Jenkins with a dynamic Docker cloud agent** and use it to build and deploy a **Node.js application with MySQL** using Docker.

## Architecture

```text
                    ┌─────────────────────────┐
                    │       EC2 - 1           │
                    │                         │
                    │  Java                   │
                    │  Jenkins                │
                    │                         │
                    │  Jenkins Controller     │
                    └────────────┬────────────┘
                                 │
                         Docker Host URI
                      tcp://<private-ip>:2375
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       EC2 - 2           │
                    │                         │
                    │  Java                   │
                    │  Docker                 │
                    │  Ubuntu + Docker group  │
                    │                         │
                    │  EBS Volume              │
                    │  /var/lib/               │
                    │                         │
                    │  Docker Host             │
                    └────────────┬────────────┘
                                 │
                         Dynamic Docker Agent
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │   Jenkins Docker Agent  │
                    │                         │
                    │  Node.js                │
                    │  npm                    │
                    │  Docker CLI              │
                    └────────────┬────────────┘
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │       Docker Network         │
                  │          appnet              │
                  │                              │
                  │  ┌────────────┐              │
                  │  │ nodeapp    │              │
                  │  │ Port 3000  │              │
                  │  └──────┬─────┘              │
                  │         │                    │
                  │  ┌──────▼─────┐              │
                  │  │   mysql    │              │
                  │  │   Port     │              │
                  │  │   3306     │              │
                  │  └────────────┘              │
                  └──────────────────────────────┘
```

---

# 1. Prerequisites

You need:

* AWS account
* 2 EC2 instances
* Ubuntu EC2 instances
* Jenkins
* Java
* Docker
* EBS volume
* GitHub repository
* Security Groups configured appropriately

GitHub repository used in this project:

`https://github.com/Code-with-Shravani25/HTMLform_NodeApp.git`

---

# 2. Launch Two EC2 Instances

Launch two Ubuntu EC2 instances.

### EC2-1 – Jenkins Controller

Install:

* Java
* Jenkins

This EC2 will act as the **Jenkins Controller**.

### EC2-2 – Docker Host

Install:

* Java
* Docker

This EC2 will act as the **Docker Host** where Jenkins dynamically creates Docker agents and runs application containers.

---

# 3. EC2-1 – Install Java

Update packages:

```bash
sudo apt update
```

Install Java:

```bash
sudo apt install -y openjdk-21-jdk
```

Verify:

```bash
java -version
```

---

# 4. EC2-1 – Install Jenkins

Add Jenkins repository and install Jenkins.

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

Update:

```bash
sudo apt update
```

Install Jenkins:

```bash
sudo apt install -y jenkins
```

Start Jenkins:

```bash
sudo systemctl enable --now jenkins
```

Check status:

```bash
sudo systemctl status jenkins
```

Jenkins runs by default on:

```text
http://<EC2-1-PUBLIC-IP>:8080
```

Get the initial password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

# 5. EC2-2 – Install Java

Update packages:

```bash
sudo apt update
```

Install Java:

```bash
sudo apt install -y openjdk-21-jdk
```

Verify:

```bash
java -version
```

---

# 6. EC2-2 – Install Docker

Install Docker:

```bash
sudo apt install -y docker.io
```

Enable and start Docker:

```bash
sudo systemctl enable --now docker
```

Verify:

```bash
docker --version
```

---

# 7. Add Ubuntu User to Docker Group

Add the `ubuntu` user to the Docker group:

```bash
sudo usermod -aG docker ubuntu
```

Log out and log back in.

Verify:

```bash
groups
```

You should see:

```text
docker
```

Test Docker:

```bash
docker ps
```

---

# 8. Create and Attach EBS Volume

Create an EBS volume from the AWS EC2 console.

The EBS volume should be attached to **EC2-2**.

After attaching the volume, check the disks:

```bash
lsblk
```

Example:

```text
NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0  20G  0 disk
├─nvme0n1p1
└─nvme0n1p16
nvme1n1     259:1    0  30G  0 disk
```

Here:

```text
nvme1n1
```

is the newly attached EBS volume.

---

# 9. Format the EBS Volume

**Be careful:** formatting the disk deletes existing data.

Check the device first:

```bash
lsblk
```

Format the new volume:

```bash
sudo mkfs.ext4 /dev/nvme1n1
```

---

# 10. Mount EBS Volume

Create a temporary mount point:

```bash
sudo mkdir -p /mnt/ebs
```

Mount the volume:

```bash
sudo mount /dev/nvme1n1 /mnt/ebs
```

Verify:

```bash
df -h
```

---

# 11. Move Docker Data to EBS

Docker normally stores its data under:

```text
/var/lib/docker
```

Since the EBS volume is being used for Docker storage, create the required directory:

```bash
sudo mkdir -p /var/lib/docker
```

The EBS volume can be mounted for Docker data storage.

Make sure Docker is stopped before moving Docker's existing data:

```bash
sudo systemctl stop docker
```

Copy existing Docker data if required:

```bash
sudo rsync -aP /var/lib/docker/ /mnt/ebs/
```

Then configure the mount appropriately so Docker uses the EBS-backed location.

> **Important:** Do not blindly mount an empty EBS volume over `/var/lib/` because `/var/lib/` contains important system/application data. Prefer mounting the EBS volume specifically for Docker storage, such as `/var/lib/docker`, or another dedicated directory.

---

# 12. Create Docker Cloud Agent Image

Create a Dockerfile:

```dockerfile
FROM jenkins/inbound-agent:jdk21

USER root

RUN apt-get update && \
    apt-get install -y \
        nodejs \
        npm \
        docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
```

> Note: Docker uses the Linux username `jenkins` in lowercase. Use `USER jenkins`, not `USER Jenkins`.

---

# 13. Build the Jenkins Agent Image

Build the image:

```bash
docker build -t dockeragent:latest .
```

Verify:

```bash
docker images
```

You should see:

```text
dockeragent   latest
```

---

# 14. Possible Error While Building the Image

If Docker build gives an error related to a missing directory, especially after configuring/mounting an EBS volume, check the directory mentioned in the error.

For example:

```bash
ls -ld /var/lib
```

If a required directory is missing, create it:

```bash
sudo mkdir -p <directory-name>
```

Then retry the build:

```bash
docker build -t dockeragent:latest .
```

### Important

Mounting an EBS volume over a system directory can hide the original contents of that directory.

For example, mounting an empty volume directly on:

```text
/var/lib
```

can make existing directories under `/var/lib` appear to disappear.

Therefore, it is safer to use a dedicated mount point such as:

```text
/mnt/ebs
```

or specifically configure:

```text
/var/lib/docker
```

for Docker storage.

---

# 15. Configure Docker Remote API

Jenkins needs to communicate with the Docker daemon running on EC2-2.

Create the Docker systemd override directory:

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
```

Create the override file:

```bash
sudo vi /etc/systemd/system/docker.service.d/override.conf
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Restart Docker:

```bash
sudo systemctl restart docker
```

Check Docker:

```bash
sudo systemctl status docker
```

---

# 16. Verify Docker is Listening on Port 2375

Run:

```bash
sudo ss -lntp | grep 2375
```

Expected:

```text
LISTEN 0 4096 0.0.0.0:2375
```

Test from EC2-2:

```bash
curl http://localhost:2375/version
```

You should receive Docker API information.

---

# 17. Configure EC2 Security Group

On the EC2-2 Security Group, allow TCP port:

```text
2375
```

The source should preferably be:

```text
EC2-1 private IP
```

or the appropriate Jenkins Controller security group.

### Security Warning

Port `2375` without TLS gives remote access to the Docker daemon.

Do **not** expose port `2375` to:

```text
0.0.0.0/0
```

Use a private network/security-group rule so only the Jenkins Controller can access it.

---

# 18. Configure Jenkins

Open Jenkins:

```text
http://<EC2-1-PUBLIC-IP>:8080
```

Complete the Jenkins setup.

Install the required plugins.

Recommended plugins include:

* Docker
* Docker Pipeline
* Git
* Pipeline
* Credentials Binding
* SSH Agent

Depending on the Jenkins version/plugin configuration, Docker cloud functionality may be provided by the appropriate Docker-related cloud/agent plugin.

---

# 19. Create Docker Cloud in Jenkins

Go to:

```text
Manage Jenkins
    ↓
Clouds
    ↓
New Cloud
```

Select the Docker cloud option provided by your installed Docker cloud plugin.

Configure the Docker host.

Use:

```text
tcp://<EC2-2-PRIVATE-IP>:2375
```

Example:

```text
tcp://172.31.10.25:2375
```

---

# 20. Configure Docker Agent Template

Create an agent template.

Use the Docker image that was created earlier:

```text
dockeragent:latest
```

Configure the agent label:

```text
docker-agent
```

The label is important because the Jenkins pipeline will request:

```groovy
agent {
    label 'docker-agent'
}
```

Jenkins will then:

1. Receive the pipeline.
2. Find the Docker cloud.
3. Connect to EC2-2 Docker daemon.
4. Create a temporary Docker container.
5. Use `dockeragent:latest`.
6. Run the Jenkins agent inside that container.
7. Execute the pipeline.
8. Remove the temporary agent after the build.

---

# 21. Verify Dynamic Agent

Create a test pipeline:

```groovy
pipeline {
    agent {
        label 'docker-agent'
    }

    stages {
        stage('Test Agent') {
            steps {
                sh 'whoami'
                sh 'node --version'
                sh 'npm --version'
                sh 'docker --version'
            }
        }
    }
}
```

The expected output should show:

```text
jenkins
```

and versions for:

```text
node
npm
docker
```

---

# 22. Create the Node.js Application Pipeline

Create a Jenkins Pipeline job.

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

# 23. Pipeline Flow

The pipeline performs the following operations:

```text
Jenkins Controller
       │
       ▼
Docker Cloud
       │
       ▼
EC2-2 Docker Host
       │
       ▼
Dynamic Jenkins Agent
       │
       ├── Clone GitHub Repository
       │
       ├── Build Node.js Docker Image
       │
       ├── Create Docker Network
       │
       ├── Start MySQL Container
       │
       └── Start Node.js Container
```

---

# 24. Docker Network

The pipeline creates:

```text
appnet
```

Both containers are connected to this network:

```text
mysql
nodeapp
```

The Node.js application can therefore connect to MySQL using:

```text
DB_HOST=mysql
```

instead of an IP address.

---

# 25. Verify Docker Containers

After the Jenkins pipeline completes, SSH into EC2-2 and run:

```bash
docker ps
```

You should see containers similar to:

```text
mysql
nodeapp
```

Check the Docker network:

```bash
docker network inspect appnet
```

Both containers should be connected to:

```text
appnet
```

---

# 26. Check Node.js Application Logs

Run:

```bash
docker logs nodeapp
```

If the application starts successfully, it should be listening on:

```text
3000
```

---

# 27. Check MySQL Logs

Run:

```bash
docker logs mysql
```

Wait until MySQL is fully initialized.

You should see a message indicating that MySQL is ready for connections.

> **Note:** The pipeline starts MySQL and immediately starts Node.js. MySQL initialization can take some time. If the Node application attempts to connect before MySQL is ready, the application may initially fail to connect. A production-ready pipeline should add a MySQL health/readiness check before starting the Node application.

---

# 28. Access the Node.js Application

Open the following in your browser:

```text
http://<EC2-2-PUBLIC-IP>:3000
```

You should see the Node.js HTML form.

Make sure EC2-2 Security Group allows:

```text
TCP 3000
```

Preferably restrict the source to your IP address rather than opening it to everyone.

---

# 29. Enter Data into the Form

Enter sample data into the application form.

For example:

```text
Name: Shravani
Email: shravani@example.com
```

Submit the form.

The Node.js application should insert the data into MySQL.

---

# 30. Verify Data in MySQL

Connect to the MySQL container:

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

Check the table:

```sql
SELECT * FROM <table_name>;
```

You should see the data submitted through the web form.

Example:

```text
+----+----------+-----------------------+
| id | name     | email                 |
+----+----------+-----------------------+
|  1 | Shravani | shravani@example.com  |
+----+----------+-----------------------+
```

---

# 31. End-to-End Verification

The complete flow is:

```text
User
 │
 │ HTTP :3000
 ▼
Node.js Container
 │
 │ DB_HOST=mysql
 │ MySQL :3306
 ▼
MySQL Container
 │
 ▼
mydb
 │
 ▼
Application Table
```

At the same time:

```text
GitHub
   │
   ▼
Jenkins Controller
   │
   ▼
Docker Cloud
   │
   ▼
EC2-2 Docker Host
   │
   ▼
Dynamic Jenkins Agent
   │
   ├── docker build
   ├── docker network create
   ├── docker run mysql
   └── docker run nodeapp
```

---

# 32. Useful Troubleshooting Commands

### Check Docker

```bash
docker ps
```

```bash
docker info
```

```bash
docker version
```

### Check Docker API

```bash
curl http://localhost:2375/version
```

### Check Docker port

```bash
sudo ss -lntp | grep 2375
```

### Check Docker service

```bash
sudo systemctl status docker
```

### Check Jenkins

```bash
sudo systemctl status jenkins
```

### Check containers

```bash
docker ps -a
```

### Check Node logs

```bash
docker logs nodeapp
```

### Check MySQL logs

```bash
docker logs mysql
```

### Check network

```bash
docker network inspect appnet
```

### Check EBS mount

```bash
df -h
```

```bash
lsblk
```

---

# 33. Important Docker Agent Troubleshooting

If the Jenkins agent reports:

```text
docker: command not found
```

check the agent image:

```bash
docker run --rm dockeragent:latest docker --version
```

Also verify:

```bash
docker run --rm dockeragent:latest node --version
```

and:

```bash
docker run --rm dockeragent:latest npm --version
```

The agent image must contain:

```text
Node.js
npm
Docker CLI
```

---

# 34. Important Docker Permission Issue

If Jenkins gets:

```text
permission denied while trying to connect to the Docker daemon socket
```

remember that the **dynamic Jenkins agent container** needs access to the Docker host.

Installing Docker CLI inside the agent is not enough by itself.

The Docker CLI needs to communicate with the Docker daemon through the configured Docker host.

The Docker cloud configuration should point to:

```text
tcp://<EC2-2-PRIVATE-IP>:2375
```

This allows the Docker CLI in the agent to communicate with the Docker daemon on EC2-2.

---

# 35. Final Architecture

```text
                     AWS
                      │
          ┌───────────┴────────────┐
          │                        │
          ▼                        ▼
     EC2-1                     EC2-2
 Jenkins Controller          Docker Host
     │                           │
     │                           ├── Docker
     │                           ├── EBS
     │                           └── Docker API :2375
     │                                │
     │                                │
     └──────── tcp://private-ip:2375 ─┘
                  │
                  ▼
          Docker Cloud
                  │
                  ▼
        Dynamic Jenkins Agent
        ┌───────────────────┐
        │ Node.js           │
        │ npm               │
        │ Docker CLI        │
        └─────────┬─────────┘
                  │
                  ▼
             Docker Build
                  │
                  ▼
             appnet network
              /          \
             /            \
            ▼              ▼
       nodeapp           mysql
       :3000             :3306
          │                │
          └───────┬────────┘
                  │
                  ▼
                mydb
                  │
                  ▼
             Form Data
```

---

# 36. Summary

This project demonstrates:

* Launching two EC2 instances
* Installing Jenkins
* Installing Docker
* Adding Ubuntu user to Docker group
* Creating and attaching an EBS volume
* Configuring Docker storage
* Creating a custom Jenkins Docker agent image
* Installing Node.js, npm and Docker CLI in the agent
* Configuring Docker Remote API
* Configuring Jenkins Docker Cloud
* Creating dynamic Jenkins agents
* Cloning a Node.js application from GitHub
* Building a Docker image
* Creating a Docker network
* Running MySQL in Docker
* Running a Node.js application in Docker
* Connecting Node.js to MySQL using Docker DNS
* Submitting form data
* Verifying the inserted data in MySQL

The final result is a **Jenkins Controller + Docker Cloud + Dynamic Docker Agent + Node.js + MySQL** CI/CD setup running across two EC2 instances.
