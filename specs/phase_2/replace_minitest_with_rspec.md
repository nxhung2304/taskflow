## Status:
- [ ] implemented

## Description
Replace MiniTest with RSpec as the project's test framework. RSpec is required by rswag and provides a more expressive, widely-adopted testing DSL for Rails APIs.

## Related
- Part of Phase 2: API
- Depends on: rswag setup (rswag requires RSpec)
- Affects: All future tests

## Why Replace MiniTest?

| Reason | Detail |
|--------|--------|
| rswag dependency | rswag-specs is built on RSpec — cannot use MiniTest |
| No existing tests | Project had zero test files, so nothing to migrate |
| Ecosystem | RSpec + FactoryBot + Shoulda is the most common Rails API testing stack |
| Expressiveness | `describe`/`context`/`it` blocks, `let`/`before` lazy loading, shared examples |

## What Changed

### Gemfile
```ruby
group :development, :test do
  gem "rspec-rails"       # Full RSpec framework for Rails
  gem "rswag-specs"       # OpenAPI spec generation (requires RSpec)
  gem "factory_bot_rails"  # Test data factories (replaces fixtures)
end

group :test do
  gem "shoulda", "~> 4.0"  # Already existed, works with RSpec
  gem "simplecov"           # Already existed, works with RSpec
end
```

### Files Created
| File | Purpose |
|------|---------|
| `.rspec` | CLI options: `--require spec_helper --format documentation` |
| `spec/spec_helper.rb` | SimpleCov, RSpec base config |
| `spec/rails_helper.rb` | Rails env, migration check, FactoryBot include |
| `spec/factories/*.rb` | Factories for User, Board, List, Task, Comment |

### Test Directory Structure
```
spec/
├── spec_helper.rb
├── rails_helper.rb
├── swagger_helper.rb
├── support/
│   └── auth_helper.rb
├── factories/
│   ├── users.rb
│   ├── boards.rb
│   ├── lists.rb
│   ├── tasks.rb
│   └── comments.rb
└── requests/
    └── api/
        └── v1/
            ├── auth_spec.rb
            ├── users_spec.rb
            ├── boards_spec.rb
            ├── lists_spec.rb
            ├── tasks_spec.rb
            └── comments_spec.rb
```

## Convention Going Forward

### Running Tests
```bash
# Run all specs
bundle exec rspec

# Run specific file
bundle exec rspec spec/requests/api/v1/boards_spec.rb

# Run specific test by line number
bundle exec rspec spec/requests/api/v1/boards_spec.rb:42

# Run with tag filter
bundle exec rspec --tag focus
```

### Writing New Tests
All new tests should follow RSpec conventions:

- **Request specs** go in `spec/requests/` (replaces controller tests)
- **Model specs** go in `spec/models/`
- **Use FactoryBot** instead of fixtures: `create(:user)`, `build(:board)`
- **Use `let`** for lazy-loaded test data
- **Use `describe`/`context`/`it`** for structure

### Naming Pattern
```
spec/requests/api/v1/{resource}_spec.rb   # API request specs
spec/models/{model}_spec.rb               # Model specs
spec/services/{service}_spec.rb           # Service object specs
```

### Generate Swagger After Writing Specs
```bash
bundle exec rake rswag:specs:swaggerize
```

## Technical Notes

- `test/` directory (MiniTest default) is no longer used — all tests live in `spec/`
- SimpleCov is configured in `spec/spec_helper.rb` with 80% minimum coverage
- FactoryBot syntax methods (`create`, `build`, `build_stubbed`) are globally included via `rails_helper.rb`
- `shoulda` matchers work with RSpec out of the box (already in Gemfile)
- Spec files require `swagger_helper` (for rswag specs) or `rails_helper` (for regular specs)

---
