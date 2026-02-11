## Status:
- [x] Merged

## Description
Implement CRUD API endpoints for Tasks resource with status management, assignee assignment, deadline filtering, and position ordering using `acts_as_list`.

## Related
- Part of Phase 2: Core Features
- Depends on: List API (completed)
- Related model: `Task` with `acts_as_list`
- GitHub Issue: [#96](https://github.com/nxhung2304/taskflow/issues/96)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/lists/:list_id/tasks` | List all tasks in a list |
| POST | `/api/v1/lists/:list_id/tasks` | Create task in a list |
| GET | `/api/v1/tasks/:id` | Get single task |
| PATCH | `/api/v1/tasks/:id` | Update task |
| DELETE | `/api/v1/tasks/:id` | Delete task |
| PATCH | `/api/v1/tasks/:id/move` | Reorder task position |

## Acceptance Criteria

### CRUD Operations
- [ ] Index: Return tasks ordered by `position` (ascending)
- [ ] Index: Support filtering by `status`, `priority`, `assignee_id`
- [ ] Create: Auto-assign position (end of list) via `acts_as_list`
- [ ] Create: Default status to `todo`
- [ ] Show: Include comments count
- [ ] Update: Allow title, description, status, priority, deadline, assignee_id updates
- [ ] Destroy: Handle dependent comments (destroy)

### Position Ordering
- [ ] Use `acts_as_list` scope: `list_id`
- [ ] Endpoint to move task within same list using `insert_at`
- [ ] Reorder should update sibling positions automatically
- [ ] Reuse `PositionForm` for position validation

### Status & Priority Management
- [ ] Status enum: `todo` (0), `in_progress` (1), `completed` (2)
- [ ] Priority enum: `low` (0), `medium` (1), `high` (2)
- [ ] Validate status/priority values on update

### Assignee
- [ ] Assign task to a user via `assignee_id`
- [ ] Assignee is optional (nullable)
- [ ] Validate assignee exists when provided

### Authorization (CanCanCan)
- [ ] Ownership-based: CRUD only on tasks within lists of owned boards
- [ ] Validate user has access through chain: task -> list -> board -> user
- [ ] Add to Ability: `can :manage, Task, list: { board: { user_id: user.id } }`

### Serialization
- [ ] Create `TaskBlueprint` with views:
  - `:default` - id, title, description, status, priority, position, deadline, assignee_id, list_id, comments_count, timestamps
  - `:with_comments` - includes nested comments ordered by created_at

## Request/Response Examples

### GET /api/v1/lists/:list_id/tasks
```json
// Request with filters (optional)
GET /api/v1/lists/:list_id/tasks?status=todo&priority=high&assignee_id=uuid

// Response 200
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Implement login",
      "description": "Add JWT auth",
      "status": "todo",
      "priority": "high",
      "position": 1,
      "deadline": "2026-03-01T00:00:00Z",
      "assignee_id": "uuid",
      "list_id": "uuid",
      "comments_count": 3,
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "pagination": { "current_page": 1, "total_pages": 1, "total_count": 1 }
}
```

### POST /api/v1/lists/:list_id/tasks
```json
// Request
{ "task": { "title": "Implement login", "description": "Add JWT auth", "priority": "high", "deadline": "2026-03-01" } }

// Response 201
{
  "id": "uuid",
  "title": "Implement login",
  "description": "Add JWT auth",
  "status": "todo",
  "priority": "high",
  "position": 1,
  "deadline": "2026-03-01T00:00:00Z",
  "assignee_id": null,
  "list_id": "uuid",
  "comments_count": 0,
  "created_at": "...",
  "updated_at": "..."
}
```

### PATCH /api/v1/tasks/:id
```json
// Request
{ "task": { "status": "in_progress", "assignee_id": "uuid" } }

// Response 200
{
  "id": "uuid",
  "title": "Implement login",
  "status": "in_progress",
  "assignee_id": "uuid",
  ...
}
```

### PATCH /api/v1/tasks/:id/move
```json
// Request
{ "task": { "position": 1 } }

// Response 200
{
  "id": "uuid",
  "title": "Implement login",
  "position": 1,
  ...
}
```

## Technical Notes

- Use shallow nesting: collection actions under lists, member actions standalone
- Scope `acts_as_list` to `list_id` to ensure positions are per-list
- Reuse `PositionForm` from List API for move validation
- Reuse `Paginatable` concern for index pagination
- Use `load_and_authorize_resource` with CanCanCan (same pattern as ListsController)
- Override `current_ability` already handled in `Api::V1::ApplicationController`
- Use existing scopes `by_status` and `by_priority` for filtering
- Task `deadline` validation: must be in the future (only on create/update when provided)

## Tasks

- [ ] Add routes (shallow nesting under lists)
- [ ] Create `TasksController` with CRUD + move action
- [ ] Create `TaskBlueprint` serializer
- [ ] Add `Task` authorization in `Ability`
- [ ] Add index filtering (status, priority, assignee_id)
- [ ] Handle errors (list not found, unauthorized, invalid status/priority)
- [ ] Write tests (CRUD, move, filtering, authorization, error cases)
- [ ] Add task fixtures (multiple tasks in same list for move tests)

---
