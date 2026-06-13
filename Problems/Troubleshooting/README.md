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
