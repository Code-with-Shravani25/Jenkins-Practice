# Configure email notification for build success and failure
---
- Install Email Extension Plugin
- Configure SMTP server:
  - Manage Jenkins --> System --> Find section (Extended Email Notification), SMTP server: smtp.gmail.com, smtp port: 465 for SSL and 587 for TLS, Advanced --> Credentials add username: email and password: App password, Check the use SSL checkbox
  - Under Email Notification Section : SMTP server: smtp.gmail.com, advanced:Check the Use SMTP Authentication Checkbox, username: email and password: App password, Check the Use SSL checkbox
  - Text Configuration
- Verify: Job --> Configure --> Post Build Action --> Email Notification
