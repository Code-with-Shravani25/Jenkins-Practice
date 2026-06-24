# Write a Jenkins pipeline with: try-catch error handling
```bash
pipeline {
    agent any

    environment {
        APP_NAME = "MyApp"
    }

    stages {

        stage('Build') {
            steps {
                script {
                    try {
                        echo "Building ${APP_NAME}..."
                        sh 'mvn clean package'
                    }
                    catch(Exception e) {
                        echo "Build failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    try {
                        echo "Running tests..."
                        sh 'mvn test'
                    }
                    catch(Exception e) {
                        echo "Test failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    try {
                        echo "Deploying application..."
                        sh './deploy.sh'
                    }
                    catch(Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully."
        }
        failure {
            echo "Pipeline execution failed."
        }
        always {
            echo "Pipeline completed."
        }
    }
}
```

## Step 1: What does try do?

- The code inside try is the code Jenkins attempts to execute.

## Step 2: When does catch execute?

- Suppose Maven build fails: mvn clean package
- The sh step returns a non-zero exit code.
- Jenkins automatically throws an exception.
- Control immediately jumps to: catch(Exception e)

## Step 3: What is Exception e?

- Think of an Exception as an error object.
- It means: "If any exception occurs, store it in variable e."

## Step 4: What is inside e?

- e contains information about the failure.

## Step 5: What does this line do?

- currentBuild.result = 'FAILURE'
- It explicitly marks the Jenkins build as failed.
- Without this line, Jenkins may still fail because of throw e, but many teams use it to clearly set the build status.

## Step 6: What does throw e mean?

- This is the most important part.
- throw e means "Re-throw the same exception again."
- Without throw e: The pipeline continues.
- With throw e: Pipeline stops immediately
  
