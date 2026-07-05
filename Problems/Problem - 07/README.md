# Configure jenkins build trigger
---
1. Poll SCM
2. GitHub Webhook
---
## 1. Poll SCM
---
- It means jenkins periodically checks the git repository for changes
- How it works:
  - Developer pushes code to Github
  - Jenkins waits for scheduled polling time.
  - Jenkins checks Github repo
  - If changes are found --> build starts.

- Configure Poll SCM Trigger
---
Configure job --> Poll SCM --> in schedule box add
```bash
H/5 * * * * # Checks every 5 mins
```
---
## 2. Github Webhook
---
- It is a event driven
- Instead of jenkins checking Github repeatedly, Github directly notifies Jenkins immediately when code changes happen.

## Configure Github webhook trigger
- In job --> Configure --> Github webhook trigger for GitScm polling
- Configure Github webhook
 - Open Github repo --> Settings --> Webhooks --> Add Webhook --> Payload URL (https://<jenkins-url>:8080/github-webhook) --> Content type: application/json --> Events --> Select accordingly like just the push event
- Note: Job name can be any but in payload url it should be github-webhook after jenkins url
---
## Verify: 
- By pusing the data into git repo
