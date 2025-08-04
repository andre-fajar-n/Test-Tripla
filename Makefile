.PHONY: help setup install db-setup db-create db-migrate db-seed db-reset test test-health swagger server clean

# Default target
help:
	@echo "Available commands:"
	@echo "  setup       - Complete project setup (install + db-setup)"
	@echo "  install     - Install dependencies"
	@echo "  db-setup    - Setup database (create + migrate + seed)"
	@echo "  db-create   - Create databases"
	@echo "  db-migrate  - Run database migrations"
	@echo "  db-seed     - Seed database with sample data"
	@echo "  db-reset    - Reset database (drop + create + migrate + seed)"
	@echo "  test        - Run all tests"
	@echo "  test-health - Run health API tests"
	@echo "  swagger     - Generate Swagger documentation"
	@echo "  server      - Start Rails server"
	@echo "  clean       - Clean temporary files"

# Complete project setup
setup: install db-setup

# Install dependencies
install:
	bundle install

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

# Reset database
db-reset:
	rails db:drop db:create db:migrate db:seed
	RAILS_ENV=test rails db:drop db:create db:migrate

# Run tests
test:
	rspec

# Run health API tests
test-health:
	rspec spec/requests/api/v1/health_spec.rb

# Generate Swagger documentation
swagger:
	rails rswag:specs:swaggerize

# Start server
server:
	rails server

# Clean temporary files
clean:
	rails log:clear tmp:clear
