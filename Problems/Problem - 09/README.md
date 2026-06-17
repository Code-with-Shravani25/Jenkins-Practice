# Write a shell script inside Jenkins that checks disk usage and sends exit code based on threshold
---
- Job --> Build step --> Execute shell
```bash
#!/bin/bash
THRESHOLD=80

# Get disk usage percentage of root file system
USAGE=$(df -h/ | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Current Disk Usage: ${USAGE}%"

# Check threshold
if ["$USAGE" -ge "$THRESHOLD" ]; then
   echo "Disk usgae exceeded threshold of ${THRESHOLD}%"
   exit 1
else
   echo "Disk usage is under control"
   exit 0
fi
```
```text
- df -h/ : Current disk usage of root file
- awk 'NR==2 {print $5}' : Extract usgae %
- sed 's/%//' : Removes %
- Exit Code 0 : Success and Exit Code 1: Failure
```
