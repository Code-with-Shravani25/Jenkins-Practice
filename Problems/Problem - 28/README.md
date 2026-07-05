# Configure Jenkins Pipeline to Build Only When Changes Are Detected in a Specific Branch

## Overview

This project demonstrates how to configure a Jenkins Pipeline to automatically trigger a build only when changes are pushed to a specific Git branch. This helps prevent unnecessary builds from other branches and is a common practice in CI/CD pipelines.

---

## Objective

Configure Jenkins to:

* Connect to a Git repository.
* Monitor a specific branch (e.g., `main` or `develop`).
* Trigger a build only when changes are pushed to that branch.
* Ignore changes made to other branches.

---

## Prerequisites

Before starting, ensure the following are available:

* AWS EC2 instance with Jenkins installed.
* Java installed.
* Jenkins accessible through a web browser.
* Git installed on the Jenkins server.
* A GitHub repository containing a `Jenkinsfile`.
* Internet access from the Jenkins server.
* Port **8080** open in the EC2 Security Group.

---

## Architecture

```text
Developer
     │
     │ Push Code
     ▼
 GitHub Repository
     │
     │ Webhook
     ▼
 Jenkins Server
     │
     ▼
 Pipeline Execution
     │
     ▼
 Build / Test / Deploy
```

---

## Step 1: Install Required Plugins

Navigate to:

```text
Manage Jenkins
    └── Plugins
         └── Available Plugins
```

Install the following plugins:

* Git
* Pipeline
* GitHub Integration
* GitHub Branch Source (Recommended)

Restart Jenkins if prompted.

---

## Step 2: Create a Pipeline Job

1. Click **New Item**.
2. Enter a job name.
3. Select **Pipeline**.
4. Click **OK**.

---

## Step 3: Configure the Pipeline

Under the **Pipeline** section:

* **Definition:** Pipeline script from SCM
* **SCM:** Git
* **Repository URL:** Your GitHub repository URL
* **Credentials:** Add Git credentials if the repository is private.

Example:

```text
Repository URL:
https://github.com/username/sample-project.git
```

---

## Step 4: Configure the Branch

In **Branches to build**, specify the branch to monitor.

Example:

```text
*/main
```

Other examples:

```text
*/develop
```

```text
*/feature/login
```

Jenkins will only check out and build the specified branch.

---

## Step 5: Add a Jenkinsfile

Create a `Jenkinsfile` in the selected branch of your repository.

Example:

```groovy
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Building Application..."
            }
        }

        stage('Test') {
            steps {
                echo "Running Tests..."
            }
        }
    }
}
```

Commit and push the file to the configured branch.

---

## Step 6: Configure GitHub Webhook

In your GitHub repository:

```text
Repository
    └── Settings
         └── Webhooks
              └── Add Webhook
```

Configure the webhook as follows:

**Payload URL**

```text
http://<EC2-Public-IP>:8080/github-webhook/
```

Example:

```text
http://54.xxx.xxx.xxx:8080/github-webhook/
```

**Content Type**

```text
application/json
```

**Events**

```text
Just the push event
```

Save the webhook.

---

## Step 7: Configure Jenkins Build Trigger

Open your Jenkins Pipeline job.

Go to:

```text
Configure
```

Under **Build Triggers**, enable:

```text
GitHub hook trigger for GITScm polling
```

Save the job.

---

## Step 8: Test the Configuration

Make a change in the configured branch.

Example:

```bash
git checkout main

echo "Testing Jenkins" >> README.md

git add .

git commit -m "Trigger Jenkins build"

git push origin main
```

The GitHub webhook sends a notification to Jenkins, and Jenkins automatically starts the pipeline.

---

## Branch Filtering Example

Repository branches:

```text
main
develop
feature/login
feature/payment
```

Configured branch:

```text
*/main
```

| Branch Updated  | Build Triggered |
| --------------- | --------------- |
| main            | Yes             |
| develop         | No              |
| feature/login   | No              |
| feature/payment | No              |

Only changes pushed to the configured branch trigger the pipeline.

---

## Alternative: Poll SCM

If webhooks cannot be configured, Jenkins can periodically check the repository.

Enable **Poll SCM** under **Build Triggers** and use a schedule such as:

```text
H/2 * * * *
```

This checks the repository approximately every two minutes for changes in the configured branch.

---

## Advantages

* Builds only the required branch.
* Reduces unnecessary pipeline executions.
* Saves Jenkins resources.
* Provides faster feedback for important branches.
* Enables efficient Continuous Integration workflows.

---

## Limitations

* Webhooks require Jenkins to be reachable from GitHub.
* Polling introduces a delay and consumes additional resources.
* Incorrect branch configuration may prevent builds from triggering.

---

## Troubleshooting

### Webhook returns HTTP 403

* Verify the Jenkins URL is correct.
* Ensure port **8080** is open in the EC2 Security Group.
* Confirm the webhook endpoint ends with:

```text
/github-webhook/
```

---

### Build is not triggered

* Verify the branch name matches the configured branch.
* Check that the webhook delivery was successful.
* Ensure **GitHub hook trigger for GITScm polling** is enabled.
* Confirm the `Jenkinsfile` exists in the target branch.

---

### Jenkins builds the wrong branch

Check the **Branches to build** field.

Example:

```text
*/main
```

---

## Interview Questions

### Why specify a branch in Jenkins?

To ensure the pipeline runs only for the intended branch, avoiding unnecessary builds for unrelated branches.

### How does Jenkins know when code changes?

GitHub sends a webhook notification after a push event, which triggers the Jenkins job.

### What is the difference between Poll SCM and GitHub Webhooks?

* **Poll SCM:** Jenkins periodically checks the repository for changes.
* **GitHub Webhooks:** GitHub immediately notifies Jenkins after a push event.

Webhooks are generally preferred because they provide faster builds and reduce unnecessary polling.

---

## Conclusion

By configuring a specific branch in the Jenkins Pipeline and enabling GitHub webhooks, Jenkins automatically builds only when changes are pushed to that branch. This approach improves CI/CD efficiency, reduces unnecessary builds, and is widely adopted in modern software development workflows.
