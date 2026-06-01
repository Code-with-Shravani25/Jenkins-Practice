# Create a freestyle job that: pulls code from Github, executes shell commands and archieve artifacts
---
```bash
- Create new job
- Name of job
- Select freestyle job
```
Under Source Code Management
```bash
- Select Git
- Add Git Repo Url
- Branch
```
Buld Steps
```bash
- Add build steps
- Execute shell
- Add commands
```
Example commands
```bash
echo "Build started"
mkdir output
echo "Hello from Jenkins" > output/result.txt
echo "Build completed"
```
Post Build Actions
```bash
- Archive Artifacts
```
Enter
```bash
output/*.txt
```
This will store the generated files after build.

## Verify
```bash
- Run a job
- Check the output and the cloned git repo at
```
```bash
/var/lib/jenkins/workspace/<job-name>/output
```
   

