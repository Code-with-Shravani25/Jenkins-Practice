# Configure Jenkins pipeline for: Pull Request validation
# Jenkins Pull Request (PR) Validation using Multibranch Pipeline

## 📌 Project Overview

This project demonstrates how to configure a **Jenkins Multibranch Pipeline** to automatically validate **GitHub Pull Requests (PRs)**.

Whenever a developer creates a Pull Request, GitHub sends a webhook notification to Jenkins. Jenkins automatically discovers the PR, creates a dedicated PR job, executes the pipeline defined in `Jenkinsfile2`, and validates the code before it is merged into the target branch.

---

# 🏗️ Architecture

```text
                +------------------+
                |   Developer      |
                +--------+---------+
                         |
                         | Push Feature Branch
                         |
                         v
                +------------------+
                |     GitHub       |
                +--------+---------+
                         |
                         | Create Pull Request
                         |
                         v
                +------------------+
                | GitHub Webhook   |
                +--------+---------+
                         |
                         |
                         v
                +------------------+
                | Jenkins          |
                | Multibranch Job  |
                +--------+---------+
                         |
          +--------------+--------------+
          |                             |
          v                             v
   Discover Branch              Discover PR
          |                             |
          +--------------+--------------+
                         |
                         v
                Execute Jenkinsfile2
                         |
                         v
                  Build Success/Failure
```

---

# 🎯 Objective

The objective of this project is to:

- Configure Jenkins Multibranch Pipeline.
- Integrate Jenkins with GitHub.
- Automatically discover branches.
- Automatically discover Pull Requests.
- Trigger builds using GitHub Webhooks.
- Validate Pull Requests before merging.

---

# 🛠️ Prerequisites

Before starting, ensure you have:

- AWS EC2 Instance
- Java Installed
- Maven Installed
- Jenkins Installed
- Git Installed
- GitHub Account

### Jenkins Plugins

- Git
- GitHub
- GitHub Branch Source
- Pipeline

---

# 📂 Repository

```
https://github.com/Code-with-Shravani25/MultiBranch-Pipeline.git
```

---

# 🚀 Step 1: Launch EC2 Instance

Launch an EC2 instance and connect to it using SSH.

---

# 🚀 Step 2: Install Required Software

Install:

- Java
- Maven
- Jenkins

Verify installations:

```bash
java -version
```

```bash
mvn -version
```

```bash
jenkins --version
```

---

# 🚀 Step 3: Configure Jenkins Tools

Navigate to:

```
Manage Jenkins
      ↓
Tools
```

Configure:

- JDK
- Maven

Example:

```
JDK Name    : JDK17
Maven Name  : Maven3
```

---

# 🚀 Step 4: Create Multibranch Pipeline

```
New Item
    ↓
Multibranch Pipeline
```

Provide a job name.

Example:

```
PR-Validation
```

---

# 🚀 Step 5: Configure Branch Source

Select **GitHub** as the Branch Source.

Repository URL:

```
https://github.com/Code-with-Shravani25/MultiBranch-Pipeline.git
```

Keep the default Branch Discovery settings.

Change the **Script Path** from

```
Jenkinsfile
```

to

```
Jenkinsfile2
```

Save the configuration.

---

# 🚀 Step 6: Configure GitHub Webhook

Open your GitHub repository.

```
Settings
    ↓
Webhooks
    ↓
Add Webhook
```

Payload URL

```
http://<EC2-PUBLIC-IP>:8080/github-webhook/
```

Content Type

```
application/json
```

Select individual events:

- ✅ Push
- ✅ Pull Request

Save the webhook.

---

# 🚀 Step 7: Scan Repository

Open Jenkins.

Click

```
PR-Validation
    ↓
Scan Multibranch Pipeline Now
```

Jenkins scans the repository and discovers all available branches.

Example:

```
main
```

---

# 🚀 Step 8: Create Feature Branch

Create a new branch.

Example:

```
feature-login
```

Push the branch to GitHub.

Jenkins automatically creates a branch job.

```
PR-Validation
│
├── main
└── feature-login
```

---

# 🚀 Step 9: Create Pull Request

Open GitHub.

GitHub displays

```
Compare & pull request
```

Click

```
Compare & pull request
```

Verify

```
Base Branch    : main
Compare Branch : feature-login
```

Provide a title.

Example

```
Testing PR Validation
```

Click

```
Create Pull Request
```

---

# 🚀 Step 10: Pull Request Validation

Once the Pull Request is created:

1. GitHub sends a Pull Request event through the webhook.
2. Jenkins receives the webhook.
3. Jenkins discovers the Pull Request.
4. Jenkins creates a dedicated PR job.
5. Jenkins executes `Jenkinsfile2`.
6. The build result is displayed.

Example:

```
PR-Validation
│
├── main
├── feature-login
└── PR-1
```

The **PR-1** job validates the Pull Request before it is merged into the target branch.

---

# 🔄 Workflow

```text
Developer
    │
    ▼
Create Feature Branch
    │
    ▼
Push Code
    │
    ▼
GitHub
    │
    ▼
Create Pull Request
    │
    ▼
GitHub Webhook
    │
    ▼
Jenkins Multibranch Pipeline
    │
    ▼
PR Job Created
    │
    ▼
Execute Jenkinsfile2
    │
    ▼
Build Success / Failure
```

---

# ✅ Expected Output

- Jenkins automatically discovers new branches.
- Jenkins automatically discovers Pull Requests.
- A separate PR job is created.
- Jenkins executes `Jenkinsfile2`.
- The Pull Request is validated before merging.

---

# 📚 Key Concepts

- Jenkins Multibranch Pipeline
- Pull Request Validation
- GitHub Webhooks
- Branch Discovery
- Pull Request Discovery
- Jenkinsfile
- Continuous Integration (CI)

---

# 🎓 Interview Questions

### What is Pull Request Validation?

Pull Request Validation is the process of automatically building and testing code whenever a Pull Request is created or updated to ensure the changes are safe to merge.

---

### Why do we use a Multibranch Pipeline?

A Multibranch Pipeline automatically discovers branches and Pull Requests, creates separate jobs for each, and executes the pipeline without manual job creation.

---

### Why are GitHub Webhooks required?

GitHub Webhooks notify Jenkins immediately whenever a Push or Pull Request event occurs, allowing Jenkins to trigger builds automatically.

---

### Why did we change the Script Path?

By default Jenkins looks for a file named `Jenkinsfile`. Since this project uses `Jenkinsfile2`, the Script Path was updated so Jenkins executes the correct pipeline.

---

### What happens after a Pull Request is created?

GitHub sends a Pull Request event to Jenkins through a webhook. Jenkins discovers the PR, creates a dedicated PR job, checks out the PR code, executes the pipeline defined in `Jenkinsfile2`, and reports the build status before the code is merged.

---

# 👨‍💻 Author

**Shravani Budharam**

DevOps | AWS | Linux | Jenkins | Docker | Kubernetes
