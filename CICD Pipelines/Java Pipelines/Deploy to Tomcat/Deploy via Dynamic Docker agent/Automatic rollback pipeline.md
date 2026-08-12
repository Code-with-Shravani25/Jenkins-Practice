# Automatic rollback if deployment failed

```bash
pipeline {

    agent {
        label 'docker-agent'
    }

    environment {
        IMAGE_NAME = "shravani2001/javademo"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
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

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }

        stage('Save Current Image for Rollback') {
            steps {
                sh '''
                    echo "Saving currently deployed image for rollback..."

                    docker pull ${IMAGE_NAME}:latest || true

                    docker tag \
                        ${IMAGE_NAME}:latest \
                        ${IMAGE_NAME}:rollback

                    docker push ${IMAGE_NAME}:rollback
                '''
            }
        }

        stage('Push New Image') {
            steps {
                sh '''
                    echo "Pushing new latest image..."

                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    echo "Deploying new latest image..."

                    docker stop java-app || true
                    docker rm java-app || true

                    docker pull ${IMAGE_NAME}:latest

                    docker run -d \
                        --name java-app \
                        -p 8081:8080 \
                        ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    echo "Waiting for application to start..."
                    sleep 20

                    echo "Checking application health..."

                    curl --fail http://localhost:8081

                    echo "Application is healthy!"
                '''
            }
        }
    }

    post {

        failure {
            echo "Deployment failed! Starting rollback..."

            sh '''
                echo "Stopping failed deployment..."

                docker stop java-app || true
                docker rm java-app || true

                echo "Pulling rollback image..."

                docker pull ${IMAGE_NAME}:rollback

                echo "Starting previous version..."

                docker run -d \
                    --name java-app \
                    -p 8081:8080 \
                    ${IMAGE_NAME}:rollback

                echo "Rollback completed successfully!"
            '''
        }

        success {
            echo "Deployment completed successfully!"
        }

        always {
            sh 'docker logout || true'
        }
    }
}
```
