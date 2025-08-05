.PHONY: help setup install db-setup db-create db-migrate db-seed db-reset db-disconnect test swagger server clean setup-hooks lint create-file-migration

# Default target
help:
	@echo "Available commands:"
	@echo "  setup                 - Complete project setup (install + db-setup + hooks)"
	@echo "  install               - Install dependencies"
	@echo "  setup-hooks           - Setup Git hooks for linting"
	@echo "  lint                  - Run RuboCop linter"
	@echo "  lint-fix              - Run RuboCop with auto-fix"
	@echo "  db-setup              - Setup database (create + migrate + seed)"
	@echo "  db-create             - Create databases"
	@echo "  db-migrate            - Run database migrations"
	@echo "  db-seed               - Seed database with sample data"
	@echo "  db-reset              - Reset database (drop + create + migrate + seed)"
	@echo "  db-disconnect         - Force disconnect all connections"
	@echo "  test                  - Run all tests"
	@echo "  swagger               - Generate Swagger documentation"
	@echo "  server                - Start Rails server"
	@echo "  clean                 - Clean temporary files"
	@echo "  create-file-migration - Create file migration"

# Complete project setup
setup: install db-setup setup-hooks

# Install dependencies
install:
	bundle install

# Setup Git hooks
setup-hooks:
	chmod +x bin/setup-hooks
	./bin/setup-hooks

# Run linter
lint:
	bundle exec rubocop

# Run linter with auto-fix
lint-fix:
	bundle exec rubocop -a

# Database setup
db-setup: db-create db-migrate db-seed

# Create databases
db-create:
	rails db:create
	RAILS_ENV=test rails db:create

# Run migrations
db-migrate:
	rails db:migrate
	RAILS_ENV=test rails db:migrate

# Seed database
db-seed:
	rails db:seed

# Reset database with force disconnect
db-reset:
	rails db:drop:_unsafe db:create db:migrate db:seed
	RAILS_ENV=test rails db:drop:_unsafe db:create db:migrate

# Force disconnect all connections
db-disconnect:
	@if [ -z "$(username)" ]; then \
		echo "❌ Error: Username cannot be empty. Use 'make db-disconnect username=YourUsername'"; \
		exit 1; \
	else \
		psql -h localhost -U $(username) -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname IN ('test_tripla_development', 'test_tripla_test') AND pid <> pg_backend_pid();"; \
	fi

# Run tests
test:
	rspec

# Generate Swagger documentation
swagger:
	rails rswag:specs:swaggerize

# Start server
server:
	rails server

# Clean temporary files
clean:
	rails log:clear tmp:clear

# Create file migration
create-file-migration:
	@if [ -z "$(filename)" ]; then \
		echo "❌ Error: Migration file name cannot be empty. Use 'make create-file-migration filename=YourMigrationName'"; \
		exit 1; \
	else \
		rails generate migration $(filename); \
	fi
