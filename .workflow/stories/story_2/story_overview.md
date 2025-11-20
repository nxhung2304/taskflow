Story 2: user-authentication-module Overview
Status: approved
From Story: Story 2: user-authentication-module
Acceptance Criteria:

- Use devise gem to authentication
- User can create account with email, password, and name
- User can log in with valid credentials and receive session management
- User can log out and have their session properly terminated
- Users are redirected to their personal dashboard after successful login

Tasks:

2.1: devise-gem-setup (0.5h, Dep: None)
2.2: user-model-migration (0.5h, Dep: 2.1)
2.3: authentication-views (1h, Dep: 2.2)
2.4: auth-routes-setup (0.5h, Dep: 2.3)
2.5: session-management (1h, Dep: 2.4)

Total Est. Time: 3.5h
