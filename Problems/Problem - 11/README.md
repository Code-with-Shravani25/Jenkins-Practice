# Configure a Jenkins job to: Clone a private Git Repo using SSH Key Authentication
---
- Generate SSH Key on Jenkins server:
```bash
sudo su - jenkins  # Switch to jenkins user, because jenkins jobs run under jenkins user account and not under personal account like ec2-user,ubuntu
                   # Jenkins cannot automatically use that key (/home/ubuntu//ssh) because jobs run as jenkins user and it looks in its own home directory
ssh-keygen
```
- Add public key to Github:
  - Github account --> Settings --> SSH and GPG keys --> Add Key and Copy paste public key
- Test SSH Connectivity on jenkins server
```bash
ssh -T git@github.com
```
- Add SSH key to Jenkins Credentials
 - Maange Jenkins --> Credentials --> System --> Add Credentials --> Choose Kind: SSH username with private key --> fill details: ID: git-user, username: git and enter private key and save
- Get SSH repo url
  - Repo --> Code (where we copy repo url) --> Switch to SSH tab --> Copy URL
- Jenkins job --> Git --> Paste repo url --> Save
- Verify: /var/lib/jenkins/workspace/<jobname> //Check clone
  
