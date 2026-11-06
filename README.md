# JiffyCRM

JiffyCRM is a microservice-based CRM. This `overview` repository is the single entry point for the whole project: it contains the bootstrap scripts, service catalog, and the shared `docker-compose.yml`.

## Prerequisites

- Git
- Bash (Git Bash on Windows, or WSL)
- Node.js 20+ (for the `ui` service)
- Docker + Docker Compose (optional, for containerized run)

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
./scripts/clone-all.sh /home/user/projects/jiffy
./scripts/clone-all.sh "C:/Users/Teracura/Projects/jiffy"
```

By default a `jiffy` folder is created relative to the current working directory.

## Update all services

```bash
# from the folder that contains the service repos (e.g. ./jiffy)
../overview/scripts/pull-all.sh
# or, from anywhere:
/path/to/overview/scripts/pull-all.sh /path/to/jiffy
```

## Run with Docker Compose

```bash
docker compose up --build
```

The UI will be available at http://localhost:3000.

## Run the UI locally

```bash
cd ui
npm install
npm run dev
```

## Services

See [ALL_MICRO_SERVICES.md](./ALL_MICRO_SERVICES.md) for the full list.
EOF