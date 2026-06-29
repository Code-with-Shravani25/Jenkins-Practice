# Jenkins Pipeline to Execute Ansible Playbooks

This project demonstrates how to configure Jenkins to execute Ansible playbooks on a remote EC2 instance.

---

## Architecture

```
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Jenkins Server
(Java + Jenkins + Ansible)
    │
    ▼
Ansible Playbook
    │
    ▼
Managed EC2 Instance
```

---

## Prerequisites

- AWS Account
- Two Ubuntu EC2 instances
- Security Group allowing SSH (22)

---

# Step 1: Launch Jenkins Server

Launch an Ubuntu EC2 instance.

Install:

- Java
- Jenkins
- Ansible
- Git

Verify the installations:

```bash
java -version
jenkins --version
ansible --version
git --version
```

---

# Step 2: Launch Managed EC2

Launch another Ubuntu EC2 instance.

Copy its **Private IP Address**.

Update the Ansible inventory file in your GitHub repository.

Example:

**inventory/inventory.ini**

```ini
[servers]
172.31.19.19 ansible_user=ubuntu
```

Commit and push the changes to GitHub.

---

# Step 3: Generate SSH Key for Jenkins User

Switch to the Jenkins user.

```bash
sudo su - jenkins
```

Generate an SSH key pair.

```bash
ssh-keygen
```

Press **Enter** for all prompts.

This creates:

```
/var/lib/jenkins/.ssh/id_rsa
/var/lib/jenkins/.ssh/id_rsa.pub
```

Display the public key.

```bash
cat ~/.ssh/id_rsa.pub
```

Copy the output.

---

# Step 4: Configure Passwordless SSH

Log in to the managed EC2 instance.

Append the copied public key to:

```bash
~/.ssh/authorized_keys
```

Example:

```bash
nano ~/.ssh/authorized_keys
```

Paste the public key and save.

Verify SSH connectivity from the Jenkins user.

```bash
sudo su - jenkins

ssh ubuntu@172.31.19.19
```

The login should complete without asking for a password.

---

# Step 5: Create Jenkins Pipeline

Create a new **Pipeline** job in Jenkins.

Use the following Pipeline script.

```groovy
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Code-with-Shravani25/Ansible-Practice.git'
            }
        }

        stage('Ansible') {
            steps {
                sh '''
                ansible-playbook \
                -i inventory/inventory.ini \
                Problems/Problem-11/Playbook.yml
                '''
            }
        }

    }
}
```

Save the pipeline and click **Build Now**.

---

# Repository Structure

```
Ansible-Practice
│
├── inventory
│   └── inventory.ini
│
├── Problems
│   ├── Problem-01
│   ├── Problem-02
│   ├── ...
│   └── Problem-11
│       └── Playbook.yml
│
└── README.md
```

---

# Workflow

```
GitHub
   │
   ▼
Jenkins clones repository
   │
   ▼
Ansible reads inventory.ini
   │
   ▼
SSH to Managed EC2
   │
   ▼
Execute Playbook
```

---

# Troubleshooting

### Host key verification failed

Accept the host key as the Jenkins user.

```bash
sudo su - jenkins

ssh ubuntu@<private-ip>
```

Type:

```
yes
```

---

### Permission denied (publickey)

Ensure the Jenkins user's public key has been added to the managed EC2's `authorized_keys` file.

---

### Test Ansible Connectivity

```bash
ansible all -i inventory/inventory.ini -m ping
```

Expected output:

```
SUCCESS
```

---

# Result

After a successful build, Jenkins will:

- Clone the GitHub repository
- Read the Ansible inventory
- Connect to the managed EC2 using SSH
- Execute the specified Ansible playbook
- Display the execution results in the Jenkins console output
