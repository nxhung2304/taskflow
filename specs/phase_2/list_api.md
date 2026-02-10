## Description
Implement CRUD API endpoints for Lists resource with position ordering support using `acts_as_list`.

## Related
- Part of Phase 2: Core Features
- Depends on: Boards API (if not done)
- Related model: `List` with `acts_as_list`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/boards/:board_id/lists` | List all lists in a board |
| POST | `/api/v1/boards/:board_id/lists` | Create list in a board |
| GET | `/api/v1/lists/:id` | Get single list |
| PATCH | `/api/v1/lists/:id` | Update list |
| DELETE | `/api/v1/lists/:id` | Delete list |
| PATCH | `/api/v1/lists/:id/move` | Reorder list position |

## Acceptance Criteria

### CRUD Operations
- [ ] Index: Return lists ordered by `position` (ascending)
- [ ] Create: Auto-assign position (end of list)
- [ ] Show: Include tasks count or nested tasks (optional view)
- [ ] Update: Allow name update
- [ ] Destroy: Handle dependent tasks (destroy or restrict)

### Position Ordering
- [ ] Use `acts_as_list` scope: `board_id`
- [ ] Endpoint to move list: `move_to_position`, `move_higher`, `move_lower`
- [ ] Reorder should update sibling positions automatically

### Authorization (CanCanCan)
- [ ] Admin: Full access to all lists
- [ ] Member: CRUD only on lists within owned/accessible boards
- [ ] Validate user has access to parent board

### Serialization
- [ ] Create `ListBlueprint` with views:
- `:default` - id, name, position, board_id, timestamps
- `:with_tasks` - includes nested tasks ordered by position

## Request/Response Examples

### POST /api/v1/boards/:board_id/lists
```json
// Request
{ "list": { "name": "In Progress" } }

// Response 201
{
"list": {
  "id": "uuid",
  "name": "In Progress",
  "position": 2,
  "board_id": "uuid",
  "created_at": "...",
  "updated_at": "..."
}
}

PATCH /api/v1/lists/:id/move

// Request
{ "position": 1 }

// Response 200
{
"list": { "id": "uuid", "name": "In Progress", "position": 1, ... }
}

Technical Notes

- Use shallow nesting: collection actions under boards, member actions standalone
- Scope acts_as_list to board_id to ensure positions are per-board
- Consider using insert_at for specific position on create

Tasks

- Add routes (shallow nesting)
- Create ListsController with CRUD + move action
- Create ListBlueprint serializer
- Add authorization in Ability
- Handle errors (board not found, unauthorized)
- Test with Postman/curl

---
