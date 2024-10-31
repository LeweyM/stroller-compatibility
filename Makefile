# Default target
all: dev

setup-local-db:
	mkdir -p ~/postgres-data
	initdb -D ~/postgres-data

teardown-local-db:
	rm -rf ~/postgres-data

start-local-db:
	pg_ctl -D ~/postgres-data -l ~/postgres-data/server.log start

stop-local-db:
	pg_ctl -D ~/postgres-data stop

reset-local-db: teardown-local-db setup-local-db

# Run development environment targeting local database
local: start-local-db
	@echo "Starting development environment targeting local database..."
	@bin/dev

# Run development environment targeting production database
local-production:
	@echo "Starting development environment targeting production database..."
	@USE_PROD_DB="true" bin/dev

.PHONY: all local local-production setup-local-db teardown-local-db start-local-db stop-local-db reset-local-db
