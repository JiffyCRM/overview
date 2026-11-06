# Architecture

JiffyCRM is a microservice-based CRM. Each service lives in its own repository under the `JiffyCRM` organization and is cloned together by `scripts/clone-all.sh`.

## Layout

```
jiffy/
├── overview/        # this repo: orchestration, docs, docker-compose
├── ui/              # Next.js frontend
├── auth-service/    # (planned) authentication & authorization
├── contact-service/ # (planned) contacts & accounts
└── deal-service/    # (planned) deals & pipelines
```

## Communication

Services communicate over HTTP/REST (and, in the future, message queues). The `ui` service calls backend services through their exposed ports.

## Data

A shared PostgreSQL instance (defined in `docker-compose.yml`) backs the services. Each service owns its own schema/tables.

## Running

- Local: `make clone && make up` (or `docker compose up --build`).
- Dev: run individual services with their own tooling (see each repo's README).
