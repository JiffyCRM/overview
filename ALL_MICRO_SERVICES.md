# All Microservices

This document lists the repositories that make up JiffyCRM. Each service lives in its own repository under the [JiffyCRM](https://github.com/JiffyCRM) organization and is cloned by `scripts/clone-all.sh`.

## Current

| Service | Repository | Description |
| --- | --- | --- |
| overview | [JiffyCRM/overview](https://github.com/JiffyCRM/overview) | Meta/orchestration repository. Single entry point for bootstrapping, docs, and shared docker-compose. |
| ui | [JiffyCRM/ui](https://github.com/JiffyCRM/ui) | Frontend web application (Next.js + shadcn/ui). |

## Planned

| Service | Description |
| --- | --- |
| auth-service | Authentication and authorization (SSO, sessions, tokens). |
| contact-service | Contact and account management. |
| deal-service | Deals, pipelines, and opportunities. |

> Add a row here whenever a new service repository is created, and add the corresponding entry to `scripts/clone-all.sh` and `docker-compose.yml`.
