# Jenkins Credentials and Secrets Security

## Objective

Securely manage credentials and secrets in Jenkins by following industry best practices. Never hardcode sensitive information in source code or pipeline scripts.

---

# Best Practices

## 1. Use Jenkins Credentials Store

Store all sensitive information in **Manage Jenkins → Credentials** instead of hardcoding them.

Supported credential types:

- Username with Password
- SSH Username with Private Key
- Secret Text (API Tokens)
- Secret File
- Certificates

**Do Not Store Secrets In:**

- Jenkinsfile
- GitHub Repository
- Shell Scripts
- Terraform Files
- Ansible Playbooks

---

## 2. Use Credential IDs

Reference credentials using their ID instead of exposing actual values.

### Example

```groovy
pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-creds',
                    url: 'https://github.com/user/repository.git'
            }
        }
    }
}
```

---

## 3. Inject Secrets Using `withCredentials`

Secrets should only be available during the required stage.

### Example

```groovy
pipeline {
    agent any

    stages {
        stage('Use API Token') {
            steps {
                withCredentials([
                    string(credentialsId: 'api-token', variable: 'TOKEN')
                ]) {
                    sh '''
                    curl -H "Authorization: Bearer $TOKEN" https://example.com
                    '''
                }
            }
        }
    }
}
```

Benefits:

- Secret exists only inside the block.
- Automatically removed after execution.
- Masked in Jenkins console logs.

---

## 4. Implement Role-Based Access Control (RBAC)

Grant permissions based on job responsibilities.

Example:

| Role | Permissions |
|------|-------------|
| Developer | Build Jobs |
| QA | View Jobs |
| DevOps Engineer | Manage Pipelines |
| Jenkins Administrator | Manage Credentials & System |

Follow the **Principle of Least Privilege**.

---

## 5. Use Folder-Level Credentials

Instead of storing all credentials globally, assign credentials to folders.

Example:

```
Jenkins
│
├── Team-A
│     └── AWS Credentials
│
├── Team-B
│     └── Docker Credentials
│
└── Team-C
      └── GitHub Token
```

Benefits:

- Better isolation
- Improved security
- Easier management

---

## 6. Prefer SSH Keys Over Passwords

Instead of:

```
Username
Password
```

Use:

```
SSH Private Key
```

Advantages:

- More secure
- Easier key rotation
- Commonly used with GitHub and Linux servers

---

## 7. Rotate Credentials Regularly

Regularly rotate:

- AWS Access Keys
- GitHub Personal Access Tokens
- Database Passwords
- SSH Keys
- API Tokens

Remove unused credentials immediately.

---

## 8. Never Print Secrets in Console Logs

Avoid commands like:

```bash
echo $PASSWORD
```

or

```bash
printenv
```

Although Jenkins masks known secrets, avoid printing them entirely.

---

## 9. Integrate with Secret Management Solutions

Instead of storing secrets permanently in Jenkins, retrieve them at runtime from secure secret managers.

Examples:

- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- HashiCorp Vault
- Azure Key Vault
- Google Secret Manager

Benefits:

- Centralized secret management
- Automatic rotation
- Better auditing

---

## 10. Use IAM Roles Instead of AWS Access Keys

If Jenkins runs on an AWS EC2 instance:

❌ Avoid storing:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

✅ Attach an IAM Role to the EC2 instance.

Benefits:

- Temporary credentials
- Improved security
- No static AWS keys

---

## 11. Encrypt Credentials

Jenkins encrypts stored credentials.

Additionally:

- Protect the Jenkins home directory.
- Restrict filesystem access.
- Secure backups.
- Limit administrator access.

---

## 12. Secure Jenkins Communication

Always:

- Enable HTTPS
- Disable unsecured HTTP access
- Secure Jenkins agents (SSH or inbound agents)
- Keep Jenkins updated
- Update plugins regularly

---

# Security Checklist

| Best Practice | Status |
|--------------|--------|
| Store credentials in Jenkins Credentials Store | ✅ |
| Never hardcode secrets | ✅ |
| Use Credential IDs | ✅ |
| Use `withCredentials` | ✅ |
| Enable RBAC | ✅ |
| Use Folder-Level Credentials | ✅ |
| Prefer SSH Keys | ✅ |
| Rotate Credentials | ✅ |
| Never Print Secrets | ✅ |
| Use Secret Managers | ✅ |
| Use IAM Roles on AWS | ✅ |
| Encrypt Credentials | ✅ |
| Enable HTTPS | ✅ |
| Keep Jenkins Updated | ✅ |

---

# Interview Answer

**How would you secure Jenkins credentials and secrets?**

> I never hardcode secrets in Jenkins pipelines or source code. Instead, I store them in the Jenkins Credentials Store and reference them using credential IDs. I use the `withCredentials` block to inject secrets only when required, ensuring they are masked in the console logs. I implement role-based access control so only authorized users can manage credentials and use folder-level credentials for team isolation. In AWS environments, I prefer IAM roles over static access keys. For production environments, I integrate Jenkins with secret management solutions such as AWS Secrets Manager or HashiCorp Vault, rotate credentials regularly, secure Jenkins with HTTPS, encrypt stored credentials, and keep Jenkins and its plugins up to date.

---

# Conclusion

Following these best practices ensures that Jenkins credentials remain secure, minimizes the risk of credential leakage, and aligns with enterprise DevSecOps standards.
