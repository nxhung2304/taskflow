# Issue #45: Tasks Controller (CRUD)

**Status:** Approved → PR: https://github.com/nxhung2304/taskflow/pull/108
**GitHub Issue:** #45
**Assignee:** —
**Priority:** High
**Milestone:** Phase 3 - Admin Side

## Overview

Implement admin CRUD operations for Tasks. Tasks are items within Lists and Boards, with support for titles, descriptions, status tracking, deadline management, and assignee assignment.

## Requirements

### Task Attributes
- **title** (string, required) - Task title/name
- **description** (text, optional) - Detailed task description
- **status** (enum: todo/in_progress/completed, default: todo) - Task status tracking
- **priority** (enum: low/medium/high, default: low) - Task priority level
- **deadline** (datetime, optional) - Task deadline date (must be in future)
- **position** (integer) - Order position within the list (managed by `acts_as_list`)
- **list_id** (foreign key) - Parent list reference
- **assignee_id** (foreign key, optional) - Assigned user reference
- **comments_count** (integer, counter cache) - Number of comments on this task

**Note:** Model (app/models/task.rb) already exists with these attributes and validations

### Controller Actions

#### 1. **Index** (GET `/admin/lists/:list_id/tasks`)
- Display all tasks for a specific list
- Filter tasks by: status, priority, assignee (use model scopes: `with_status`, `with_priority`, `with_assignee_id`)
- Paginate results (20 per page using Kaminari)
- Show task details: title, status badge, priority, assignee, deadline, comment count
- Links to show, edit, delete, and create new task
- Breadcrumb navigation: Home > Board > List > Tasks
- Handle both nested and flat routes (like Lists controller does)

#### 2. **Show** (GET `/admin/lists/:list_id/tasks/:id`)
- Display single task details with full information
- Show all comments on the task
- Display assignee information and deadline status
- Show task status with edit capability
- Links to edit, delete, and create comment
- Breadcrumb navigation

#### 3. **New** (GET `/admin/lists/:list_id/tasks/new`)
- Form to create a new task
- Pre-select list from parent board (similar to Lists controller)
- Fields: title (required), description, status, priority, deadline, assignee (optional)
- Submit button

#### 4. **Create** (POST `/admin/lists/:list_id/tasks`)
- Persist new task with validation (title required, deadline must be future, assignee must exist)
- Success: Redirect to index with success message
- Failure: Re-render form with errors and `status: :unprocessable_entity`
- Use i18n for messages: `admin.tasks.messages.created`

#### 5. **Edit** (GET `/admin/lists/:list_id/tasks/:id/edit`)
- Form to edit task details
- Pre-populate all fields (title, description, status, priority, deadline, assignee)
- Submit button

#### 6. **Update** (PATCH `/admin/lists/:list_id/tasks/:id`)
- Update task attributes
- Success: Redirect to index with success message
- Failure: Re-render form with errors
- Use i18n for messages: `admin.tasks.messages.updated`

#### 7. **Destroy** (DELETE `/admin/lists/:list_id/tasks/:id`)
- Delete the task (and associated comments if cascade enabled)
- Confirm deletion to prevent accidents
- Success: Redirect to index with success message
- Use i18n for messages: `admin.tasks.messages.destroyed`

### Implementation Pattern

Follow the **Lists controller** pattern (see: `app/controllers/admin/lists_controller.rb`):

**Key patterns:**
- Inherit from `Admin::ApplicationController`
- Use `load_and_authorize_resource :task` for authorization via CanCanCan
- Define constant for pagination: `TASKS_PER_PAGE = 20`
- Use `before_action` for common setup:
  - `:set_list` (required for all actions)
  - `:set_list_from_task` (for nested show/edit/update/destroy)
  - `:set_users_for_form` (for new/create/edit/update to populate assignee dropdown)
