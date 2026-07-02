# Create multibranch pipeline in Jenkins.
- A Multibranch Pipeline in Jenkins automatically discovers branches in a Git repository and creates a separate pipeline for each branch. Each branch must contain its own Jenkinsfile.
  
## Advantages
- Automatically detects new branches.
- Automatically removes deleted branches.
- Each branch has its own build history.
- Ideal for Git workflows like feature branches, release branches, and hotfixes.
- No need to manually create a new Jenkins job for every branch.

# Jenkins Multibranch Pipeline

## Objective

Create a Jenkins **Multibranch Pipeline** that automatically discovers branches from a Git repository and builds each branch using its own `Jenkinsfile`.

---

## Prerequisites

- Jenkins installed
- Java installed
- Git installed
- GitHub repository
- Jenkins Pipeline Plugin
- Git Plugin
- GitHub Branch Source Plugin (recommended)

---

## Step 1: Launch Jenkins

Install the required software:

- Java
- Jenkins
- Git

Verify the installations:

```bash
java -version
jenkins --version
git --version
```

Access Jenkins:

```
http://<JENKINS_SERVER_IP>:8080
```

---

## Step 2: Create a GitHub Repository

Example repository structure:

```
my-project/
│
├── src/
├── pom.xml
└── Jenkinsfile
```

Push the project to GitHub.

---

## Step 3: Create Multiple Branches

Create and push multiple branches.

Example:

```bash
git checkout -b develop
git push origin develop

git checkout -b feature/login
git push origin feature/login

git checkout -b feature/payment
git push origin feature/payment
```

Your repository may contain branches like:

```
main
develop
feature/login
feature/payment
release/v1.0
```

Each branch should contain a `Jenkinsfile`.

---

## Step 4: Create a Multibranch Pipeline

1. Open Jenkins.
2. Click **New Item**.
3. Enter a job name.
4. Select **Multibranch Pipeline**.
5. Click **OK**.

---

## Step 5: Configure Branch Source

Under **Branch Sources**:

1. Click **Add Source**.
2. Select **Git** (or **GitHub** if using the GitHub Branch Source Plugin).
3. Enter the repository URL.

Example:

```
https://github.com/username/my-project.git
```

If the repository is private:

- Add GitHub credentials.
- Select the credentials in Jenkins.

---

## Step 6: Configure Build

Under **Build Configuration**:

**Mode**

```
by Jenkinsfile
```

**Script Path**

```
Jenkinsfile
```

If your Jenkinsfile is stored elsewhere:

```
jenkins/Jenkinsfile
```

---

## Step 7: Save and Scan Repository

Click **Save**.

Jenkins scans the repository and discovers all available branches.

Example:

```
main
develop
feature/login
feature/payment
release/v1.0
```

A separate pipeline is automatically created for each branch.

---

## Step 8: Jenkinsfile

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
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

    }

    post {
        success {
            echo "Build Successful"
        }

        failure {
            echo "Build Failed"
        }
    }
}
```

---

## Repository Structure

```
my-project/
│
├── Jenkinsfile
├── pom.xml
├── src/
└── target/
```

---

## Branch Structure

```
Repository
│
├── main
├── develop
├── feature/login
├── feature/payment
└── release/v1.0
```

---

## How It Works

1. Jenkins scans the Git repository.
2. Every branch containing a `Jenkinsfile` is discovered.
3. Jenkins automatically creates a separate pipeline for each branch.
4. Every branch maintains:
   - Separate build history
   - Separate console logs
   - Separate workspace
5. When a new branch is pushed, Jenkins automatically detects it (through periodic scanning or Git webhooks) and creates a new pipeline.

---

## Advantages

- Automatic branch discovery
- No manual job creation
- Supports feature branch workflows
- Separate build history for each branch
- Easy integration with GitHub and GitLab
- Ideal for CI/CD workflows

---

## Pipeline Flow

```
GitHub Repository
        │
        ▼
Jenkins Scans Repository
        │
        ▼
Detects All Branches
        │
        ▼
Creates Individual Pipelines
        │
        ▼
Checks Out Branch Code
        │
        ▼
Build
        │
        ▼
Test
        │
        ▼
Build Result
```

---

## Pipeline vs Multibranch Pipeline

| Feature | Pipeline | Multibranch Pipeline |
|----------|----------|----------------------|
| Supports one branch | ✅ | ❌ |
| Supports multiple branches | ❌ | ✅ |
| Automatic branch discovery | ❌ | ✅ |
| Separate build history | ❌ | ✅ |
| Uses Jenkinsfile | ✅ | ✅ |
| Manual job creation | Required | Not Required |

---

## Conclusion

A **Multibranch Pipeline** automatically discovers branches in a Git repository and creates an independent Jenkins pipeline for each branch. This approach simplifies CI/CD for projects using feature branches, release branches, and Git-based workflows by eliminating the need to manually create or manage separate pipeline jobs.

<img width="1911" height="930" alt="image" src="https://github.com/user-attachments/assets/3aa965c4-40cc-43ff-b8b0-7b1e78bb13be" />
