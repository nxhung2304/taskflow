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

setup: setup-pre-commit

# Database
db-reset:
	rails db:migrate:reset
	rails db:seed
