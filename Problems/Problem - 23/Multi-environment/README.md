# Create multibranch pipeline in Jenkins.
- A multi-environment deployment pipeline allows you to deploy the same application to different environments (Development, Staging, Production) using a single Jenkinsfile
```bash
pipeline {
    agent any
    
    environment{
        APP_NAME = 'my-app'
    }
    stages {
        stage('GitClone') {
            steps {
                git branch: 'main', url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy to Development') {
            steps {
                echo "Deploying ${APP_NAME} to Development..."
                sh '''
                    echo "Deployment to Development completed."
                '''
            }
        }

        stage('Approval for Staging') {
            steps {
                input message: 'Deploy to Staging?', ok: 'Proceed'
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo "Deploying ${APP_NAME} to Staging..."
                sh '''
                    echo "Deployment to Staging completed."
                '''
            }
        }

        stage('Approval for Production') {
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
            }
        }

        stage('Deploy to Production') {
            steps {
                echo "Deploying ${APP_NAME} to Production..."
                sh '''
                    echo "Deployment to Production completed."
                '''
            }
        }
    }

    post {
        success {
            echo "Application successfully deployed to all environments."
        }

        failure {
            echo "Pipeline failed."
        }

        always {
            cleanWs() # It deletes the Jenkins workspace after the pipeline finishes
        }
    }
}
```
