# Jenkins Migration to a New Server with Minimal Downtime

## Overview

This project demonstrates how to migrate a Jenkins server from one machine to another with minimal downtime while preserving jobs, pipelines, plugins, credentials, users, and build history.

---

## Objective

- Migrate Jenkins to a new server with minimal downtime.
- Preserve all Jenkins configurations and data.
- Ensure pipelines continue to run successfully after migration.
- Maintain a rollback option in case of failure.

---

## Prerequisites

- Existing Jenkins server
- New server with SSH access
- Administrative (sudo/root) privileges
- Same Jenkins version on both servers
- Same Java version on both servers
- Network connectivity between both servers

---

## Architecture

```text
                Before Migration

        +-----------------------+
        |   Old Jenkins Server  |
        |                       |
        | Jobs                  |
        | Pipelines             |
        | Plugins               |
        | Credentials           |
        | Build History         |
        +-----------+-----------+
                    |
              Copy Jenkins Home
                 (rsync/scp)
                    |
                    v
        +-----------------------+
        |   New Jenkins Server  |
        |                       |
        | Same Jenkins Version  |
        | Same Plugins          |
        | Same Configuration    |
        +-----------+-----------+
                    |
              Validate Server
                    |
             Enable Quiet Down
                    |
          Final Incremental Sync
                    |
            Update DNS/LB/Proxy
                    |
                    v
             Users Access New
              Jenkins Server
```

---

# Migration Steps

## Step 1: Collect Existing Jenkins Information

Verify the following from the current Jenkins server:

- Jenkins version
- Java version
- Installed plugins
- Jenkins Home directory
- Connected agents
- Configured credentials
- Tool installations (Git, Maven, JDK, etc.)
- Shared libraries
- SCM webhooks

---

## Step 2: Prepare the New Server

Install the required software.

- Java
- Jenkins
- Git
- Maven (if required)
- Docker (if pipelines use Docker)
- Any additional tools used by pipelines

Ensure the Jenkins version matches the existing server.

---

## Step 3: Install Matching Plugins

Install the same plugin versions on the new server to avoid compatibility issues.

---

## Step 4: Copy Jenkins Home Directory

The Jenkins Home directory typically resides at:

```text
/var/lib/jenkins
```

Copy it to the new server.

```bash
rsync -avz /var/lib/jenkins/ user@new-server:/var/lib/jenkins/
```

This copies:

- Jobs
- Pipelines
- Plugins
- Users
- Build history
- Global configuration

---

## Step 5: Copy Secrets and Credentials

Ensure the following are copied:

```text
$JENKINS_HOME/secrets/
$JENKINS_HOME/credentials.xml
```

Without these files, Jenkins cannot decrypt stored credentials.

---

## Step 6: Set File Permissions

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins
```

---

## Step 7: Configure Build Agents

Reconnect Jenkins agents.

### SSH Agents

- Verify SSH connectivity.
- Update the controller IP if required.

### JNLP/WebSocket Agents

- Update the Jenkins URL.
- Restart or reconnect the agents.

---

## Step 8: Validate the New Jenkins Server

Before switching production traffic, verify:

- Jenkins UI loads successfully.
- Jobs are present.
- Pipelines execute successfully.
- Credentials are accessible.
- Plugins load correctly.
- Git checkout works.
- Docker builds (if applicable).
- Notifications (Email/Slack).
- Agent connectivity.

---

## Step 9: Enable Quiet Down Mode

Put the old Jenkins server into **Quiet Down** mode.

Purpose:

- Prevents new builds from starting.
- Allows running builds to complete.

---

## Step 10: Perform Final Incremental Synchronization

Copy only the changes made after the initial synchronization.

```bash
rsync -avz --delete /var/lib/jenkins/ user@new-server:/var/lib/jenkins/
```

This minimizes downtime because only changed files are transferred.

---

## Step 11: Start Jenkins on the New Server

```bash
sudo systemctl start jenkins
```

Verify:

- Jobs
- Credentials
- Pipelines
- Plugins
- Agents

---

## Step 12: Redirect Users

Update one of the following:

- DNS
- Load Balancer
- Reverse Proxy
- Virtual IP

Users are now redirected to the new Jenkins server.

---

## Step 13: Monitor

Verify:

- Pipeline execution
- SCM webhooks
- Scheduled jobs
- Agent connectivity
- Email/Slack notifications

Keep the old Jenkins server available until the migration is fully validated.

---

# Rollback Plan

If migration fails:

1. Redirect DNS or Load Balancer back to the old Jenkins server.
2. Restart Jenkins on the old server if necessary.
3. Resume builds.
4. Investigate the issue before attempting migration again.

---

# Best Practices

- Perform the migration during a maintenance window.
- Keep Jenkins versions identical.
- Keep Java versions identical.
- Install matching plugin versions.
- Use `rsync` for efficient synchronization.
- Copy the `secrets` directory and `credentials.xml`.
- Validate the new server before switching traffic.
- Retain the old server until the migration is confirmed successful.

---

# Useful Commands

### Copy Jenkins Home

```bash
rsync -avz /var/lib/jenkins/ user@new-server:/var/lib/jenkins/
```

### Incremental Sync

```bash
rsync -avz --delete /var/lib/jenkins/ user@new-server:/var/lib/jenkins/
```

### Set Ownership

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins
```

### Start Jenkins

```bash
sudo systemctl start jenkins
```

### Check Jenkins Status

```bash
sudo systemctl status jenkins
```

---

# Outcome

After completing the migration:

- Jenkins is successfully migrated to the new server.
- Jobs, pipelines, plugins, credentials, and build history are preserved.
- Build agents reconnect successfully.
- Production traffic is switched with minimal downtime.
- A rollback option remains available until the migration is fully verified.
