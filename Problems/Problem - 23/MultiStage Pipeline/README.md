# Create a scripted pipeline for: Multi-stage deployment

There are two types of Jenkins pipelines:

✅ Scripted Pipeline → Uses node {}
✅ Declarative Pipeline → Uses pipeline {}
✅ A node represents a Jenkins agent (executor) where the pipeline or part of the pipeline will execute.
✅ node {} means run on any available node (or the built-in controller if no other agents are configured).
✅ node('linux') {} means run on the agent that has the label linux

```bash
node {

    stage('Checkout') {
        echo "Cloning source code..."
        git branch: 'main', url: 'https://github.com/your-username/your-repository.git'
    }

    stage('Build') {
        echo "Building application..."
        sh 'mvn clean package'
    }

    stage('Unit Test') {
        echo "Running unit tests..."
        sh 'mvn test'
    }

    stage('Deploy to Dev') {
        echo "Deploying to Development environment..."
        sh './deploy-dev.sh'
    }

    stage('Deploy to QA') {
        echo "Deploying to QA environment..."
        sh './deploy-qa.sh'
    }

    stage('Approval for UAT') {
        input message: 'Deploy to UAT?', ok: 'Proceed'
    }

    stage('Deploy to UAT') {
        echo "Deploying to UAT environment..."
        sh './deploy-uat.sh'
    }

    stage('Approval for Production') {
        input message: 'Deploy to Production?', ok: 'Deploy'
    }

    stage('Deploy to Production') {
        echo "Deploying to Production environment..."
        sh './deploy-prod.sh'
    }

    stage('Success') {
        echo "Application successfully deployed to all environments."
    }
}
```
