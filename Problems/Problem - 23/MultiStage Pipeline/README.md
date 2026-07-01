# Create a scripted pipeline for: Multi-stage deployment

There are two types of Jenkins pipelines:

✅ Scripted Pipeline → Uses node {}
✅ Declarative Pipeline → Uses pipeline {}
✅ A node represents a Jenkins agent (executor) where the pipeline or part of the pipeline will execute.
✅ node {} means run on any available node (or the built-in controller if no other agents are configured).
✅ node('linux') {} means run on the agent that has the label linux

```bash
node{
    stage('Clone'){
        git branch: 'main', url: 'https://github.com/Code-with-Shravani25/Java-maven-code-with-test-cases.git'
    }
    stage('Build'){
        sh 'mvn clean compile'
    }
     stage('Test'){
        sh 'mvn test'
    }
     stage('Package'){
        sh 'mvn package'
    }
    stage('Deploy'){
        echo 'Deployed'
    }
}
```
