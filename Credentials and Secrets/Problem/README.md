# Configure credentials in Jenkins for: DockerHub,GitHub,AWS access keys

# Jenkins Credentials Configuration Guide

## Overview

Jenkins securely stores secrets in its **Credentials Store**. Pipelines
access them using `withCredentials` (when required) instead of
hardcoding sensitive values.

## DockerHub

-   **Credential Type:** Username with Password (or Personal Access
    Token)
-   **Credential ID:** `dockerhub-credentials`

Example:

``` groovy
withCredentials([
    usernamePassword(
        credentialsId: 'dockerhub-credentials',
        usernameVariable: 'DOCKER_USER',
        passwordVariable: 'DOCKER_PASS'
    )
]) {
    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
}
```

## GitHub

### Option 1: SSH Key (Recommended for Git operations)

-   Generate an SSH key on the Jenkins server.
-   Add the public key to GitHub.
-   Store the private key in Jenkins as **SSH Username with private
    key**.
-   Use the repository SSH URL: `git@github.com:username/repository.git`

### Option 2: Personal Access Token (PAT)

-   Store the GitHub username and PAT as **Username with password**
    credentials.
-   Commonly used for HTTPS authentication or GitHub API access.

## AWS

### Jenkins running on AWS EC2 (Recommended)

-   Attach an IAM Role to the EC2 instance.
-   Do **not** store AWS access keys in Jenkins.
-   No `withCredentials` block is required.
-   The AWS CLI/SDK automatically uses the IAM role.

Example:

``` groovy
sh 'aws s3 ls'
```

### Jenkins running outside AWS

-   Store AWS credentials in Jenkins as **AWS Credentials**.
-   Use `withCredentials` in the pipeline.

Example:

``` groovy
withCredentials([
    [$class: 'AmazonWebServicesCredentialsBinding',
     credentialsId: 'aws-credentials']
]) {
    sh 'aws s3 ls'
}
```

## Best Practices

-   Never hardcode secrets in a Jenkinsfile.
-   Use Jenkins Credentials Store for all sensitive data.
-   Use SSH keys for GitHub repository access whenever possible.
-   Use IAM Roles instead of AWS access keys when Jenkins runs on EC2.
-   Use `withCredentials` only when credentials are stored in Jenkins.
-   Grant the minimum permissions required (least privilege).

## Quick Summary

  Service                     Recommended Authentication
  --------------------------- ----------------------------------------
  DockerHub                   Username + Password/PAT
  GitHub                      SSH Key (preferred), PAT for HTTPS/API
  AWS (Jenkins on EC2)        IAM Role
  AWS (Jenkins outside AWS)   AWS Credentials + `withCredentials`
