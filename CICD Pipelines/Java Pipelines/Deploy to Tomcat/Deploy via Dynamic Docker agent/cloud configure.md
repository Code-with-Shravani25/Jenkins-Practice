# Configure Docker Cloud in Jenkins

---
$## Docker Host URI 

(URI is Uniform Resource Identifier)
```bash
unix:///var/run/docker.sock
```
Here uri is unix:// this is a scheme or protocol that tells jenkins to communicate over a unix socket connection
/var/run/docker.sock this is docker unix socket path
Connect to the Docker daemon through the Unix socket located at /var/run/docker.sock
---

## USER as root

If the container runs as a normal user, that user may not have permission to:

Install packages
Write to certain directories
Access mounted volumes
Execute Docker commands
Modify files required by the build

Running as root gives the container administrator-level permissions inside that container.

---

## Mounts

```bash
type: bind, source=/var/run/docker.sock, target=/var/run/docker.sock
```

My dynamic agent container wants to talk to Docker installed on my Jenkins controller/EC2 host, so we bind the EC2 host's Docker socket path to the container's Docker socket path

---
## Remote File System Root

```bash
Remote File System Root:
/home/jenkins/agent
```
It is simply the directory inside the dynamic agent container where Jenkins will keep the workspace and execute your pipeline.
we need this because for example whne we are doing git clone then the source code needs a location inside the temporary agent.
Jenkins uses the Remote File System Root as the base directory.
