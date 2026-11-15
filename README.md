# JiffyCRM

JiffyCRM is a microservice-based CRM. This `overview` repository is the single entry point for the whole project: it contains the bootstrap scripts, service catalog, and the shared `docker-compose.yml`.

## Prerequisites

- Git
- Bash (Git Bash on Windows, or WSL)
- Node.js 20+ (for the `ui` service)
- Docker + Docker Compose (for the containerized stack)
- `openssl` (optional, to generate the identity-link HMAC secret)

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

Create an ignored `.env` file with a random identity-link HMAC secret (at least 32 bytes):

```bash
echo "IDENTITY_LINK_HMAC_SECRET=$(openssl rand -base64 48)" > .env
```

Then start the stack:

```bash
docker compose up --build
```

The UI will be available at http://localhost:3000 and identity-link gRPC at `localhost:50051`. The identity-link migration job runs automatically before the service starts. Its database is a dedicated `identity-link-postgres` container; it has no host port and is only reachable on the Compose network.

Never commit `.env`. The identity-link secret must remain stable: changing it invalidates existing email hash lookups. See the [identity-link security documentation](https://github.com/JiffyCRM/identity-link/blob/main/docs/security.md).

## Run the UI locally

```bash
cd ui
npm install
npm run dev
```

## Run identity-link locally

See the [identity-link README](https://github.com/JiffyCRM/identity-link#readme). It can run outside Compose with its own Postgres container, migrations, and gRPC server.

## Architecture

See [docs/architecture.md](./docs/architecture.md) for the microservice layout and data flow.

## Quick commands (Makefile)

```bash
make clone   # clone/update all services
make pull    # pull latest in all services
make up      # docker compose up --build
make down    # docker compose down
make status  # git status of all services
```

## Services

See [ALL_MICRO_SERVICES.md](./ALL_MICRO_SERVICES.md) for the full list. Current services: `ui` (Next.js) and `identity-link` (Go + gRPC).
