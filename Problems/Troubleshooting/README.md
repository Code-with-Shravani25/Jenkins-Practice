# Jenkins Troubleshooting Guide

---

# 1. Jenkins Build Failing After Dependency Installation

## Troubleshooting Steps

### Check Jenkins Console Output
Review the build logs for errors.

### Verify Dependency Installation Commands

**Maven**
```bash
mvn clean install
```

**NPM**
```bash
npm install
```

**Python**
```bash
pip install -r requirements.txt
```

### Check Version Compatibility

- Java
- Maven
- Node.js

### Verify Internet Access to Package Repositories

```bash
curl https://repo.maven.apache.org
```

### Check Disk Space

```bash
df -h
```

## Fix

Clear corrupted caches:

```bash
rm -rf ~/.m2/repository
```

```bash
npm cache clean --force
```

---

# 2. Jenkins Workspace Consuming High Disk Space

## Investigation

Check workspace usage:

```bash
du -sh /var/lib/jenkins/workspace/*
```

Check Jenkins home usage:

```bash
du -sh /var/lib/jenkins/*
```

## Common Causes

- Old workspaces
- Large build artifacts
- Old logs
- Docker images

## Fix

### Use Workspace Cleanup Plugin

Pipeline cleanup:

```groovy
post {
    always {
        cleanWs()
    }
}
```

Delete old builds:

```bash
find /var/lib/jenkins/jobs -name builds -mtime +30 -exec rm -rf {} \;
```

Cleanup Docker:

```bash
docker system prune -a
```

---

# 3. Pipeline Stuck at "Waiting for Next Available Executor"

## Investigation

Check:

```text
Manage Jenkins → Nodes
```

Verify:

- Agent online
- Executor availability

Check Jenkins Queue:

```text
http://jenkins:8080/queue
```

## Common Causes

- All executors busy
- Agent offline
- Incorrect label assignment

Example:

```groovy
agent {
    label 'kubernetes'
}
```

No matching agent exists.

## Fix

Increase executors:

```text
Manage Jenkins → Nodes → Configure → Number of Executors
```

Or add more build agents.

---

# 4. GitHub Webhook Not Triggering Jenkins Job

## Verification

GitHub:

```text
Repository → Settings → Webhooks
```

Payload URL:

```text
http://jenkins-url/github-webhook/
```

### Check Delivery Logs

Possible responses:

- 200 OK
- 403 Forbidden
- 404 Not Found
- 500 Internal Server Error

## Verify Jenkins Configuration

Install:

- GitHub Plugin
- Git Plugin

Enable:

```text
GitHub hook trigger for GITScm polling
```

Test:

```bash
curl http://jenkins-url/github-webhook/
```

## Fix

- Correct webhook URL
- Open firewall
- Verify GitHub credentials/token

---

# 5. Jenkins Agent Frequently Disconnects

## Investigation

Check logs:

```bash
journalctl -u jenkins-agent
```

## Common Causes

- Network instability
- Low memory
- Java crashes
- SSH timeout

Check resources:

```bash
free -m
top
```

## Fix

Increase JVM memory:

```bash
-Xms512m
-Xmx2048m
```

SSH Keepalive:

```bash
ServerAliveInterval 60
```

Monitor network stability.

---

# 6. Docker Image Push Failing with Authentication Error

## Error

```text
unauthorized: incorrect username or password
```

## Verification

Test login:

```bash
docker login
```

Check Jenkins Credentials:

```text
Manage Jenkins → Credentials
```

## Secure Pipeline Example

```groovy
withCredentials([usernamePassword(
credentialsId: 'dockerhub',
usernameVariable: 'USER',
passwordVariable: 'PASS'
)]) {
    sh 'echo $PASS | docker login -u $USER --password-stdin'
}
```

## Fix

- Regenerate DockerHub access token
- Update Jenkins credentials
- Verify repository permissions

---

# 7. Kubernetes Deployment Failing Due to Image Pull Issues

## Error

```text
ImagePullBackOff
ErrImagePull
```

## Investigation

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

## Common Causes

- Wrong image name
- Image not pushed
- Missing image pull secret

## Create Secret

```bash
kubectl create secret docker-registry regcred
```

Deployment configuration:

```yaml
imagePullSecrets:
  - name: regcred
```

## Verification

```bash
kubectl describe pod <pod-name>
```

---