- Use strong parameters: `params.require(:task).permit(:title, :description, :status, :priority, :deadline, :list_id, :assignee_id)`
- Handle both nested (`/lists/:list_id/tasks`) and flat routes (`/tasks`)
- Use `includes(:assignee, :list)` to prevent N+1 queries
- Return `status: :unprocessable_entity` on validation errors
- Use i18n for all user-facing messages

### Routes

Add nested routes under list:
```ruby
resources :lists do
  resources :tasks
end
```

Or use shallow routing pattern already established:
```ruby
resources :lists, shallow: true do
  resources :tasks
end
```

### Views

Create Haml/Erb views:
- `views/admin/tasks/index.html.haml` — List all tasks with filters and actions
- `views/admin/tasks/show.html.haml` — Show single task details with comments
- `views/admin/tasks/_form.html.haml` — Shared form for create/edit
- `views/admin/tasks/new.html.haml` — New task form
- `views/admin/tasks/edit.html.haml` — Edit task form

### View Features

#### Index View
- Status filter dropdown (All / Pending / In Progress / Completed)
- Assignee filter (select user or "Unassigned")
- Deadline filter (Due Soon / Overdue / All)
- Search by title/description
- Task list with columns: title, status badge, assignee, deadline, comments count
- Action buttons: View, Edit, Delete

#### Form Partial
- Title input (required)
- Description textarea
- Status select (pending / in_progress / completed)
- Deadline date picker
- Assignee select with user options
- Submit button
- Error messages with i18n

#### Show View
- Task header with title and status badge
- Task metadata: list name, board name, assignee, deadline, created/updated dates
- Description section
- Comments section with list of comments and comment count
- Action buttons: Edit, Delete, Add Comment
- Breadcrumb navigation

### i18n Messages

Add to `config/locales/en.yml`:
```yaml
admin:
  tasks:
    index: Tasks
    show: Task Details
    new: New Task
    edit: Edit Task
    messages:
      created: Task created successfully
      updated: Task updated successfully
      destroyed: Task deleted successfully
    status:
      todo: To Do
      in_progress: In Progress
      completed: Completed
    priority:
      low: Low
      medium: Medium
      high: High
    labels:
      title: Title
      description: Description
      status: Status
      priority: Priority
      deadline: Deadline
      assignee: Assigned To
      comments: Comments
    filters:
      all_statuses: All Statuses
      all_priorities: All Priorities
      all_assignees: All Assignees
```

### Testing (RSpec)

- Test all CRUD actions
- Test validation errors (title required)
- Test authorization (admin access)
- Test status transitions
- Test assignee management
- Test deadline filtering
- Test redirects and flash messages
- Test pagination
- Test i18n messages
- Test N+1 query prevention with `includes`
- Test strong parameters filtering

## Acceptance Criteria

- [ ] Tasks controller with all CRUD actions created
- [ ] Routes configured with nested list relationship
- [ ] All views created with proper layout and styling
- [ ] i18n messages configured for all user-facing text
- [ ] Authorization enforced via CanCanCan
- [ ] Pagination working (20 per page)
- [ ] Status filtering working (pending/in_progress/completed)
- [ ] Assignee assignment and display working
- [ ] Deadline management with date picker working
- [ ] RSpec tests passing for all actions
- [ ] No N+1 queries (use `includes` for associations)
- [ ] Form validation working with proper error messages
- [ ] Delete confirmation implemented
- [ ] Breadcrumb navigation implemented
- [ ] Comment count display working

## Related Issues

- Closes #45
- Depends on: #43 (Boards CRUD), #44 (Lists CRUD) must be completed first
- Relates to: #46 (Comments CRUD), #49 (Task filtering)

## Reference Implementation Files

**Study these files for patterns:**

