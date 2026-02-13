## Status:
- [x] implemented

## Description
Setup rswag (OpenAPI/Swagger) for auto-generated, interactive API documentation. Specs serve as both integration tests and documentation source.

## Related
- Part of Phase 2: API
- Depends on: All API endpoints (Boards, Lists, Tasks, Comments, Auth)
- GitHub Issue: [#89](https://github.com/nxhung2304/taskflow/issues/89)

## What Was Done

### Gems Added
| Gem | Group | Purpose |
|-----|-------|---------|
| `rswag-api` | default | Serves swagger.yaml as JSON endpoint |
| `rswag-ui` | default | Swagger UI at `/api-docs` |
| `rswag-specs` | development, test | RSpec DSL for writing OpenAPI specs |
| `rspec-rails` | development, test | Full RSpec test framework for Rails |
| `factory_bot_rails` | development, test | Test data factories |

### Generators Run
- `rails g rswag:api:install` — created `config/initializers/rswag_api.rb`
- `rails g rswag:ui:install` — created `config/initializers/rswag_ui.rb`

### Files Created

| File | Purpose |
|------|---------|
| `.rspec` | RSpec CLI config |
| `spec/spec_helper.rb` | SimpleCov + RSpec base config |
| `spec/rails_helper.rb` | Rails test env, FactoryBot |
| `spec/swagger_helper.rb` | OpenAPI 3.0 definition, DeviseTokenAuth security scheme |
| `spec/support/auth_helper.rb` | Helper to sign in and extract auth headers |
| `spec/factories/users.rb` | User factory |
| `spec/factories/boards.rb` | Board factory |
| `spec/factories/lists.rb` | List factory |
| `spec/factories/tasks.rb` | Task factory |
| `spec/factories/comments.rb` | Comment factory |
| `spec/requests/api/v1/auth_spec.rb` | Auth endpoints (sign_up, sign_in, sign_out) |
| `spec/requests/api/v1/users_spec.rb` | GET /users/me |
| `spec/requests/api/v1/boards_spec.rb` | Boards CRUD |
| `spec/requests/api/v1/lists_spec.rb` | Lists CRUD + move |
| `spec/requests/api/v1/tasks_spec.rb` | Tasks CRUD + move + filtering |
| `spec/requests/api/v1/comments_spec.rb` | Comments CRUD |

### Authentication Scheme
DeviseTokenAuth uses 4 headers (NOT standard Bearer JWT):

| Header | Description |
|--------|-------------|
| `access-token` | Token from sign in response |
| `client` | Client identifier from sign in response |
| `uid` | User email |
| `token-type` | Always "Bearer" |

Defined in `spec/swagger_helper.rb` as `apiKey` security schemes. The `auth_headers_for(user)` helper signs in via HTTP and captures these headers for use in specs.

### API Endpoints Documented

| Tag | Endpoints |
|-----|-----------|
| Auth | POST /auth (sign up), POST /auth/sign_in, DELETE /auth/sign_out |
| Users | GET /users/me |
| Boards | GET/POST /boards, GET/PUT/DELETE /boards/:id |
| Lists | GET/POST /boards/:board_id/lists, GET/PUT/DELETE /lists/:id, PATCH /lists/:id/move |
| Tasks | GET/POST /lists/:list_id/tasks, GET/PUT/DELETE /tasks/:id, PATCH /tasks/:id/move |
| Comments | GET/POST /tasks/:task_id/comments, GET/PUT/DELETE /comments/:id |

Each endpoint documents: success, validation error (422), not found (404), and unauthorized (401) responses.

## How to Use

### Generate Swagger Docs
```bash
bundle exec rake rswag:specs:swaggerize
```
Outputs: `swagger/v1/swagger.yaml`

### View Interactive Docs
Start Rails server and visit:
```
http://localhost:3000/api-docs
```

### Run as Tests
```bash
bundle exec rspec spec/requests/
```

## Technical Notes

- rswag specs are real RSpec request tests — they hit the API and validate responses
- Swagger output at `swagger/v1/swagger.yaml` is served by `rswag-api` middleware
- `rswag-ui` mounts Swagger UI and reads from the yaml endpoint
- Shallow nesting is reflected in specs: nested paths for collection, standalone for member actions
- Pagination params (`page`, `per_page`) documented on all index endpoints
- Filter params (`status`, `priority`, `assignee_id`) documented on tasks index

---
