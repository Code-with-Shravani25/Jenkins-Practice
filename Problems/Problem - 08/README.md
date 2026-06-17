# Create and Manage: Jenkins Users,Roles and Project based permissions
---
## Create Jenkins Users
- Manage Jenkins --> Users --> Create User --> Provide Username,password,full name and email.
- Verify: Sign out and sign in again by new user
---
## Role Based Authorization
---
- Install plugin --> Role based Authorization Strategy
- Enable Role based Authorization: Manage Jenkins --> Security --> Under Authorization select Role based Strategy
- Create Roles in Jenkins: Manage Jenkins --> Manage and Assign Roles --> Manage Roles
- Create Role: Role name (Developer, Tester)
- Assign Roles to users: Manage Jenkins --> Manage and Assign Roles --> Assign Roles
- Verify: Logging as different users
