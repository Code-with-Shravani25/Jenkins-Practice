# Write a Jenkins pipeline that: Uses environment variables dynamically
```bash
pipeline {

    agent any

    environment {
        APP_NAME    = "my-app" # static env variable
        BUILD_NO    = "${env.BUILD_NUMBER}"
        BRANCH_NAME = "${env.GIT_BRANCH}"
        JOB_NAME    = "${env.JOB_NAME}"
        IMAGE_TAG   = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Display Variables') {
            steps {
                echo "Application : ${APP_NAME}"
                echo "Build Number: ${BUILD_NO}"
                echo "Branch Name : ${BRANCH_NAME}"
                echo "Job Name    : ${JOB_NAME}"
                echo "Image Tag   : ${IMAGE_TAG}"
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package"
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                docker build -t myrepo/${APP_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying build ${BUILD_NO}"
            }
        }
    }

    post {
        success {
            echo "Build ${BUILD_NO} completed successfully"
        }
        failure {
            echo "Build ${BUILD_NO} failed"
        }
    }
}
```
- A dynamic environment variable is an environment variable whose value is determined at runtime rather than being hardcoded.
- Dynamic environment variables are variables whose values are generated or assigned during pipeline execution based on runtime information such as build number, branch name, Git commit ID, parameters, timestamps, or script output, instead of being hardcoded in the Jenkinsfile.

-In many cases you don't need to create a separate environment variable. You can use Jenkins built-in variables directly inside steps.
```bash
pipeline {
    agent any

    stages {

        stage('Info') {
            steps {
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Job Name: ${env.JOB_NAME}"
                echo "Workspace: ${env.WORKSPACE}"
                echo "Branch: ${env.GIT_BRANCH}"
            }
        }
    }
}
```
