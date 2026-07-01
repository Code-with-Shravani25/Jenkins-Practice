# Jenkins Blue-Green Deployment Pipeline

## Objective

Implement a Blue-Green deployment strategy using Jenkins to achieve near-zero downtime deployments and quick rollback in case of failures.

---

# What is Blue-Green Deployment?

Blue-Green Deployment is a release strategy where two identical production environments are maintained.

- **Blue Environment** – Currently serving live user traffic.
- **Green Environment** – Idle environment where the new application version is deployed and tested.

Only one environment receives production traffic at a time.

---

## Architecture

### Initial State

```text
                 Users
                   │
                   ▼
             Load Balancer
                   │
             ┌─────┴─────┐
             │           │
        Blue Server   Green Server
        Version 1         Idle
      ✅ Live Traffic
```

The Blue environment is currently serving all users.

---

### Deploy New Version

The new application version is deployed to the Green environment while users continue accessing the Blue environment.

```text
                 Users
                   │
                   ▼
             Load Balancer
                   │
             ┌─────┴─────┐
             │           │
        Blue Server   Green Server
        Version 1      Version 2
      ✅ Live Traffic   🚀 Testing
```

---

### Switch Traffic

Once the Green environment passes all tests, the Load Balancer redirects user traffic to Green.

```text
                 Users
                   │
                   ▼
             Load Balancer
                   │
             ┌─────┴─────┐
             │           │
        Blue Server   Green Server
        Version 1      Version 2
          Idle       ✅ Live Traffic
```

---

### Rollback

If any issue is detected after deployment, simply redirect traffic back to the Blue environment.

```text
                 Users
                   │
                   ▼
             Load Balancer
                   │
             ┌─────┴─────┐
             │           │
        Blue Server   Green Server
      ✅ Live Again      Failed
```

Rollback is quick because the Blue environment remains unchanged.

---

# Prerequisites

- Jenkins installed
- Java installed
- Build tool (Maven/Gradle)
- Git installed
- Two application servers (Blue and Green)
- Load Balancer (e.g., AWS Application Load Balancer or NGINX)
- SSH access from Jenkins to deployment servers
- AWS CLI (if deploying on AWS)

---

# Deployment Workflow

1. Developer pushes code to GitHub.
2. Jenkins clones the repository.
3. Jenkins builds the application.
4. Jenkins runs automated tests.
5. Jenkins deploys the application to the Green environment.
6. Jenkins performs health checks on Green.
7. (Optional) Manual approval before production switch.
8. Jenkins updates the Load Balancer to route traffic to Green.
9. Green becomes the live environment.
10. Blue remains available for rollback if needed.

---

# Sample Jenkins Pipeline

```groovy
pipeline {
    agent any

    environment {
        BLUE_SERVER = "172.31.1.10"
        GREEN_SERVER = "172.31.2.15"
    }

    stages {

        stage('Clone') {
            steps {
                echo "Cloning repository..."
            }
        }

        stage('Build') {
            steps {
                echo "Building application..."
            }
        }

        stage('Test') {
            steps {
                echo "Running tests..."
            }
        }

        stage('Deploy to Green') {
            steps {
                echo "Deploying application to Green server..."
            }
        }

        stage('Health Check') {
            steps {
                echo "Running health checks..."
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Switch production traffic to Green?'
            }
        }

        stage('Switch Traffic') {
            steps {
                echo "Updating Load Balancer..."
            }
        }

        stage('Verification') {
            steps {
                echo "Verifying deployment..."
            }
        }
    }

    post {

        success {
            echo "Blue-Green deployment completed successfully."
        }

        failure {
            echo "Deployment failed. Production traffic remains on Blue."
        }

    }
}
```

---

# Real Deployment Commands

## Clone Repository

```bash
git clone https://github.com/your-repository.git
```

---

## Build Application

```bash
mvn clean package
```

---

## Deploy to Green Server

```bash
scp target/app.jar ec2-user@GREEN_SERVER:/opt/app/

ssh ec2-user@GREEN_SERVER

sudo systemctl restart application
```

---

## Health Check

```bash
curl http://GREEN_SERVER:8080/actuator/health
```

Expected response:

```json
{
  "status": "UP"
}
```

---

## Switch Load Balancer (AWS Example)

Update the Application Load Balancer (ALB) to direct traffic to the Green target group using the AWS CLI.

Example:

```bash
aws elbv2 modify-listener ...
```

---

# Rollback Procedure

If the Green deployment fails:

1. Stop routing traffic to Green.
2. Redirect the Load Balancer back to Blue.
3. Investigate and fix the issue.
4. Redeploy a corrected version to Green.

Since the Blue environment was never modified, rollback is immediate.

---

# Advantages

- Near-zero downtime deployments
- Fast and reliable rollback
- Safer production releases
- Ability to validate the new version before exposing it to users
- Improved deployment confidence

---

# Limitations

- Requires duplicate infrastructure
- Higher infrastructure cost
- Database changes require careful planning
- More complex deployment and load balancer management

---

# Interview Flow

If asked how Blue-Green deployment works with Jenkins:

1. Push code to GitHub.
2. Jenkins clones the repository.
3. Build and test the application.
4. Deploy the new version to the idle Green environment.
5. Perform health checks and validation.
6. Obtain manual approval (optional).
7. Update the Load Balancer to send production traffic to Green.
8. Monitor the deployment.
9. If issues occur, switch traffic back to Blue for an immediate rollback.

---

# Summary

- Maintains two identical production environments: Blue and Green.
- Only one environment serves live traffic at a time.
- New releases are deployed to the idle environment.
- Health checks validate the deployment before traffic is switched.
- Rollback is achieved by redirecting traffic back to the previous environment.
- Jenkins automates the entire deployment workflow, reducing downtime and deployment risk.
