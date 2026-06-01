# Install Jenkins on linux and change the default port
---
## Install Java
```bash
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version
```
---
## Install Jenkins
- You can copy these commands from jenkins document on browser
```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
```
---
## Default Port
```bash
http://<public_ip>:8080
```
---
## Change Default port
- To chnage the default port we need to change the jenkins configuration file and the systemd service file.
- Jenkins Configuration file location
```bash
sudo vi /etc/default/jenkins
```
- Here search for HTTP_Port=8808 and change to the desired port
- Jenkins system.service file location
```bash
sudo vi /lib/systemd/system/jenkins.service
```
- Here search for line Environment="JENKINS_PORT=8080" and change to desired port.
- Once changed restart the service

 ## Restart the service
 ```bash
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

## Verify
```bash
http://<public_ip>:<new_port>
```
