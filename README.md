# JiffyCRM

JiffyCRM is a microservice-based CRM. This `overview` repository is the single entry point for the whole project: it contains the bootstrap scripts, service catalog, and the shared `docker-compose.yml`.

## Prerequisites

- Git
- Bash (Git Bash on Windows, or WSL)
- Node.js 20+ (for the `ui` service)
- Docker + Docker Compose (for the containerized stack)
- [Infisical CLI](https://infisical.com/docs/cli/overview) for dev secrets

## Clone everything

### Linux / macOS

```bash
git clone https://github.com/JiffyCRM/overview.git
cd overview
./scripts/clone-all.sh
```

### Windows (Git Bash)

```bash
git clone https://github.com/JiffyCRM/overview.git
cd overview
bash scripts/clone-all.sh
```

### Windows (WSL)

Same as Linux, run inside your WSL shell.

### Custom location

```bash
./scripts/clone-all.sh /home/user/projects/JiffyCRM
./scripts/clone-all.sh "C:/Users/Teracura/Projects/JiffyCRM"
```

By default a `JiffyCRM` folder is created relative to the current working directory.
When run from inside an `overview` checkout, the parent directory is used instead so service repos become siblings of `overview`.

## Update all services

```bash
# from the folder that contains the service repos (e.g. ./JiffyCRM)
../overview/scripts/pull-all.sh
# or, from anywhere:
/path/to/overview/scripts/pull-all.sh /path/to/JiffyCRM
```

## Run with Docker Compose

> **Permissions:** On Linux, Docker requires root access unless your user is in the `docker` group. Use `sudo make up` / `sudo make down` (or `sudo docker compose up --build` / `sudo docker compose down`). On macOS, Docker Desktop runs as your user, so `make up` works without sudo. On Windows, run the terminal as Administrator or ensure Docker Desktop is running; `make up` usually works without sudo.

Dev secrets are managed in Infisical, not in `.env` files.

```bash
infisical login
infisical init   # first time only; select the jiffycrm project
make secrets-check
```

Then start the stack:

```bash
make up
```

`make up` runs `docker compose` through `infisical secrets-manager run --env=dev`, so provider credentials and application secrets are injected at runtime.

The UI will be available at http://localhost:3000 (sign-in at `/login`), and identity-link gRPC at `localhost:50051`. The identity-link migration job runs automatically before the service starts. Its database is a dedicated `identity-link-postgres` container; it has no host port and is only reachable on the Compose network.

OAuth redirect URIs:

- Google: `http://localhost:3000/api/auth/callback/google`
- Microsoft Entra ID: `http://localhost:3000/api/auth/callback/microsoft-entra-id`

See the [UI README](https://github.com/JiffyCRM/ui#readme) for provider registration, the Microsoft `email` optional claim, and security notes.

Never commit secrets. Keep `IDENTITY_LINK_HMAC_SECRET` and `AUTH_SECRET` stable: changing the identity-link secret invalidates existing email hash lookups, and changing `AUTH_SECRET` invalidates sessions. See the [identity-link security documentation](https://github.com/JiffyCRM/identity-link/blob/main/docs/security.md).

## Run the UI locally

The UI needs identity-link, Infisical dev secrets, and at least one OAuth provider configured. See the [UI README](https://github.com/JiffyCRM/ui#readme).

```bash
cd ui
npm install
infisical secrets-manager run --env=dev -- npm run dev
```

## Run identity-link locally

See the [identity-link README](https://github.com/JiffyCRM/identity-link#readme). It can run outside Compose with its own Postgres container, migrations, and gRPC server.

## Architecture

See [docs/architecture.md](./docs/architecture.md) for the microservice layout and data flow.

## Quick commands (Makefile)

```bash
make clone   # clone/update all services
make pull    # pull latest in all services
make up      # Infisical dev secrets + docker compose up --build
make secrets-check  # verify required Infisical secrets
make down    # stop all services
make logs    # follow service logs
make ps      # show service status
make db      # start Adminer database UI on http://localhost:8080
make db-stop # stop the Adminer database UI
make status  # git status of all services
```

## Database UI

Start Adminer:

```bash
make db
```

Open http://localhost:8080.

Identity-link database:

| Field | Value |
| --- | --- |
| System | PostgreSQL |
| Server | `identity-postgres` |
| Username | `identity_link` |
| Password | `identity_link` |
| Database | `identity_link` |

UI database:

| Field | Value |
| --- | --- |
| System | PostgreSQL |
| Server | `postgres` |
| Username | `jiffy` |
| Password | `jiffy` |
| Database | `jiffycrm` |

Adminer only binds to `127.0.0.1:8080`. These credentials are local development defaults; do not expose Adminer or reuse them in production.

Stop Adminer with:

```bash
make db-stop
```

## Services

See [ALL_MICRO_SERVICES.md](./ALL_MICRO_SERVICES.md) for the full list. Current services: `ui` (Next.js) and `identity-link` (Go + gRPC).
