# Issue #44: Lists Controller (CRUD)

**Status:** Completed (PR: Draft)
**Assignee:** —
**Priority:** High
**Milestone:** Phase 3 - Admin Side

## Overview

Implement admin CRUD operations for Lists. Lists are columns/sections within a Board, and this controller should provide a web interface to manage them with create, read, update, and delete functionality.

## Requirements

### List Attributes
- **name** (string, required) - Name of the list/column
- **position** (integer) - Order position within the board (managed by `acts_as_list`)
- **tasks_count** (integer, counter cache) - Number of tasks in this list
- **board_id** (foreign key) - Parent board reference

### Controller Actions

#### 1. **Index** (GET `/admin/boards/:board_id/lists`)
- Display all lists for a specific board
- Filter lists by board & name
- Paginate results (20 per page using Kaminari)
- Show list details: name, position, task count
- Links to show, edit, delete, and create new list

#### 2. **Show** (GET `/admin/boards/:board_id/lists/:id`)
- Display single list details
- Show all tasks within the list
- Breadcrumb navigation: Home > Board > List
- Links to edit and delete

#### 3. **New** (GET `/admin/boards/:board_id/lists/new`)
- Form to create a new list
- Fields: name (required)
- Submit button

#### 4. **Create** (POST `/admin/boards/:board_id/lists`)
- Persist new list with validation
- Success: Redirect to index with success message
- Failure: Re-render form with errors
- Use i18n for messages: `admin.lists.messages.created`

#### 5. **Edit** (GET `/admin/boards/:board_id/lists/:id/edit`)
- Form to edit list details
- Pre-populate name field
- Submit button

#### 6. **Update** (PATCH `/admin/boards/:board_id/lists/:id`)
- Update list attributes
- Success: Redirect to index with success message
- Failure: Re-render form with errors
- Use i18n for messages: `admin.lists.messages.updated`

#### 7. **Destroy** (DELETE `/admin/boards/:board_id/lists/:id`)
- Delete the list
- Confirm deletion to prevent accidents
- Success: Redirect to index with success message
- Use i18n for messages: `admin.lists.messages.destroyed`

### Implementation Pattern

Follow the **Boards controller** pattern:
- Inherit from `Admin::ApplicationController`
- Use `layout "admin"`
- Apply authorization with CanCanCan
- Use `before_action` for common setup (`set_list`, `set_board`)
- Use strong parameters for safety
- Implement pagination with Kaminari
- Use i18n for user-facing messages

### Routes

Add nested routes under board:
```ruby
resources :boards do
  resources :lists
end
```

### Views

Create Haml/Erb views:
- `views/admin/lists/index.html.haml` — List all lists with actions
- `views/admin/lists/show.html.html` — Show single list details
- `views/admin/lists/_form.html.haml` — Shared form for create/edit
- `views/admin/lists/new.html.haml` — New list form
- `views/admin/lists/edit.html.haml` — Edit list form

### i18n Messages

Add to `config/locales/en.yml`:
```yaml
admin:
  lists:
    index: Lists
    show: List Details
    new: New List
    edit: Edit List
    messages:
      created: List created successfully
      updated: List updated successfully
      destroyed: List deleted successfully
```

### Testing (RSpec)

- Test all CRUD actions
- Test validation errors
- Test authorization (admin access)
- Test redirects and flash messages
- Test pagination
- Test i18n messages

## Acceptance Criteria

- [ ] Lists controller with all CRUD actions created
- [ ] Routes configured with nested board relationship
- [ ] All views created with proper layout and styling
- [ ] i18n messages configured for all user-facing text
- [ ] Authorization enforced via CanCanCan
- [ ] Pagination working (20 per page)
- [ ] RSpec tests passing for all actions
- [ ] No N+1 queries (use `includes`)
- [ ] Form validation working with proper error messages
- [ ] Delete confirmation implemented

## Related Issues

- Closes #44
- Depends on: #43 (Boards CRUD must be completed first)
- Relates to: #45 (Tasks CRUD), #46 (Comments CRUD)

## Implementation Notes

1. **Position Management:** Lists use `acts_as_list scope: :board` — ensure position is handled correctly during create/update
2. **Authorization:** Only admins should manage lists
3. **Stimulus JS:** Use stimulus for interactive features if needed (e.g., position reordering)
4. **Clean Code:** Keep controller thin, move business logic to models
5. **No Magic Numbers:** Use named variables for pagination limits
