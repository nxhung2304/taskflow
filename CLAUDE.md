# Taskflow

A Trello-like task management application with Rails API backend and Flutter mobile frontend.

## Repository

- https://github.com/nxhung2304/taskflow

## Tech Stack

- **Backend**: Rails API (this repo)
- **Mobile**: Flutter (separate repo)
- **Database**: PostgreSQL with UUID
- **Auth**: Devise + JWT
- **Authorization**: CanCanCan
- **Background Jobs**: Sidekiq + Redis
- **Serialization**: Blueprinter
- **Pagination**: Kaminari

## Database Schema

| Table | Description | Key Fields |
|-------|-------------|------------|
| **users** | User auth & profile (Devise) | `id` (UUID), `email`, `encrypted_password`, `name`, `role` (admin/member) |
| **boards** | Project boards (like Trello) | `id` (UUID), `name`, `description`, `owner_id` (FK users) |
| **lists** | Columns in board | `id` (UUID), `name`, `position`, `board_id` (FK boards) |
| **tasks** | Main tasks with deadline/assign | `id` (UUID), `title`, `description`, `status`, `deadline`, `position`, `list_id` (FK lists), `assignee_id` (FK users) |
| **comments** | Task discussions | `id` (UUID), `content`, `task_id` (FK tasks), `user_id` (FK users) |

## Roadmap

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

- [ ] **Board API** - [#85](https://github.com/nxhung2304/taskflow/issues/85)
  - Full CRUD `/api/v1/boards` with authorization
  - Tools: Controller, Blueprinter serializer, CanCanCan integration

- [ ] **List API** - [#86](https://github.com/nxhung2304/taskflow/issues/86)
  - Position ordering with `acts_as_list`
  - Route: Nested `/api/v1/boards/:board_id/lists`

- [ ] **Task API** - [#88](https://github.com/nxhung2304/taskflow/issues/88)
  - Status management, assignee, deadline filtering
  - Route: Nested `/api/v1/lists/:list_id/tasks`

- [ ] **Comment API** - [#87](https://github.com/nxhung2304/taskflow/issues/87)
  - Route: Nested `/api/v1/tasks/:task_id/comments`

- [ ] **Pagination, Error Handling, Docs** - [#89](https://github.com/nxhung2304/taskflow/issues/89)
  - Pagination (Kaminari)
  - Error handling middleware
  - API documentation (rswag)

---

### Phase 3: Admin Side

**CRUD Operations**
- [ ] Boards controller (CRUD + ownership) - [#43](https://github.com/nxhung2304/taskflow/issues/43)
- [ ] Lists controller (with position ordering) - [#44](https://github.com/nxhung2304/taskflow/issues/44)
- [ ] Tasks controller (with status management) - [#45](https://github.com/nxhung2304/taskflow/issues/45)
- [ ] Comments controller - [#46](https://github.com/nxhung2304/taskflow/issues/46)

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

---

## API Routes Structure

```ruby
# API for Flutter mobile app (shallow nesting)
namespace :api do
  namespace :v1 do
    resources :boards do
      resources :lists, shallow: true
    end
    resources :lists, only: [] do
      resources :tasks, shallow: true
    end
    resources :tasks, only: [] do
      resources :comments, shallow: true
    end
  end
end

# Admin web dashboard
namespace :admin do
  resources :boards
  resources :lists
  resources :tasks
  resources :comments
  resources :users
end
```

## Key Design Decisions

1. **UUID Primary Keys**: All tables use UUID for better security and distributed systems support
2. **Shallow Nesting**: API routes use shallow nesting for cleaner URLs
3. **acts_as_list**: Used for position ordering in Lists and Tasks
4. **Role-based Access**: Admin has full access, Member has scoped access
