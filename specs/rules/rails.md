# Rails Code Rules

## General Principles

- Follow Rails Convention over Configuration
- Prefer readability over clever code
- Avoid unnecessary abstractions
- Keep methods short and focused
- Prefer explicit code over implicit behavior

---

## Naming Conventions

- Use descriptive names
- Avoid abbreviations

Good
```ruby
user = User.find(user_id)
```

Bad
```ruby
u = User.find(id)
```

---

## Controllers

Controllers should only handle HTTP concerns.

Rules
- Keep controllers thin
- Do not place business logic inside controllers
- Use Strong Parameters
- Delegate business logic to Service Objects
- Render JSON through a serializer (project-specific)
- Avoid complex conditional logic

Bad
```ruby
def create
  user = User.new(params[:user])

  if user.save
    WelcomeMailer.send_email(user)
  end
end
```

Good
```ruby
def create
  user = CreateUserService.call(user_params)
  render json: user
end
```

---

## Models

Models represent domain data and core domain logic.

Rules
- Models should contain domain logic
- Avoid large models (> 200 lines when possible)
- Extract complex logic to Service Objects
- Use scopes for reusable queries
- Prefer `delegate` for association forwarding
- Avoid callbacks for complex logic

Scope example
```ruby
scope :active, -> { where(active: true) }
```

Delegate example
```ruby
delegate :name, to: :user
```

---

## Service Objects

Use service objects when business logic becomes complex.

Rules
- Located in `app/services`
- Class name should represent an action
- Use `.call` as entrypoint
- Raise exception on failure — do not return `nil` or `false`
- Use bang methods (`create!`, `save!`, `update!`) inside services
- Controller is responsible for rescuing exceptions

Service example
```ruby
class CreateUserService
  def self.call(params)
    user = User.create!(params)
    SendWelcomeEmailJob.perform_later(user.id)
    user
  end
end
```

Controller rescue pattern
```ruby
def create
  user = CreateUserService.call(user_params)
  render json: user
rescue ActiveRecord::RecordInvalid => e
  render json: { data: nil, error: e.message }, status: :unprocessable_entity
end
```

---

## Query Optimization

Avoid inefficient database queries.

Rules
- Prevent N+1 queries
- Use `includes` or `preload`
- Use `pluck` when only retrieving specific fields
- Avoid loading entire objects unnecessarily

Good
```ruby
User.includes(:posts)
```

Better when only retrieving ids
```ruby
User.pluck(:id)
```

---

## Background Jobs

Long-running tasks must run asynchronously.

Rules
- Use ActiveJob
- Do not execute heavy work in controllers or models
- Pass IDs instead of objects

Example
```ruby
SendEmailJob.perform_later(user.id)
```

---

## Validations

Use ActiveRecord validations for data integrity.

```ruby
validates :email, presence: true, uniqueness: true
```

- Avoid complex validation logic inside models
- Move complex validation to service objects when needed

---

## Callbacks

Use callbacks carefully.

Bad
```ruby
after_create :send_email
```

Better — handle explicitly inside a service object.

---

## Authorization

Rules
- Authorization logic must not be placed inside service objects
- Service objects assume the caller is already authorized
- Use a dedicated authorization library or pattern (project-specific)
- Authorize at the controller layer before delegating to services

---

## JSON API

Rules
- JSON keys should use `snake_case`
- Always return a consistent structure

Success response
```json
{ "data": {}, "error": null }
```

Error response
```json
{ "data": null, "error": "Not Found" }
```

---

## Error Handling

Prefer explicit error handling.

```ruby
rescue ActiveRecord::RecordNotFound
  render json: { data: nil, error: "Not Found" }, status: :not_found
```

---

## Method Design

Rules
- Methods should do one thing
- Prefer early return
- Avoid deep nesting

Bad
```ruby
if user
  if user.active?
    do_something
  end
end
```

Good
```ruby
return unless user&.active?

do_something
```

---

## Constants

Avoid magic numbers or strings.

Bad
```ruby
if user.age > 18
```

Good
```ruby
LEGAL_AGE = 18

if user.age > LEGAL_AGE
```

---

## Testing

All business logic should be testable.

Rules
- Test service objects thoroughly
- Test model validations and scopes
- Keep controller tests minimal
- Avoid testing private methods
- Use factories for test data setup (project-specific tooling may vary)

---

## AI Coding Instructions

When generating Ruby on Rails code:
- Follow all rules defined in this document
- Prefer simple and readable implementations
- Avoid unnecessary gems
- Do not introduce architecture not already used in the project
- Prefer Service Objects for complex logic
- Avoid fat controllers and fat models
- Ensure queries are optimized
- Raise exceptions in service objects — do not silently return nil
- Do not place authorization logic inside service objects
