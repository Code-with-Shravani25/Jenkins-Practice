# Jenkins Shared Library

## What is a Jenkins Shared Library?

A **Jenkins Shared Library** is a collection of reusable Groovy scripts that can be shared across multiple Jenkins pipelines. Instead of writing the same pipeline code in every Jenkinsfile, common logic is written once in a shared library and reused by multiple projects.

### Benefits

- Reusable pipeline code
- Cleaner and shorter Jenkinsfiles
- Easy maintenance
- Centralized updates
- Version controlled using Git
- Promotes standardization across projects

---

# Step 1: Create a Git Repository

Create a GitHub repository named:

```
jenkins-shared-library
```

Repository Structure:

```
jenkins-shared-library/
│
├── vars/
│   ├── buildApp.groovy
│   ├── testApp.groovy
│   └── packageApp.groovy
│
├── src/
│
├── resources/
│
└── README.md
```

### Folder Description

| Folder | Purpose |
|---------|----------|
| vars | Stores reusable pipeline functions. These functions can be called directly from the Jenkinsfile. |
| src | Stores Groovy classes for complex business logic. |
| resources | Stores static files like YAML, JSON, templates, properties, etc. |

---

# Step 2: Create Shared Library Functions

## buildApp.groovy

Location:

```
vars/buildApp.groovy
```

```groovy
def call() {
    echo "Building Maven Project..."
    sh 'mvn clean compile'
}
```

---

## testApp.groovy

Location:

```
vars/testApp.groovy
```

```groovy
def call() {
    echo "Running Test Cases..."
    sh 'mvn test'
}
```

---

## packageApp.groovy

Location:

```
vars/packageApp.groovy
```

```groovy
def call() {
    echo "Packaging Application..."
    sh 'mvn package'
}
```

---

# Step 3: Push Shared Library to GitHub

Initialize Git repository.

```bash
git init
```

Add all files.

```bash
git add .
```

Commit changes.

```bash
git commit -m "Initial Jenkins Shared Library"
```

Rename branch.

```bash
git branch -M main
```

Add remote repository.

```bash
git remote add origin https://github.com/<username>/jenkins-shared-library.git
```

Push repository.

```bash
git push -u origin main
```

---

# Step 4: Configure Shared Library in Jenkins

Go to

```
Manage Jenkins
        ↓
System
        ↓
Global Trusted Pipeline Libraries
        ↓
Add
```

Configure the library as follows:

| Field | Value |
|--------|-------|
| Name | shared-lib |
| Default Version | main |
| Retrieval Method | Modern SCM |
| SCM | Git |
| Repository URL | https://github.com/<username>/jenkins-shared-library.git |

Click **Save**.

---

# Step 5: Jenkins Pipeline Using Shared Library

```groovy
@Library('shared-lib') _

pipeline {

    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
            }
        }

        stage('Build') {
            steps {
                buildApp()
            }
        }

        stage('Test') {
            steps {
                testApp()
            }
        }

        stage('Package') {
            steps {
                packageApp()
            }
        }
    }
}
```

---

# How the Pipeline Works

```
Pipeline Starts
       │
       ▼
Loads Shared Library
(@Library('shared-lib'))
       │
       ▼
Checkout Source Code
       │
       ▼
buildApp()
       │
       ▼
vars/buildApp.groovy
       │
       ▼
testApp()
       │
       ▼
vars/testApp.groovy
       │
       ▼
packageApp()
       │
       ▼
vars/packageApp.groovy
       │
       ▼
Pipeline Completed
```

---

# Why do build.groovy, test.groovy and package.groovy give errors?

Jenkins Pipeline already provides many built-in steps such as:

- build
- checkout
- git
- sh
- stage
- parallel
- input

If you create shared library files with the same names, Jenkins may call the built-in pipeline step instead of your shared library function.

For example:

```
vars/build.groovy
```

Calling

```groovy
build()
```

does **not** invoke your shared library. Instead, Jenkins invokes its built-in **build** step, which is used to trigger another Jenkins job.

Since the built-in **build** step requires a **job** parameter, Jenkins throws the following error:

```
Missing required parameter: "job"

build()
```

Similarly, using names like `test.groovy` or `package.groovy` can also lead to conflicts with existing pipeline steps or plugins, making the behavior unpredictable.

---

# Recommended Naming Convention

Always use descriptive and unique names for shared library functions.

| Avoid | Recommended |
|---------|-------------|
| build.groovy | buildApp.groovy |
| test.groovy | testApp.groovy |
| package.groovy | packageApp.groovy |
| deploy.groovy | deployApp.groovy |
| docker.groovy | dockerBuild.groovy |

Then call them as:

```groovy
buildApp()
testApp()
packageApp()
deployApp()
```

This avoids conflicts with Jenkins' built-in pipeline steps and makes the pipeline easier to understand.

---

# Advantages of Jenkins Shared Library

- Eliminates duplicate pipeline code.
- Centralizes reusable pipeline logic.
- Makes Jenkinsfiles shorter and cleaner.
- Simplifies maintenance and updates.
- Supports versioning through Git branches and tags.
- Encourages standardization across multiple projects.
- Improves readability and collaboration for CI/CD pipelines.
