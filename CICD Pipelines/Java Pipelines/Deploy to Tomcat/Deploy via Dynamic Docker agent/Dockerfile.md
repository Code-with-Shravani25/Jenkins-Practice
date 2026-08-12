# Custom Jenkins Docker Dynamic Agent

This project creates a **custom Jenkins inbound agent Docker image** with the tools required to build, test, package, and containerize a Java Maven application.

The custom image includes:

* Jenkins inbound agent
* Java 21
* Maven
* Docker CLI

---

---

---

# Dockerfile

Create a file named `Dockerfile`.

```dockerfile
FROM jenkins/inbound-agent:jdk21

USER root

RUN apt-get update \
    && apt-get install -y \
        maven \
        docker.io \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
```

> **Note:** The username should be lowercase `jenkins`.

---

# Dockerfile Explanation

## 1. Base Image

```dockerfile
FROM jenkins/inbound-agent:jdk21
```

This image is used as the base image.

It already contains:

* Jenkins inbound agent
* Java 21
* Jenkins agent software

The agent can connect to the Jenkins controller and execute Jenkins jobs.

```text
jenkins/inbound-agent:jdk21
        |
        +-- Java 21
        +-- Jenkins Agent
        +-- Connection to Jenkins Controller
```

---

## 2. Switch to Root User

```dockerfile
USER root
```

The Jenkins agent normally runs as the `jenkins` user.

Installing packages requires root privileges, so we temporarily switch to the `root` user.

---

## 3. Update Package Information

```dockerfile
RUN apt-get update
```

This updates the package information inside the container.

It retrieves the latest information about available packages from the configured package repositories.

---

## 4. Install Maven

```dockerfile
apt-get install -y maven
```

Maven is installed to build Java Maven applications.

The Jenkins pipeline can execute:

```bash
mvn clean compile
mvn test
mvn package
```

---

## 5. Install Docker

```dockerfile
apt-get install -y docker.io
```

Docker is installed so the Jenkins agent can execute Docker commands such as:

```bash
docker build
docker tag
docker push
docker pull
docker run
```

---

## 6. Clean Package Cache

```dockerfile
rm -rf /var/lib/apt/lists/*
```

This removes unnecessary package-list files created during the installation process.

The purpose is to reduce the final Docker image size.

```text
apt-get update
      |
      v
Install Maven + Docker
      |
      v
Remove package cache
      |
      v
Smaller Docker image
```

---

## 7. Switch Back to Jenkins User

```dockerfile
USER jenkins
```

After installing the required packages, switch back to the `jenkins` user.

This is recommended for security because the Jenkins pipeline should not unnecessarily run as the root user.

---

# Build the Custom Docker Image

Navigate to the directory containing the Dockerfile.

Build the image:

```bash
docker build -t shravani2001/jenkins-java-maven-docker-agent:latest .
```

Verify the image:

```bash
docker images
```

Expected output:

```text
REPOSITORY                                         TAG      IMAGE ID
shravani2001/jenkins-java-maven-docker-agent       latest   xxxxxxxx
```

---

# Test the Tools Inside the Image

Start a container:

```bash
docker run --rm -it --entrypoint bash shravani2001/jenkins-java-maven-docker-agent:latest
```

Verify Java:

```bash
java -version
```

Verify Maven:

```bash
mvn -version
```

Verify Docker:

```bash
docker --version
```

---

# Push the Custom Image to Docker Hub

Log in to Docker Hub:

```bash
docker login
```

Push the image:

```bash
docker push shravani2001/jenkins-java-maven-docker-agent:latest
```

The image can now be used in the Jenkins Docker Cloud configuration.

---

