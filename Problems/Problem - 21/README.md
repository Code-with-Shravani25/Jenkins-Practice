# Configure Jenkins with: Maven, JDK and Git tools globally

## Objective

Configure the following tools globally in Jenkins so they can be used by Freestyle and Pipeline jobs.

- Java (JDK)
- Maven
- Git

---

## Prerequisites

- EC2/Linux server
- Java installed
- Jenkins installed
- Maven installed
- Git installed

Verify installations:

```bash
java -version
mvn -version
git --version
```

Example output:

```bash
openjdk version "17.x.x"

Apache Maven 3.9.x

git version 2.x.x
```

---

# Step 1: Find Installation Paths

## JDK Path

```bash
readlink -f $(which java)
```

Example:

```bash
/usr/lib/jvm/java-17-openjdk-amd64/bin/java
```

JDK Home:

```text
/usr/lib/jvm/java-17-openjdk-amd64
```

---

## Maven Path

```bash
which mvn
```

Example:

```bash
/usr/bin/mvn
```

Find Maven home:

```bash
readlink -f $(which mvn)
```

Example:

```bash
/opt/apache-maven-3.9.6/bin/mvn
```

Maven Home:

```text
/opt/apache-maven-3.9.6
```

---

## Git Path

```bash
which git
```

Example:

```bash
/usr/bin/git
```

---

# Step 2: Open Global Tool Configuration

Go to:

```
Dashboard
   ↓
Manage Jenkins
   ↓
Tools
```

---

# Step 3: Configure JDK

Click **Add JDK**

Configure:

```
Name:
JDK17

JAVA_HOME:
/usr/lib/jvm/java-17-openjdk-amd64
```

Uncheck:

```
Install automatically
```

Save.

---

# Step 4: Configure Maven

Click **Add Maven**

Configure:

```
Name:
Maven3

MAVEN_HOME:
/opt/apache-maven-3.9.6
```

Uncheck:

```
Install automatically
```

Save.

---

# Step 5: Configure Git

Locate **Git Installations**

Configure:

```
Name:
Default

Path to Git:
/usr/bin/git
```

Save.

---

# Step 6: Verify Configuration

Create a Pipeline job.

Example:

```groovy
pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    stages {

        stage('Verify Tools') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
                sh 'git --version'
            }
        }

    }
}
```

---

## Expected Output

```
Java Version:
openjdk 17

Maven Version:
Apache Maven 3.x

Git Version:
git version 2.x
```
