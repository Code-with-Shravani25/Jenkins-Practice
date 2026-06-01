# Create a parameterized Jenkins job with String parameter, Choice parameter and Boolean Paarmeter.
---
```bash
- Create freestyle job
```
Under General Select
```bash
This project is parameterized
```
Add string parameter
```bash
Name: Username
default value: Shravani
```
Add Choice parameter
```bash
Name: Environment
Choices: Dev
         Test
         Prod
```
Add Boolean Parameter
```bash
Name: Deploy
Default: Checked
```
Add Build Step -> Execute shell
```bash
echo "Username: $Username"
echo "Environment: $Environment"
echo "Deploy: $Deploy"
```
## Verify
- Build with parameters
- Select or give new values
- Verify the output in putput section of build
