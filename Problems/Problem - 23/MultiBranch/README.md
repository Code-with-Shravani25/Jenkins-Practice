# Create multibranch pipeline in Jenkins.
- A Multibranch Pipeline in Jenkins automatically discovers branches in a Git repository and creates a separate pipeline for each branch. Each branch must contain its own Jenkinsfile.
## Advantages
- Automatically detects new branches.
- Automatically removes deleted branches.
- Each branch has its own build history.
- Ideal for Git workflows like feature branches, release branches, and hotfixes.
- No need to manually create a new Jenkins job for every branch.

