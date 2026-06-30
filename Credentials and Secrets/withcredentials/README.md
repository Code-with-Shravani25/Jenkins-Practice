# Jenkins `withCredentials`

## What is `withCredentials`?

`withCredentials` is a Jenkins Pipeline step used to **temporarily inject credentials into your pipeline**. The credentials are available **only inside the `withCredentials` block**, making it one of the most secure ways to use secrets.

---

# Syntax

```groovy
withCredentials([credential_type]) {
    // Use credentials here
}
```

---

# Why use `withCredentials`?

Suppose you need to:

- Connect to a database
- Clone a private GitHub repository
- Login to Docker Hub
- Access AWS
- Call an API

Instead of hardcoding usernames, passwords, or tokens, you store them in the **Jenkins Credentials Store** and access them securely using `withCredentials`.

---

# Example 1: Secret Text Credential

## Credential in Jenkins

| Property | Value |
|----------|-------|
| Type | Secret text |
| ID | `api-key` |

### Pipeline

```groovy
pipeline {
    agent any

    stages {
        stage('API Call') {
            steps {
                withCredentials([
                    string(credentialsId: 'api-key', variable: 'API_KEY')
                ]) {
                    sh '''
                        echo "Calling API..."
                        curl -H "Authorization: Bearer $API_KEY" https://example.com
                    '''
                }
            }
        }
    }
}
```

### Inside the block

```bash
$API_KEY
```

Contains the secret value.

### Outside the block

```bash
$API_KEY
```

Does **not** exist because Jenkins removes it after exiting the `withCredentials` block.

---

# Example 2: Username and Password Credential

## Credential in Jenkins

| Property | Value |
|----------|-------|
| Type | Username with password |
| ID | `db-creds` |

### Pipeline

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'db-creds',
        usernameVariable: 'DB_USER',
        passwordVariable: 'DB_PASS'
    )
]) {
    sh '''
        mysql -u $DB_USER -p$DB_PASS
    '''
}
```

### Available Variables

```bash
DB_USER
DB_PASS
```

- `DB_USER` → Stores the username.
- `DB_PASS` → Stores the password.

---

# Example 3: SSH Private Key Credential

```groovy
withCredentials([
    sshUserPrivateKey(
        credentialsId: 'server-key',
        keyFileVariable: 'SSH_KEY',
        usernameVariable: 'SSH_USER'
    )
]) {
    sh '''
        ssh -i $SSH_KEY $SSH_USER@10.0.0.10 hostname
    '''
}
```

### Available Variables

| Variable | Description |
|----------|-------------|
| `SSH_KEY` | Path to the temporary private key file |
| `SSH_USER` | SSH username |

---

# How `withCredentials` Works

```
Pipeline starts
      │
      ▼
No credentials available
      │
      ▼
Enter withCredentials block
      │
      ▼
Jenkins fetches credentials
from the Credentials Store
      │
      ▼
Creates temporary
environment variables
      │
      ▼
Pipeline uses the credentials
      │
      ▼
Exit withCredentials block
      │
      ▼
Temporary variables are removed
automatically
```

---

# `environment` vs `withCredentials`

| `environment { credentials(...) }` | `withCredentials` |
|------------------------------------|-------------------|
| Credentials are available throughout the pipeline or stage. | Credentials are available only inside the block. |
| Easier for credentials used in multiple stages. | Best when credentials are required only for a specific step. |
| Larger scope means secrets exist longer. | Smaller scope improves security. |
| Simpler syntax. | More secure and flexible. |

---

# Best Practices

- Store all sensitive information in the **Jenkins Credentials Store**.
- Never hardcode usernames, passwords, API keys, or tokens in your Jenkinsfile.
- Use `withCredentials` whenever credentials are required only for a specific stage or command.
- Avoid printing secrets in the Jenkins console output.
- Rotate credentials periodically for improved security.
- Use meaningful credential IDs such as:
  - `github-token`
  - `dockerhub-creds`
  - `aws-access-key`
  - `db-creds`

---

# Summary

- `withCredentials` securely injects credentials into a pipeline.
- Credentials are available **only inside the block**.
- Jenkins automatically removes the temporary variables after the block completes.
- Supports multiple credential types, including:
  - Secret Text
  - Username & Password
  - SSH Private Key
  - Secret File
  - Certificate
- Preferred over global environment variables when credentials are needed only for specific steps because it provides a smaller, more secure scope.
