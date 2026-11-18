# All Microservices

This document is the service catalog for JiffyCRM. Each service lives in its own repository under the [JiffyCRM](https://github.com/JiffyCRM) organization and is cloned by `scripts/clone-all.sh`.

## Current services

| Service | Repository | Runtime | Local endpoint | Data ownership |
| --- | --- | --- | --- | --- |
| overview | [JiffyCRM/overview](https://github.com/JiffyCRM/overview) | Orchestration only | - | None |
| ui | [JiffyCRM/ui](https://github.com/JiffyCRM/ui) | Next.js 16 + Auth.js | http://localhost:3000 | No app database yet; encrypted JWT session cookies |
| identity-link | [JiffyCRM/identity-link](https://github.com/JiffyCRM/identity-link) | Go + gRPC + pgx | `localhost:50051` | Dedicated `identity_link` PostgreSQL database |
| membership | [JiffyCRM/membership](https://github.com/JiffyCRM/membership) | Go + gRPC + pgx | `localhost:50052` | Dedicated `membership` PostgreSQL database |

### overview

Meta repository. Contains the bootstrap and update scripts, service catalog, architecture docs, shared `docker-compose.yml`, and development tooling. It runs no application code and owns no data.

### ui

Next.js App Router frontend using shadcn/ui.

- Owns the Google and Microsoft Entra ID OAuth/OIDC flow through Auth.js.
- Calls `identity-link.GetOrCreate` from server-side code only.
- Stores the internal user ID in an encrypted JWT session cookie.
- Never exposes email, provider subject, or OAuth tokens to the browser session.
- Does not currently use a database or Auth.js adapter.
- Is linked to the shared Infisical `jiffycrm` / `dev` environment through `.infisical.yaml`.

### identity-link

Go gRPC service that owns the mapping from external provider identities to internal opaque user IDs.

- Providers are normalized external names such as `google` and `microsoft-entra-id`.
- Microsoft subjects are stored as `${tid}:${oid}` to avoid cross-tenant collisions.
- Emails are stored only as HMAC-SHA256 hashes; no plaintext email column exists.
- Uses a dedicated `identity_link` database and runtime role.
- Exposes its own README and complete documentation under `docs/`.
- Is linked to the shared Infisical `jiffycrm` / `dev` environment through `.infisical.yaml`.

### membership

Go gRPC service that owns organizations, memberships, Discord-style roles, role
hierarchy, effective permissions, and invitations.

- Uses a dedicated `membership` database and runtime role.
- Stores only `internal_id` values from identity-link; no plaintext email,
  name, or avatar.
- Invitations store an HMAC digest of the email using
  `MEMBERSHIP_INVITATION_HMAC_SECRET` and resolve existing users through
  `identity-link.FindByEmail`.
- Enforces role hierarchy and prevents granting permissions the actor does not
  hold.
- Exposes `CheckPermission`, `CheckPermissions`, and
  `GetEffectivePermissions` for other backend services.
- Is linked to the shared Infisical `jiffycrm` / `dev` environment through
  `.infisical.yaml`.

## Local infrastructure

These are development components in `docker-compose.yml`, not independently versioned services.

| Component | Image | Purpose | Local endpoint |
| --- | --- | --- | --- |
| postgres | `postgres:latest` | Existing UI/CRM database container (`jiffycrm`); not used by auth today | `localhost:5432` |
| identity-postgres | `postgres:16-alpine` | Dedicated identity-link database (`identity_link`) | Internal only |
| identity-link-migrate | Built from identity-link | One-shot identity-link migration job | - |
| membership-postgres | `postgres:16-alpine` | Dedicated membership database (`membership`) | Internal only |
| membership-migrate | Built from membership | One-shot membership migration job | - |
| adminer | `adminer:latest` | Optional database UI, enabled with `make db` | http://localhost:8080 |

All containers share the `jiffycrm-network` Compose network.

## Communication rules

- The browser talks only to the UI.
- The UI server calls `identity-link` over gRPC at `identity-link:50051` inside Compose, or `localhost:50051` locally.
- The UI server will call `membership` over gRPC at `membership:50052` inside Compose, or `localhost:50052` locally, and forwards the session user as `x-user-id`.
- Other backend services call `membership` for `CheckPermission` / `CheckPermissions` and `identity-link` for identity resolution.
- The browser never calls `identity-link` or `membership` directly.
- Services never read or write another service's database.

## Identity flow

```text
Browser -> UI OAuth callback (Google / Microsoft Entra ID)
        -> UI server-side gRPC GetOrCreate
        -> identity-link
        -> identity_link PostgreSQL
        -> internal user_id returned
        -> UI session cookie contains only user_id
```

## Dev secrets and tooling

- Shared dev secrets are managed in Infisical project `jiffycrm`, environment `dev`.
- Each repository that needs direct secret access contains an `.infisical.yaml` with the project ID only.
- `make up` runs Docker Compose through `infisical secrets-manager run --env=dev`.
- `make secrets-check` verifies the required values are available.
- `make db` starts Adminer; `make db-stop` stops it.
- See the [README](README.md) for the full Makefile command list and database UI credentials.

## Planned

| Service | Description |
| --- | --- |
| auth-service | Future extraction of authentication only if JiffyCRM needs per-customer SSO/SAML/SCIM, token issuance to other services, or centralized session revocation. Current Google/Microsoft OAuth remains in the UI. |
| contact-service | Contact and account management. |
| deal-service | Deals, pipelines, and opportunities. |

## Adding a service

1. Create the repository under the `JiffyCRM` organization.
2. Add it to `scripts/clone-all.sh`.
3. Add its Compose service, network, and dedicated database to `docker-compose.yml`.
4. Add its dev secrets to the Infisical `jiffycrm` project and commit an `.infisical.yaml` containing only the project ID.
5. Update this catalog with its runtime, local endpoint, and data ownership.
6. Update `docs/architecture.md` and the service README.
