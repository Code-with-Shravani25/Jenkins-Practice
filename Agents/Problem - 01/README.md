# Configure Jenkins master-agent architecture.
---
## Method 1: Using agents pem file
1. Launch an EC2, install java and jenkins and configure jenkins by logging in UI
2. Launch another EC2, that is our agent EC2 and just install java and create one working directory (/home/ubuntu/jenkins_working_directory)
3. Go to Jenkins UI --> Manage Jenkins --> Credentials --> SSH with username and private key --> Add username (ubuntu) and add private key(the key pair used for agent EC2 to launch, copy that key pairs pem contents and add it --> Save
4. Go to Manage Jenkins --> Nodes --> Add node/new node --> Permanent Agent --> Remote root directory (add agents working directory: /home/ubuntu/jenkins_working_directory) --> labels (add label as we need to use this in our pipelines for running the pipelines on this agent) --> Usgae(Use this node as much as possible) --> Launch Method (Launch agents via SSH) --> On this a new section pops up -->Host (private ip of agent EC2) --> Credentials (select the credentials that we created) --> Host Key verification strategy (Non verifying verification strategy) and save.
5. Now check the agent is online if not go to Manage Jenkins --> Nodes --> Select node and click on Launch Agent
6. Now try to run a pipeline and check on which node its running and check the working directory for the pipeline that is run.

## Method 2: By SSH
1. On Jenkins EC2 do ssh-keygen copy public key and paste it in agents EC2's authorized keys.
2. Manage Jenkins --> Credentials --> Add Credential --> SSH with username and private key --> Add username (ubuntu) and add private key(Copy paste private SSH key that we generated on jenkins ec2)--> Save.
3. Go to Manage Jenkins --> Nodes --> Add node/new node --> Permanent Agent --> Remote root directory (add agents working directory: /home/ubuntu/jenkins_working_directory) --> labels (add label as we need to use this in our pipelines for running the pipelines on this agent) --> Usgae(Use this node as much as possible) --> Launch Method (Launch agents via SSH) --> On this a new section pops up -->Host (private ip of agent EC2) --> Credentials (select the credentials that we created) --> Host Key verification strategy (Non verifying verification strategy) and save.
4. Verify by running a job.
 
