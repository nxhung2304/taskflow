# Setup for project
setup-pre-commit:
	@echo "🔧 Setting up pre-commit hooks..."

	@if command -v pre-commit >/dev/null 2>&1; then \
		echo "✅ pre-commit is installed."; \
	else \
		echo "⬇️ Installing pre-commit..."; \
		brew install pre-commit; \
	fi

	@if [ ! -f .pre-commit-config.yaml ]; then \
		echo "📝 Creating default .pre-commit-config.yaml file..."; \
		printf "%s\n" \
"repos:" \
"  - repo: local" \
"    hooks:" \
"      - id: rubocop" \
"        name: RuboCop" \
"        entry: bundle exec rubocop" \
"        language: ruby" \
"        types: [ruby]" \
"      - id: rails-test" \
"        name: Rails Test" \
"        entry: bundle exec rails test" \
"        language: system" \
"        pass_filenames: false" \
		> .pre-commit-config.yaml; \
	else \
		echo "✅ .pre-commit-config.yaml already exists."; \
	fi

	@pre-commit install
	@echo "✅ pre-commit installed successfully!"

setup:
	bundle install
	yarn install
	rails db:create
	rails db:migrate
	rails db:seed
	$(MAKE) setup-pre-commit

# Database
db-reset:
	rails db:migrate:reset
	rails db:seed

# Generation
# 1. API
g-api:
	if [ -z "$(NAME)" ]; then \
		echo "Error: NAME variable is not set. Please provide controller name(s)." >&2; \
		exit 1; \
	fi
	rails generate controller Api::V1::$(NAME) index show create update destroy --no-helper --no-assets --no-view-specs

d-api:
	if [ -z "$(NAME)" ]; then \
		echo "Error: NAME variable is not set. Please provide controller name(s)." >&2; \
		exit 1; \
	fi
	rails destroy controller Api::V1::$(NAME) index show create update destroy --no-helper --no-assets --no-view-specs

