.PHONY: clone pull up down status help

# Default target folder (relative)
TARGET ?=

help:
	@echo "JiffyCRM Overview"
	@echo ""
	@echo "Usage:"
	@echo "  make clone [TARGET=path]   Clone/update all repos into TARGET (default: parent dir if in overview, else ./JiffyCRM)"
	@echo "  make pull  [TARGET=path]   Pull latest changes in TARGET (default: parent dir if in overview, else ./JiffyCRM)"
	@echo "  make status [TARGET=path]  Git status of all services"
	@echo "  make up                    Start all services with docker compose"
	@echo "  make down                  Stop all services"
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
	docker compose up --build

down:
	docker compose down