### Controllers (already implemented)
- `app/controllers/admin/boards_controller.rb` — Simple pattern with single-level resource
- `app/controllers/admin/lists_controller.rb` — **Primary reference** — Shows nested + flat route handling
  - Line 2: `LISTS_PER_PAGE = 20` constant (follow this pattern with `TASKS_PER_PAGE`)
  - Line 4-7: `before_action` setup
  - Line 69-84: `fetch_board_lists` and `fetch_all_lists` helper methods (adapt for tasks)
  - Line 90-92: `redirect_path_after_action` helper (needed for nested/flat routing)

### Models (already implemented)
- `app/models/task.rb` — Shows available enums, validations, and scopes
  - Status enum: `{ todo: 0, in_progress: 1, completed: 2 }`
  - Priority enum: `{ low: 0, medium: 1, high: 2 }`
  - Available scopes: `:with_status`, `:with_priority`, `:with_assignee_id`
  - Validations: title required, deadline future, assignee exists

### Authorization
- `app/models/ability.rb` — Check authorization rules for tasks (should allow admin to manage all tasks)

## Implementation Notes

### Code Patterns to Follow

1. **Controller Structure** (from `app/controllers/admin/lists_controller.rb`):
   ```ruby
   class Admin::TasksController < Admin::ApplicationController
     TASKS_PER_PAGE = 20

     load_and_authorize_resource :task
     before_action :set_list, only: %i[index show new create edit update destroy]
     before_action :set_list_from_task, only: %i[show edit update destroy]
     before_action :set_users_for_form, only: %i[new create edit update]
   ```

2. **Index Action** (handle both nested `/lists/:list_id/tasks` and flat `/tasks`):
   - Use `board_specific?` helper to check for `params[:list_id]`
   - Call `fetch_list_tasks` or `fetch_all_tasks` accordingly
   - Use `includes(:assignee, :list)` for N+1 prevention

3. **Strong Parameters:**
   ```ruby
   def task_params
     params.require(:task).permit(:title, :description, :status, :priority, :deadline, :list_id, :assignee_id)
   end
   ```

4. **Enum Values:**
   - Status: `todo`, `in_progress`, `completed` (not `pending`)
   - Priority: `low`, `medium`, `high`

5. **Validation Errors:**
   - Return `status: :unprocessable_entity` on save/update failure (as in Boards/Lists controllers)
   - Model validations already check: title required, deadline > today, assignee exists

6. **Redirect Logic:**
   - Use `admin_list_tasks_path(@list)` for nested routes
   - Use `admin_tasks_path` for flat routes
   - Create helper `redirect_path_after_action` like Lists controller

7. **Authorization:** Only admins manage tasks (already configured in CanCanCan ability.rb)

### Database & Model

1. **Position Management:** Tasks use `acts_as_list scope: :list` — position is auto-managed
2. **Counter Cache:** `comments_count` is auto-updated by the comments association
3. **Orderable Module:** Task includes `Orderable` module (check what it provides)

### Views & UX

1. **Filtering:**
   - Status filter (use Task enum values)
   - Priority filter (use Task enum values)
   - Assignee filter (populate with User.pluck(:name, :id))
   - Form should use Rails select helpers with enums

2. **Deadline Display:** Show relative time ("Due in 2 days", "Overdue by 1 day", "No deadline")

3. **Status Badges:** Use CSS classes for visual indication (color-coded)

4. **Breadcrumbs:** Home > Board name > List name > Tasks (extract board from list)

### Testing Requirements (RSpec)

- Test authorization with `load_and_authorize_resource`
- Test all CRUD actions with valid/invalid data
- Test both nested and flat routes
- Test filtering with scopes (`:with_status`, `:with_priority`, `:with_assignee_id`)
- Test pagination (20 per page)
- Test i18n message keys
- Test error status codes (`:unprocessable_entity` for validation errors)
- Test N+1 queries with database query count assertions

### Code Rules to Follow

- Per `specs/rules/rails.md`:
  - Thin controller, fat model
  - No magic numbers (use `TASKS_PER_PAGE = 20`)
  - Use stimulus for interactive features