# 8. Jenkins Job Works Manually But Fails Through Webhook

## Common Causes

### Different User Context

Manual Build:

```text
User Context
```

Webhook Build:

```text
System Context
```

### Missing Parameters

Verify:

```groovy
echo "${params.BRANCH}"
```

### SCM Configuration Issues

Check Git checkout configuration.

### Permission Issues

Webhook user may not have required permissions.

## Fix

Compare environment variables:

```groovy
sh 'env'
```

between manual and webhook builds.

---

# 9. Jenkins Pipeline Exposing Secrets in Console Logs

## Bad Practice

```groovy
echo "$PASSWORD"
```

## Secure Method

```groovy
withCredentials([
string(credentialsId: 'db-password',
variable: 'PASSWORD')
]) {
    sh './deploy.sh'
}
```

## Additional Fixes

Install:

```text
Mask Passwords Plugin
```

Avoid:

```groovy
password = "admin123"
```

Store secrets in:

- Jenkins Credentials
- Kubernetes Secrets
- HashiCorp Vault
- AWS Secrets Manager

---

# 10. Jenkins Master CPU Usage Very High During Builds

## Investigation

Check resource usage:

```bash
top
htop
```

Verify executor configuration:

```text
Manage Jenkins → Nodes
```

## Root Cause

Builds running on Jenkins Controller/Master.

## Best Practice Architecture

```text
             Jenkins Controller
                     |
      --------------------------------
      |              |              |
   Agent-1        Agent-2        Agent-3
   Build           Test          Deploy
```

## Fix

Set controller executors:

```text
Number of Executors = 0
```

Move workloads to agents:

```groovy
pipeline {
    agent {
        label 'build-agent'
    }
}
```

## Additional Optimization

- Kubernetes Agents
- Docker Agents
- Increase JVM Heap

```bash
-Xms2g
-Xmx4g
```

- Store artifacts externally (S3, Nexus, Artifactory)

---

# Standard Jenkins Troubleshooting Flow

```text
1. Check Console Logs
2. Check Jenkins System Logs
3. Verify Agent Status
4. Verify Credentials
5. Check Network Connectivity
6. Check Resource Utilization
7. Validate Pipeline Configuration
8. Reproduce Manually
9. Compare Working vs Failing Scenario
10. Apply Fix and Re-run
```

Following this structured troubleshooting process helps quickly identify and resolve most Jenkins production issues.
---

# 11. Troubleshoot intermittent Jenkins pipeline failures occurring randomly during deployment.
---

# Jenkins Troubleshooting Guide: Intermittent Pipeline Failures During Deployment

## Objective

This guide explains a systematic approach to troubleshoot Jenkins pipeline failures that occur randomly during the deployment stage.

---

# Step 1: Check Jenkins Console Logs

Start by reviewing the Jenkins **Console Output** of the failed build.

Look for errors such as:

* Connection timed out
* Permission denied
* Authentication failed
* Out of memory
* No space left on device
* SSH connection errors
* Docker or Kubernetes errors

Compare the failed build log with a successful build to identify where the failure begins.

---

# Step 2: Compare Successful and Failed Builds

Compare the following between successful and failed executions:

* Git commit/version
* Branch
* Jenkins agent
* Environment variables
* Build duration
* Deployment target

This helps determine whether the issue is environment-specific or code-related.

---

# Step 3: Verify Jenkins Agent Health

Random failures often occur due to unhealthy Jenkins agents.

Check:

```bash
df -h
free -m
top
uptime
```

Verify:

* Disk space
* Memory usage
* CPU utilization
* System uptime

Resolve issues such as:

* Disk full
* High CPU usage
* Low memory
* Hung processes

---

# Step 4: Verify Network Connectivity

Deployment usually requires connectivity to external systems.

Examples:

* GitHub
* Docker Hub
* AWS
* Kubernetes Cluster
* Remote Linux Servers

Test connectivity using:

```bash
ping github.com
curl https://api.github.com
ssh user@server
```

Check for:

* Network interruptions
* DNS issues
* Firewall restrictions
* VPN connectivity problems

---

# Step 5: Verify Jenkins Credentials

Ensure Jenkins credentials are valid and not expired.

Common credentials include:

* GitHub Personal Access Token or SSH Key
* Docker Hub Username & Password
* AWS Access Keys or IAM Role
* SSH Private Keys

