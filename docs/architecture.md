# Architecture

JiffyCRM is a microservice-based CRM. Each service lives in its own repository under the `JiffyCRM` organization and is cloned together by `scripts/clone-all.sh`.

## Layout

```
jiffy/
├── overview/        # this repo: orchestration, docs, docker-compose
├── ui/              # Next.js frontend
├── identity-link/   # Go + gRPC identity mapping service
├── membership/      # Go + gRPC organizations, roles, permissions
├── auth-service/    # (planned) authentication & authorization
├── contact-service/ # (planned) contacts & accounts
└── deal-service/    # (planned) deals & pipelines
```

## Communication

- The `ui` service owns the Google/Microsoft OAuth flow and calls `identity-link` over gRPC from server-side code only.
- The `ui` server will call `membership` over gRPC at `membership:50052` for organization and role management, forwarding the session user as `x-user-id`.
- Other backend services call `membership` for `CheckPermission` / `CheckPermissions` and `identity-link` for identity resolution.
- The browser never calls `identity-link` or `membership` directly.
- Planned services will follow the same rule: service-to-service communication over APIs, never direct database access.

## Data

Each service owns its data:

- `ui` uses the shared `jiffycrm` PostgreSQL database (`postgres` container).
- `identity-link` has a dedicated `identity_link` database in its own `identity-postgres` container. It stores provider mappings and HMAC-hashed emails only.
- `membership` has a dedicated `membership` database in its own `membership-postgres` container. It stores organizations, memberships, roles, permissions, and invitation token/email hashes only.
- No service reads or writes another service's tables.

## Running

- Local: `make clone` then `make up` (or `docker compose up --build`).
- Set `IDENTITY_LINK_HMAC_SECRET` and `MEMBERSHIP_INVITATION_HMAC_SECRET` in the Infisical `jiffycrm` / `dev` environment before starting the stack. Both values must be at least 32 random bytes and must remain stable.
- On first start, the `identity-link-migrate` and `membership-migrate` one-shot services apply their schemas before the gRPC servers start.
- Dev: run individual services with their own tooling (see each repo's README).
