### Phase 1: Foundation & Auth (Completed)

**Basic Setup**
- [x] Rails API structure with versioning `/api/v1`
- [x] Devise + JWT authentication
- [x] User model with role-based access

**Core Models**
- [x] Create models: Board, List, Task, Comment
- [x] Setup associations and validations
- [x] Database migrations with UUID
- [x] Seed data for development

**Authorization**
- [x] Setup CanCanCan policies

---

### Phase 2: API

- [x] **Board API** - [#85](https://github.com/nxhung2304/taskflow/issues/85)
  - Full CRUD `/api/v1/boards` with authorization
  - Tools: Controller, Blueprinter serializer, CanCanCan integration

- [x] **List API** - [#86](https://github.com/nxhung2304/taskflow/issues/86)
  - Position ordering with `acts_as_list`
  - Route: Nested `/api/v1/boards/:board_id/lists`

- [x] **Task API** - [#88](https://github.com/nxhung2304/taskflow/issues/88)
  - Status management, assignee, deadline filtering
  - Route: Nested `/api/v1/lists/:list_id/tasks`

- [x] **Comment API** - [#87](https://github.com/nxhung2304/taskflow/issues/87)
  - Route: Nested `/api/v1/tasks/:task_id/comments`

- [x] ** Docs for API** - [#48](https://github.com/nxhung2304/taskflow/issues/48)
  - [ ] API documentation ( Rswag )
- [x] **Use Rspec instead of Mini Test** 

---

### Phase 3: Admin Side

**CRUD Operations**
- [x] Boards controller (CRUD + ownership) - [#43](https://github.com/nxhung2304/taskflow/issues/43)
- [x] Lists controller (CRUD) - [#44](https://github.com/nxhung2304/taskflow/issues/44)
- [x] Tasks controller (CRUD) - [#45](https://github.com/nxhung2304/taskflow/issues/45)
- [ ] Comments controller (CRUD) - [#46](https://github.com/nxhung2304/taskflow/issues/46)

**Search & Filtering**
- [ ] Task filtering (status, assignee, deadline) - [#49](https://github.com/nxhung2304/taskflow/issues/49)

---

### Phase 4: Advanced Features

**Background Jobs**
- [ ] Setup Sidekiq + Redis
- [ ] Email notifications for deadlines
- [ ] Task assignment notifications

**Performance**
- [ ] Database indexing optimization
- [ ] N+1 query fixes with includes
- [ ] Redis caching for frequent queries

---

### Phase 5: Production Ready

**Containerization**
- [ ] Dockerfile for Rails app
- [ ] Docker Compose for development
- [ ] Environment configuration

**Deployment**
- [ ] Setup Kamal deployment
- [ ] Production database setup
- [ ] SSL certificates

**Monitoring**
- [ ] Sentry error tracking
- [ ] Rate limiting with Rack::Attack
- [ ] Health check endpoints
