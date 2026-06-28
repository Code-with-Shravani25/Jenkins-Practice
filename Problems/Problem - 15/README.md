# Create a Jenkins pipeline that: Executes unit tests and Publishes test reports
## Without publishing test reports:
- Without publishing the test reports, we need to check the test results under build no's console log.
- In this we wont get new test tab
<img width="940" height="280" alt="image" src="https://github.com/user-attachments/assets/5bfc001c-5f02-434b-9b4e-78c2fe9d3e3a" />

## With Publishing Test Reports:
- We get a new tab under of tests when we click on build no (like #1) and y=under it we can see proper test reports success, failed and if failed which one is particularly failed. We get detailed information.
- <img width="940" height="379" alt="image" src="https://github.com/user-attachments/assets/b8e5ba8e-ebd9-4e30-97db-344c6af1377e" />

## Jekins Pipeline
```bash
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: '[https://github.com/your-username/your-repository.git](https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git)'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
    }

    post {

        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
```

The post block is important to publish the test reports
```bash
post {
    always {
        junit '**/target/surefire-reports/*.xml'
    }
}
```
- why surefire-reports is used: we need to check our target folder under which our test reports are usually stored and that location we need to pass to junit.
```bash
ls -R target
```
example
```bash
target/
├── classes
├── generated-sources
├── surefire-reports
│   ├── TEST-AppTest.xml
│   └── TEST-UserTest.xml
└── test-classes
```
