# Create a Jenkins pipeline that executes jobs on: Different nodes using labels

## Overview

To execute different stages on different Jenkins nodes, assign
**labels** to agents and use those labels in the pipeline.

## Example Setup

| Agent | Node Name | Label |
|-------|-----------|-------|
| Agent 1 | `linux-agent` | `linux` |
| Agent 2 | `docker-agent` | `docker` |
| Agent 3 | `maven-agent` | `maven` |

## Declarative Pipeline Example

``` groovy
pipeline {
    agent none

    stages {

        stage('Build') {
            agent {
                label 'maven'
            }
            steps {
                sh 'hostname'
                sh 'mvn --version'
            }
        }

        stage('Docker Build') {
            agent {
                label 'docker'
            }
            steps {
                sh 'hostname'
                sh 'docker --version'
            }
        }

        stage('Testing') {
            agent {
                label 'linux'
            }
            steps {
                sh 'hostname'
                sh 'echo Running Tests'
            }
        }
    }
}
```

## What Happens?

  Stage          Runs On
  -------------- ---------------------------
  Build          Agent with label `maven`
  Docker Build   Agent with label `docker`
  Testing        Agent with label `linux`

Jenkins automatically finds an available node with the specified label
and runs that stage there.

## Key Points

-   `agent none` prevents the pipeline from using a default agent.
-   Each stage specifies its own agent using a label.
-   Jenkins matches the label with an available node.
-   This approach distributes workloads across multiple agents.
-   It is commonly used in distributed Jenkins environments.
