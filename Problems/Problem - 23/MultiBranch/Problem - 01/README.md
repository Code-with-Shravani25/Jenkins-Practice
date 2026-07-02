# Jenkins Pipeline: Deploy to Different Environments Based on Branch Name

## Project Overview

This project demonstrates how to create a Jenkins **Multibranch Pipeline** that automatically deploys an application to different environments based on the Git branch that triggers the build.

### Branch to Environment Mapping

| Git Branch | Deployment Environment |
|------------|------------------------|
| develop | Development |
| qa | QA |
| staging | Staging |
| main | Production |

---

# Prerequisites

- AWS EC2 Instance (Ubuntu)
- Java
- Jenkins
- Git
- Maven (Optional)
- Docker (Optional)
- GitHub Repository

---

# Architecture

```
                GitHub Repository
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    develop           qa          staging         main
        │              │              │            │
        └──────────────┼──────────────┴────────────┘
                       │
          Jenkins Multibranch Pipeline
                       │
               Detects BRANCH_NAME
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   Deploy to      Deploy to      Deploy to      Deploy to
 Development          QA           Staging      Production
```

---

# Step 1: Launch an EC2 Instance

Launch an Ubuntu EC2 instance and install the required software.

Install:

- Java
- Jenkins
- Git

(Optional)

- Maven
- Docker

Verify the installations:

```bash
java -version
git --version
mvn -version
docker --version
```

---

# Step 2: Create a GitHub Repository

Example repository structure:

```
BranchBasedDeployment
│
├── Jenkinsfile
├── pom.xml
└── src/
```

---

# Step 3: Create Branches

Create the required branches.

```bash
git checkout -b develop
git push origin develop

git checkout -b qa
git push origin qa

git checkout -b staging
git push origin staging
```

Your repository should now contain:

- main
- develop
- qa
- staging

---

# Step 4: Add the Jenkinsfile

Create a `Jenkinsfile` in the root of the repository.

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

        stage('Deploy') {
            steps {
                script {

                    if (env.BRANCH_NAME == 'develop') {

                        echo "Deploying to Development Environment"

                    } else if (env.BRANCH_NAME == 'qa') {

                        echo "Deploying to QA Environment"

                    } else if (env.BRANCH_NAME == 'staging') {

                        echo "Deploying to Staging Environment"

                    } else if (env.BRANCH_NAME == 'main') {

                        echo "Deploying to Production Environment"

                    } else {

                        echo "No deployment configured."

                    }

                }
            }
        }

    }
}
```

---

# Step 5: Push the Jenkinsfile

Commit and push the changes to all branches.

```bash
git add .
git commit -m "Added Jenkinsfile"

git push origin develop
git push origin qa
git push origin staging
git push origin main
```

---

# Step 6: Create a Multibranch Pipeline

1. Open Jenkins Dashboard.
2. Click **New Item**.
3. Enter a project name.
4. Select **Multibranch Pipeline**.
5. Click **OK**.

---

# Step 7: Configure the Branch Source

1. Navigate to **Branch Sources**.
2. Click **Add Source**.
3. Select **Git** or **GitHub**.
4. Enter the repository URL.
5. Add GitHub credentials if the repository is private.

Example:

```
https://github.com/username/BranchBasedDeployment.git
```

---

# Step 8: Scan the Repository

Click **Scan Multibranch Pipeline Now**.

Jenkins automatically discovers the branches:

- develop
- qa
- staging
- main

Each branch is created as a separate pipeline job.

---

# Step 9: Build Each Branch

Run each branch individually to verify the deployment logic.

### Develop Branch

```
Building Application...
Running Tests...
Deploying to Development Environment
```

### QA Branch

```
Building Application...
Running Tests...
Deploying to QA Environment
```

### Staging Branch

```
Building Application...
Running Tests...
Deploying to Staging Environment
```

### Main Branch

```
Building Application...
Running Tests...
Deploying to Production Environment
```

---

# How It Works

Jenkins automatically sets the environment variable:

```
env.BRANCH_NAME
```

Depending on the branch that triggered the build, the pipeline executes the corresponding deployment logic.

Example:

| Branch | BRANCH_NAME Value | Deployment |
|---------|-------------------|------------|
| develop | develop | Development |
| qa | qa | QA |
| staging | staging | Staging |
| main | main | Production |

---

# Recommended Approach Using `when`

Instead of using multiple `if-else` statements, Jenkins provides the `when` directive to execute stages only for specific branches.

Example:

```groovy
stage('Deploy to Dev') {
    when {
        branch 'develop'
    }
    steps {
        echo "Deploying to Development"
    }
}

stage('Deploy to QA') {
    when {
        branch 'qa'
    }
    steps {
        echo "Deploying to QA"
    }
}

stage('Deploy to Staging') {
    when {
        branch 'staging'
    }
    steps {
        echo "Deploying to Staging"
    }
}

stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        echo "Deploying to Production"
    }
}
```

This approach provides:
- Better readability
- Cleaner pipeline structure
- Easier maintenance
- Clear stage visibility in the Jenkins UI

---

# Real-World Deployment

In production environments, the deployment stages typically execute deployment scripts or automation tools instead of simple `echo` statements.

Example:

```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        sh './deploy-prod.sh'
    }
}
```

Deployment targets may include:

- Development server
- QA server
- Staging server
- Production server
- Kubernetes cluster
- Amazon ECS
- Docker host
- Virtual machines

---

# Benefits

- Single Jenkinsfile for all environments
- Automatic deployment based on branch
- Supports Git branching workflows
- Easy to maintain
- Scalable for enterprise CI/CD pipelines
- Reduces manual deployment effort

---

# Conclusion

A Jenkins Multibranch Pipeline enables automated deployments by identifying the Git branch that triggered the build. Using `env.BRANCH_NAME` or the `when` directive, a single Jenkinsfile can manage deployments to Development, QA, Staging, and Production environments, making the CI/CD process efficient, scalable, and easy to maintain.
