# Jenkins Pipeline – Retry Failed Stages Automatically

## Overview

This project demonstrates how to configure a Jenkins Pipeline to automatically retry failed stages. Automatic retries help recover from temporary or intermittent failures, such as network issues, API timeouts, or temporary service unavailability, without requiring manual intervention.

---

## Objective

Configure a Jenkins Pipeline to:

* Automatically retry failed stages
* Improve pipeline reliability
* Reduce failures caused by transient issues
* Continue execution if a retry succeeds

---

## Prerequisites

* Jenkins installed and running
* Pipeline Plugin installed
* Jenkins agent configured
* Git repository containing the application code
* Required build tools (Maven, Gradle, Node.js, etc.)

---

## Project Structure

```text
project/
│
├── Jenkinsfile
├── src/
├── pom.xml
└── README.md
```

---

## Jenkinsfile

```groovy
pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                retry(3) {
                    echo "Building application..."
                    sh 'mvn clean package'
                }
            }
        }

        stage('Test') {
            steps {
                retry(2) {
                    echo "Running unit tests..."
                    sh 'mvn test'
                }
            }
        }

        stage('Deploy') {
            steps {
                retry(2) {
                    echo "Deploying application..."
                    sh './deploy.sh'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed after all retry attempts.'
        }
    }
}
```

---

## How the `retry` Step Works

The `retry` step reruns the commands inside its block if they fail.

### Syntax

```groovy
retry(numberOfAttempts) {
    // Steps to execute
}
```

### Example

```groovy
retry(3) {
    sh 'mvn clean package'
}
```

In the above example:

* Jenkins attempts the command for the first time.
* If it fails, Jenkins retries automatically.
* It continues until the command succeeds or all attempts are exhausted.
* If all attempts fail, the stage is marked as failed.

---

## Execution Flow

```text
Pipeline Started
       │
       ▼
 Build Stage
       │
       ├── Success ─────────────► Next Stage
       │
       └── Failure
              │
          Retry Attempt
              │
      Success?
       │         │
      Yes        No
       │          │
Next Stage   Retry Again
                  │
          Attempts Exhausted
                  │
                  ▼
          Pipeline Failed
```

---

## Why Use Retry?

Automatic retries are useful for temporary failures such as:

* Network interruptions
* Docker registry connection failures
* Git clone failures
* Maven dependency download issues
* Cloud API throttling
* Kubernetes API timeouts
* Temporary SSH connectivity issues

---

## When Not to Use Retry

Do **not** use retries for permanent failures such as:

* Compilation errors
* Syntax errors
* Application bugs
* Failed unit tests due to code issues
* Invalid credentials
* Missing configuration files

These issues require fixing the code or configuration rather than retrying.

---

## Best Practices

* Retry only stages that are likely to fail temporarily.
* Keep retry attempts between **2 and 3**.
* Avoid wrapping the entire pipeline in a single `retry` block.
* Log retry attempts for easier troubleshooting.
* Add a delay between retries when interacting with external services.

Example:

```groovy
retry(3) {
    sleep(time: 10, unit: 'SECONDS')
    sh 'docker push myapp:latest'
}
```

---

## Sample Console Output

```text
[Pipeline] stage
Building application...

Attempt 1
Build failed.

Retrying...

Attempt 2
Build failed.

Retrying...

Attempt 3
Build successful.

Proceeding to next stage...
```

---

## Advantages

* Improves pipeline reliability
* Reduces manual reruns
* Handles transient failures automatically
* Increases CI/CD stability
* Saves developer time

---

## Limitations

* Does not fix permanent errors
* Excessive retries may increase build time
* Should be used only where appropriate

---

## Interview Questions

### 1. What is the purpose of the `retry` step in Jenkins?

It automatically reruns failed steps to recover from temporary or intermittent failures.

---

### 2. Does `retry` rerun the entire pipeline?

No. It reruns only the commands inside the `retry` block.

---

### 3. Can every stage use `retry`?

Yes, but it should be used only for stages that may fail due to temporary issues.

---

### 4. What happens if all retry attempts fail?

The stage fails, and the pipeline continues with its configured failure handling (or stops if not handled).

---

## Conclusion

The Jenkins `retry` step is an effective way to improve the resilience of CI/CD pipelines. By automatically retrying operations affected by temporary issues, it minimizes unnecessary build failures and reduces manual intervention. However, retries should be applied selectively and not as a substitute for fixing genuine code or configuration problems.
