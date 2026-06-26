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

## Dynamic Agents
# Jenkins Dynamic Agents

## What are Dynamic Agents?

A **dynamic agent** is a temporary machine or container that Jenkins creates **only when a build needs it**. After the build finishes, Jenkins automatically destroys the agent.

Unlike **static agents**, you don't have to keep machines running all the time, making dynamic agents more scalable and cost-effective.

---

# Why Dynamic Agents?

Imagine your company has **100 developers**, and every developer pushes code multiple times a day.

If you use **static agents**:

- You need many servers running **24×7**.
- Some servers remain idle most of the day.
- Infrastructure costs increase.
- Manual maintenance becomes difficult.

Dynamic agents solve this problem by creating build environments **on demand**.

---

# Static vs Dynamic Agents

## Static Agent

```text
Jenkins Controller
        |
        |
Linux Agent (Always ON)
        |
        |
Runs Build
        |
Still Running
```

- Agent exists before the build.
- Remains available after the build.
- Resources are consumed even when idle.

---

## Dynamic Agent

```text
Build Starts
      |
      |
Create Agent
      |
      |
Run Build
      |
      |
Destroy Agent
```

- Agent is created only when required.
- Destroyed immediately after the build.
- No build → No agent.

---

# How Dynamic Agents Work

The provisioning workflow is the same whether you're using Docker, Kubernetes, or cloud virtual machines.

```text
Developer Pushes Code
        |
        ▼
Jenkins Detects Build
        |
        ▼
Jenkins Requests an Agent
        |
        ▼
Agent is Created Automatically
        |
        ▼
Checkout Source Code
        |
        ▼
Build / Test / Deploy
        |
        ▼
Results Sent to Jenkins
        |
        ▼
Agent Destroyed
```

Every build gets a **fresh and isolated environment**.

---

# Types of Dynamic Agents

## 1. Docker Dynamic Agents (Best for Beginners)

Jenkins creates a Docker container whenever a pipeline starts.

### Workflow

```text
Jenkins
   |
   ▼
docker run maven:3.9
   |
   ▼
Container Created
   |
   ▼
Run Maven Build
   |
   ▼
Container Deleted
```

### Container Lifecycle

```text
Container Created
        |
        ▼
Build
        |
        ▼
Tests
        |
        ▼
Package
        |
        ▼
Container Removed
```

Since the container is removed after the build, **no leftover files remain**.

---

## 2. Kubernetes Dynamic Agents (Production Standard)

Instead of creating containers directly, Jenkins requests Kubernetes to create a Pod.

### Workflow

```text
Jenkins
   |
   ▼
Kubernetes Plugin
   |
   ▼
Create Pod
   |
   ▼
Run Build
   |
   ▼
Delete Pod
```

### Example Pod

```text
Pod
--------------------------------
| Maven Container              |
| Git Container                |
| Docker Container             |
--------------------------------
```

After the build:

```text
Pod Deleted
```

Each pipeline receives its own temporary Kubernetes Pod.

---

## 3. Cloud VM Dynamic Agents

Cloud providers can provision complete virtual machines whenever Jenkins requires them.

Example:

```text
Jenkins
   |
   ▼
AWS EC2 Plugin
   |
   ▼
Launch EC2 Instance
   |
   ▼
Run Build
   |
   ▼
Terminate EC2 Instance
```

These are useful for:

- Large builds
- High-memory workloads
- Specialized operating systems
- GPU workloads

---

# Advantages of Dynamic Agents

- **Automatic Provisioning**
  - Agents are created only when needed.

- **Clean Build Environment**
  - Every build starts in a fresh environment.
  - No leftover artifacts from previous builds.

- **Scalability**
  - Multiple agents can be created simultaneously.
  - Supports parallel pipeline execution.

- **Resource Efficiency**
  - No idle servers consuming CPU or memory.

- **Isolation**
  - Builds do not interfere with one another.

- **Lower Infrastructure Cost**
  - Resources are consumed only during builds.

- **Easy Environment Management**
  - Different projects can use different build images.

---

# Static vs Dynamic Agents Comparison

| Feature | Static Agent | Dynamic Agent |
|----------|--------------|---------------|
| Creation | Manual | Automatic |
| Lifetime | Permanent | Temporary |
| Resource Usage | Always running | Only during builds |
| Cost | Higher | Lower |
| Scalability | Manual | Automatic |
| Maintenance | Manual | Minimal |
| Build Environment | Persistent | Fresh every build |
| Best For | Small teams, Learning | Production, Cloud, CI/CD |

---

# Real-World Example

Suppose an organization has four different projects:

| Project | Technology |
|----------|------------|
| User Service | Java + Maven |
| Payment Service | Java + Gradle |
| Frontend | Node.js |
| Recommendation Engine | Python |

Using dynamic agents:

```text
Frontend Build
        |
        ▼
Node.js Container

Payment Build
        |
        ▼
Gradle Container

Recommendation Build
        |
        ▼
Python Container
```

Each project receives its own isolated environment with only the required tools installed.

---

# Summary

Dynamic agents allow Jenkins to provision build environments **only when required**, execute the pipeline, and automatically remove the environment after completion.

This approach provides:

- Cost optimization
- Better scalability
- Faster parallel builds
- Clean and isolated execution environments
- Simplified infrastructure management

Dynamic agents are the preferred choice for **modern CI/CD pipelines** and are commonly implemented using **Docker**, **Kubernetes**, or **cloud virtual machines**.

