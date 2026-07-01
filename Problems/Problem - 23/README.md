# Jenkins Pipeline Concepts

This document explains four important Jenkins Pipeline concepts commonly used in CI/CD:

* Multibranch Pipeline
* Multistage Pipeline
* Multi-Environment Deployment Pipeline
* Parallel Stages

---

# 1. Multibranch Pipeline

## What is a Multibranch Pipeline?

A **Multibranch Pipeline** is a Jenkins project that automatically discovers branches from a Git repository and creates a separate pipeline for each branch containing a `Jenkinsfile`.

Instead of creating multiple Jenkins jobs manually, Jenkins automatically scans the repository and manages pipelines for all branches.

## Why do we use it?

Suppose your Git repository contains the following branches:

```text
main
develop
feature/login
feature/payment
bugfix/header
```

Without a Multibranch Pipeline:

* Create one Jenkins job for `main`
* Create another for `develop`
* Create another for `feature/login`
* Continue creating jobs for every new branch

With a Multibranch Pipeline:

```text
Git Repository
       │
       ▼
 Jenkins Multibranch Pipeline
       │
 ├── main
 ├── develop
 ├── feature/login
 ├── feature/payment
 └── bugfix/header
```

Whenever a new branch containing a `Jenkinsfile` is pushed, Jenkins automatically creates a new pipeline for it.

## Real-world Example

Different branches can perform different tasks.

| Branch    | Action                          |
| --------- | ------------------------------- |
| main      | Build and Deploy to Production  |
| develop   | Build and Deploy to Development |
| feature/* | Build and Run Unit Tests Only   |
| bugfix/*  | Build and Test                  |

---

# 2. Multistage Pipeline

## What is a Multistage Pipeline?

A **Multistage Pipeline** divides the CI/CD process into multiple logical stages.

Each stage performs a specific task such as:

* Checkout
* Build
* Test
* Scan
* Package
* Deploy

## Pipeline Flow

```text
Checkout
    │
    ▼
Build
    │
    ▼
Unit Test
    │
    ▼
Sonar Scan
    │
    ▼
Docker Build
    │
    ▼
Push Docker Image
    │
    ▼
Deploy
```

## Example Jenkinsfile

```groovy
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git 'repo-url'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Deploy') {
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

## Benefits

* Better readability
* Easier debugging
* Stage-wise build status
* Easy to identify failures

---

# 3. Multi-Environment Deployment Pipeline

## What is a Multi-Environment Deployment Pipeline?

A **Multi-Environment Deployment Pipeline** deploys the same application to multiple environments in a controlled sequence.

Typical deployment flow:

```text
Developer
      │
      ▼
Development (Dev)
      │
      ▼
Quality Assurance (QA)
      │
      ▼
User Acceptance Testing (UAT)
      │
      ▼
Production
```

## Pipeline Flow

```text
Checkout
    │
    ▼
Build
    │
    ▼
Test
    │
    ▼
Deploy to Dev
    │
    ▼
Approval
    │
    ▼
Deploy to QA
    │
    ▼
Approval
    │
    ▼
Deploy to UAT
    │
    ▼
Approval
    │
    ▼
Deploy to Production
```

## Example Jenkinsfile

```groovy
pipeline {

    agent any

    stages {

        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Deploy Dev') {
            steps {
                sh './deploy-dev.sh'
            }
        }

        stage('Deploy QA') {
            steps {
                sh './deploy-qa.sh'
            }
        }

        stage('Deploy UAT') {
            steps {
                sh './deploy-uat.sh'
            }
        }

        stage('Deploy Production') {
            steps {
                sh './deploy-prod.sh'
            }
        }
    }
}
```

## Typical Workflow

| Environment | Deployment Type                |
| ----------- | ------------------------------ |
| Dev         | Automatic                      |
| QA          | Automatic or after testing     |
| UAT         | Manual approval                |
| Production  | Manual approval and deployment |

---

# 4. Parallel Stages

## What are Parallel Stages?

By default, Jenkins executes stages one after another.

### Sequential Execution

```text
Build
   │
   ▼
Unit Test
   │
   ▼
Integration Test
   │
   ▼
Security Scan
   │
   ▼
Deploy
```

This can take a long time.

If multiple tasks are independent, Jenkins can execute them simultaneously using **Parallel Stages**.

### Parallel Execution

```text
               Build
                 │
      ┌──────────┼──────────┐
      ▼          ▼          ▼
 Unit Test  Security Scan  Integration Test
      └──────────┼──────────┘
                 ▼
              Deploy
```

## Example Jenkinsfile

```groovy
pipeline {

    agent any

    stages {

        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Testing') {

            parallel {

                stage('Unit Test') {
                    steps {
                        sh 'mvn test'
                    }
                }

                stage('Integration Test') {
                    steps {
                        sh './integration.sh'
                    }
                }

                stage('Security Scan') {
                    steps {
                        sh './scan.sh'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

## Example

Sequential execution:

```text
Unit Test          : 5 minutes
Integration Test   : 8 minutes
Security Scan      : 6 minutes

Total Time = 19 minutes
```

Parallel execution:

```text
Unit Test
Integration Test
Security Scan
```

All stages execute simultaneously.

Total time becomes approximately **8 minutes** (the duration of the longest stage), provided enough Jenkins executors are available.

---

# Comparison

| Concept                                   | Purpose                                          | Example                                    |
| ----------------------------------------- | ------------------------------------------------ | ------------------------------------------ |
| **Multibranch Pipeline**                  | Automatically create pipelines for Git branches  | main, develop, feature/login               |
| **Multistage Pipeline**                   | Organize the CI/CD workflow into stages          | Checkout → Build → Test → Deploy           |
| **Multi-Environment Deployment Pipeline** | Deploy applications across multiple environments | Dev → QA → UAT → Production                |
| **Parallel Stages**                       | Run independent tasks simultaneously             | Unit Test, Integration Test, Security Scan |

---

# How They Work Together

In a real-world DevOps project, these concepts are often used together.

```text
GitHub Repository
│
├── main
├── develop
└── feature/*
        │
        ▼
Multibranch Pipeline
        │
        ▼
Multistage Pipeline
├── Checkout
├── Build
├── Parallel Testing
│   ├── Unit Tests
│   ├── Integration Tests
│   └── Security Scan
├── Package
└── Deploy
        │
        ▼
Multi-Environment Deployment
Dev → QA → UAT → Production
```

This architecture provides:

* Automatic pipeline creation for every Git branch.
* A well-organized CI/CD workflow using multiple stages.
* Faster execution by running independent tasks in parallel.
* Safe and controlled deployments through multiple environments before reaching production.

---

# Conclusion

* **Multibranch Pipeline** manages multiple Git branches automatically.
* **Multistage Pipeline** divides the CI/CD workflow into logical stages.
* **Multi-Environment Deployment Pipeline** promotes applications through Dev, QA, UAT, and Production.
* **Parallel Stages** execute independent tasks simultaneously, reducing overall pipeline execution time.

Together, these features form the foundation of modern Jenkins CI/CD pipelines used in enterprise software development.
