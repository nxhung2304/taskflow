## Status:
- [x] merged

## Description
Implement CRUD API endpoints for Comments resource. Comments are associated with Tasks and tracked by User (author). Ordered by `created_at` (ascending).

## Related
- Part of Phase 2: Core Features
- Depends on: Task API (completed)
- Related model: `Comment` (belongs_to :task, belongs_to :user)
- GitHub Issue: [#87](https://github.com/nxhung2304/taskflow/issues/87)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/tasks/:task_id/comments` | List all comments in a task |
| POST | `/api/v1/tasks/:task_id/comments` | Create comment in a task |
| GET | `/api/v1/comments/:id` | Get single comment |
| PATCH | `/api/v1/comments/:id` | Update comment |
| DELETE | `/api/v1/comments/:id` | Delete comment |

## Acceptance Criteria

### CRUD Operations
- [ ] Index: Return comments ordered by `created_at` (ascending)
- [ ] Create: Assign `user_id` from `current_api_v1_user` (author tracking)
- [ ] Show: Include user info (author)
- [ ] Update: Allow content update (only by comment author)
- [ ] Destroy: Only comment author or board owner can delete

### Authorization (CanCanCan)
- [ ] Create: User must have access to parent task (through task -> list -> board -> user chain)
- [ ] Read: User must have access to parent task
- [ ] Update: Only comment author can update their own comments
- [ ] Delete: Comment author or board owner can delete
- [ ] Add to Ability: `can :manage, Comment, task: { list: { board: { user_id: user.id } } }`

### Serialization
- [ ] Create `CommentBlueprint` with views:
  - `:default` - id, content, task_id, user_id, timestamps
  - `:with_author` - includes nested user (author) info
- [ ] Uncomment `CommentBlueprint` association in `TaskBlueprint#with_comments` view

## Request/Response Examples

### GET /api/v1/tasks/:task_id/comments
```json
// Response 200
{
  "comments": [
    {
      "id": "uuid",
      "content": "Looks good, let's proceed",
      "task_id": "uuid",
      "user_id": "uuid",
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "pagination": { "current_page": 1, "total_pages": 1, "total_count": 1 }
}
```

### POST /api/v1/tasks/:task_id/comments
```json
// Request
{ "comment": { "content": "This needs more detail" } }

// Response 201
{
  "id": "uuid",
  "content": "This needs more detail",
  "task_id": "uuid",
  "user_id": "uuid",
  "created_at": "...",
  "updated_at": "..."
}
```

### PATCH /api/v1/comments/:id
```json
// Request
{ "comment": { "content": "Updated comment text" } }

// Response 200
{
  "id": "uuid",
  "content": "Updated comment text",
  "task_id": "uuid",
  "user_id": "uuid",
  "created_at": "...",
  "updated_at": "..."
}
```

## Technical Notes

- Use shallow nesting: collection actions under tasks, member actions standalone
- No `acts_as_list` needed - comments are ordered by `created_at`, not `position`
- No `Moveable` concern needed
- Include `Paginatable` concern for index pagination
- Assign `user_id` from `current_api_v1_user` on create (do NOT accept from params)
- Use `load_and_authorize_resource` with CanCanCan (same pattern as Tasks/Lists controllers)
- Override `current_ability` already handled in `Api::V1::ApplicationController`
- Comment model already validates content (presence, max 500 chars)

## Tasks

- [ ] Add routes (shallow nesting under tasks)
- [ ] Create `CommentBlueprint` serializer
- [ ] Add `Comment` authorization in `Ability`
- [ ] Create `CommentsController` with CRUD actions
- [ ] Uncomment `CommentBlueprint` in `TaskBlueprint#with_comments`
- [ ] Handle errors (task not found, unauthorized, validation errors)
- [ ] Write tests (CRUD, authorization, error cases)
- [ ] Add comment fixtures for tests

---
