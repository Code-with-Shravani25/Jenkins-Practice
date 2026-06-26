# Jenkins Architecture (Master-Agent Architecture)
---
Jenkins Controller (Master)
       |
  Agent 1 (linux)
       | 
  Agent 2 (Docker)

The controller schedules jobs, while agents execute them.

## Jenkins Controller (Master)
- The controller is the central server responsible for
  - Managing Jenkins UI
  - Scheduling jobs
  - Managing plugins
  - Storing build history
  - Managing credentials
  - Assigning jobs to agents
- It should ideally not execute builds itself in production environments.

## Jenkins Agents (Node)
- An agent is a machine that executes the actual build,test and deployment tasks.
- Examples: Linux agent, windows agent, docker agent, kubernetes pod agent
- The controller sends instructions to agents and agents return the results.

## Why do we use Jenkins Agent
- Agents are used to offload build and deployment work from Jenkins Controller (Master) and distribute workloads across multiple machines.
- Problems without machines:
  - High CPU and memory usage on the controller
  - Slow build execution
  - Controller becomes a single bottleneck
  - If controller is overloaded, Jenkins UI may become show or unresponsive
- With Agents:
  - Builds run in parallel
  - Better performance and scalability
  - Different environments can be used (Linux, Windows, Docker, etc)
  - Controller remains dedicated to managing Jenkins
 
## Communication Flow
- Step 1: Developer triggers a build.
- Step 2: Master checks available agents.
- Step 3: Master assigns the job.
- Step 4: Agent executes commands.
- Step 5: Results are sent back.
- Step 6: Master displays logs and build status.

## Types of Agents
1. Static Agents
- Always running and manually configured
- Eg: EC2 instance1 --> Jenkins Agent
- EC2 instance2 --> Linux agent

2. Dynamic Agents
- Created only when needed.
- After build finishes, the agent is destroyed.

## Labels in Jenkins
Labels help jenkins decide where to run a job.
