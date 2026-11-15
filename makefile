.PHONY: clone pull up down logs ps db db-stop status help secrets-check

# Default target folder (relative)
TARGET ?=

DC := infisical secrets-manager run --env=dev -- docker compose

help:
	@echo "JiffyCRM Overview"
	@echo ""
	@echo "Usage:"
	@echo "  make clone [TARGET=path]   Clone/update all repos into TARGET (default: parent dir if in overview, else ./JiffyCRM)"
	@echo "  make pull  [TARGET=path]   Pull latest changes in TARGET (default: parent dir if in overview, else ./JiffyCRM)"
	@echo "  make status [TARGET=path]  Git status of all services"
	@echo "  make up                    Start all services with Infisical dev secrets + docker compose"
	@echo "  make secrets-check         Verify the required Infisical secrets are available"
	@echo "  make down                  Stop all services"
	@echo "  make logs                  Follow service logs"
	@echo "  make ps                    Show service status"
	@echo "  make db                    Start the Adminer database UI on http://localhost:8080"
	@echo "  make db-stop               Stop the Adminer database UI"
	@echo ""
	@echo "Examples:"
	@echo "  make clone"
	@echo "  make clone TARGET=/home/user/projects/JiffyCRM"
	@echo "  make clone TARGET=\"C:/Users/Teracura/Projects/JiffyCRM\""
	@echo "  make pull TARGET=./JiffyCRM"

clone:
	@./scripts/clone-all.sh "$(TARGET)"

pull:
	@./scripts/pull-all.sh "$(TARGET)"

status:
	@./scripts/status.sh "$(TARGET)"

up:
	@command -v infisical >/dev/null 2>&1 || { echo "infisical CLI is required; see README"; exit 1; }
	$(DC) up --build

secrets-check:
	infisical secrets-manager run --env=dev -- bash -c 'test -n "$$AUTH_SECRET" && test -n "$$IDENTITY_LINK_HMAC_SECRET" && echo "Infisical secrets OK"'

down:
	$(DC) --profile tools down

logs:
	$(DC) logs -f

ps:
	$(DC) ps

db:
	$(DC) --profile tools up -d adminer
	@echo "Adminer: http://localhost:8080"

db-stop:
	$(DC) --profile tools stop adminer
