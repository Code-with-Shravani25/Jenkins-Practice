# Create upstream downstream jenkins job
---
## Step 1: Create Upstream Job
---
Freestyle job --> Job name --> Add build step --> Execute shell --> echo "Executing upstream job" or echo "$JOB_NAME"
---
## Step 2: Create Downstream Job
---
Freestyle job --> Job name --> Add build step --> Execute shell --> echo "Executing downstream job" or echo "$JOB_NAME"
---
## Step 3: Configure Upstream Job
---
Post build action --> Build other projects --> Enter downstream job name --> Save
---
## Verify
---
Trigger upstream, it will also trigger downstream job automatically.
---
