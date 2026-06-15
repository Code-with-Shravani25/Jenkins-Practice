# Configure Jenkins workspace cleanup after every build
---
## Method 1: 
---
 - Configure job --> Add post build action --> Delete workspace when build is done --> Save
---
## Method 2:
---
- Install Plugon: Manage Jenkins--> Plugins --> Workspace Cleanup Plugin
- Configure Cleanup: Build Env --> Delete workspace before build starts/post build actions --> Clean workspace