Always access secrets securely using:

```groovy
withCredentials(...)
```

Never hardcode usernames, passwords, or access keys in the pipeline.

---

# Step 6: Check Deployment Server Health

If deploying to a remote server, verify that the server is healthy.

Useful commands:

```bash
systemctl status docker
systemctl status nginx
journalctl -xe
```

Verify:

* Server is reachable
* Required services are running
* Disk space is available
* No system errors

---

# Step 7: Check Resource Contention

Failures may occur if multiple pipelines deploy simultaneously.

Possible issues:

* Multiple jobs writing to the same workspace
* Simultaneous deployments to the same server
* Docker image conflicts
* Terraform state lock
* Shared resource conflicts

Recommended solutions:

* Serialize deployments
* Use Jenkins Lockable Resources plugin
* Use separate workspaces

---

# Step 8: Clean Jenkins Workspace

Old files can cause inconsistent behavior.

Clean the workspace before every build.

```groovy
cleanWs()
```

or

```bash
rm -rf *
```

This removes stale artifacts and temporary files.

---

# Step 9: Verify Jenkins Plugins

Outdated plugins may introduce random failures.

Review plugins such as:

* Pipeline Plugin
* Git Plugin
* Docker Plugin
* SSH Plugin
* Credentials Plugin

Keep plugins updated after testing compatibility.

---

# Step 10: Review Deployment Scripts

Inspect deployment scripts for:

* Hardcoded paths
* Missing error handling
* Race conditions
* Missing retries
* Invalid permissions

Example:

Instead of:

```bash
scp app.jar server:/opt/
```

Use:

```bash
scp app.jar server:/opt/ || exit 1
```

Always fail immediately if deployment commands fail.

---

# Step 11: Review Infrastructure Logs

Jenkins logs may not show infrastructure-related issues.

Check logs from:

* EC2 Instance
* Docker Containers
* Kubernetes Pods
* Application Logs
* Nginx
* Load Balancer

These logs help identify server-side problems.

---

# Step 12: Add Retry Logic

Transient network or infrastructure failures can often be resolved using retries.

Example:

```groovy
retry(3) {
    sh './deploy.sh'
}
```

The deployment step will automatically retry up to three times before failing.

---

# Step 13: Configure Timeouts

Prevent pipelines from hanging indefinitely.

Example:

```groovy
timeout(time: 20, unit: 'MINUTES') {
    sh './deploy.sh'
}
```

This terminates the build if it exceeds the specified duration.

---

# Step 14: Archive Build Logs

Store logs and artifacts after every build.

Example:

```groovy
post {
    always {
        archiveArtifacts artifacts: 'logs/**'
    }
}
```

Archived logs simplify troubleshooting and historical analysis.

---

# Sample Jenkins Pipeline

```groovy
pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Deploy') {
            steps {
                retry(3) {
                    sh './deploy.sh'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'logs/**', allowEmptyArchive: true
        }
    }
}
```

---

# Troubleshooting Checklist

* Review Jenkins Console Output.
* Compare successful and failed builds.
* Verify Jenkins agent health (CPU, Memory, Disk).
* Check network connectivity.
* Validate Jenkins credentials.
* Verify deployment server health.
* Check for concurrent deployments.
* Clean Jenkins workspace.
* Update and verify Jenkins plugins.
* Review deployment scripts.
* Inspect infrastructure logs.
* Add retry logic.
* Configure pipeline timeouts.
* Archive logs for future analysis.

---

# Best Practices

* Use `withCredentials()` to securely access secrets.
* Use `cleanWs()` before builds to avoid stale artifacts.
* Implement `retry()` for transient failures.
* Configure `timeout()` to prevent hanging builds.
* Archive logs and artifacts after every execution.
* Keep Jenkins plugins up to date.
* Monitor Jenkins agents for CPU, memory, and disk utilization.
* Avoid concurrent deployments to shared infrastructure.
* Validate deployment scripts with proper error handling.
* Regularly monitor application and infrastructure logs.

---

# Conclusion

Intermittent Jenkins deployment failures are typically caused by infrastructure issues, network instability, unhealthy Jenkins agents, expired credentials, resource contention, or deployment script problems. By following a structured troubleshooting process and implementing best practices such as workspace cleanup, retries, timeouts, and log archiving, you can significantly improve pipeline reliability and reduce deployment failures.

