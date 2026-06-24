# Write a Jenkinsfile using: stages, steps, environment variables, post actions
```bash
pipeline {

    agent any

    environment {
        APP_NAME = "my-java-app"
        BUILD_ENV = "DEV"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                git branch: 'main',
                    url: 'https://github.com/user/repository.git'
            }
        }

        stage('Build') {
            steps {
                echo "Building ${APP_NAME}"
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                echo "Running unit tests..."
                sh 'mvn test'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying ${APP_NAME} to ${BUILD_ENV}"
                sh 'echo Deployment Successful'
            }
        }
    }

    post {

        always {
            echo "Pipeline execution completed."
        }

        success {
            echo "Build and deployment successful."
        }

        failure {
            echo "Build or deployment failed."
        }

        unstable {
            echo "Build is unstable."
        }
    }
}
```
