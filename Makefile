# Quality-of-life shortcuts for the JiffyCRM meta-repo.

.PHONY: clone pull up down status

clone:
	./scripts/clone-all.sh

pull:
	./scripts/pull-all.sh

up:
	docker compose up --build

down:
	docker compose down

status:
	./scripts/status.sh
