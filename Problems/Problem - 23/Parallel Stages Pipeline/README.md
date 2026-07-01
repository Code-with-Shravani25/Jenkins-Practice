# Implement parallel stages in Jenkins pipeline.

```bash
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Parallel') {
            parallel {

                stage('Test') {
                    steps {
                        sh 'mvn test'
                    }
                }

                stage('Scan') {
                    steps {
                        echo "Scanning"
                    }
                }

            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

    }
}
```
