# Setup for project
setup:
	bundle install
	yarn install
	rails db:create
	rails db:migrate
	rails db:seed

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
	rails generate controller Api::V1::$(NAME) index show create update destroy --no-helper --no-assets --no-view --no-view-specs

d-api:
	if [ -z "$(NAME)" ]; then \
		echo "Error: NAME variable is not set. Please provide controller name(s)." >&2; \
		exit 1; \
	fi
	rails destroy controller Api::V1::$(NAME) index show create update destroy --no-helper --no-assets --no-view --no-view-specs

