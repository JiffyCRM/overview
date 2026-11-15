# Architecture

JiffyCRM is a microservice-based CRM. Each service lives in its own repository under the `JiffyCRM` organization and is cloned together by `scripts/clone-all.sh`.

## Layout

```
jiffy/
├── overview/        # this repo: orchestration, docs, docker-compose
├── ui/              # Next.js frontend
├── identity-link/   # Go + gRPC identity mapping service
├── auth-service/    # (planned) authentication & authorization
├── contact-service/ # (planned) contacts & accounts
└── deal-service/    # (planned) deals & pipelines
```

## Communication

- The `ui` service calls backend HTTP/REST services through their exposed ports.
- `identity-link` exposes gRPC on port `50051`. Backend services call it to resolve provider identities, create users, and check emails. The browser does not call it directly.
- Planned services will follow the same rule: service-to-service communication over APIs, never direct database access.

## Data

Each service owns its data:

- `ui` uses the shared `jiffycrm` PostgreSQL database (`postgres` container).
- `identity-link` has a dedicated `identity_link` database in its own `identity-postgres` container. It stores provider mappings and HMAC-hashed emails only.
- No service reads or writes another service's tables.

## Running

- Local: `make clone` then `make up` (or `docker compose up --build`).
- Create an `overview/.env` file with `IDENTITY_LINK_HMAC_SECRET` before starting the stack. The value must be at least 32 random bytes and must remain stable.
- On first start, the `identity-link-migrate` one-shot service applies the identity-link schema before the gRPC server starts.
- Dev: run individual services with their own tooling (see each repo's README).
