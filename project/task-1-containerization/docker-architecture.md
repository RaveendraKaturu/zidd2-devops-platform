# 🏗️ Docker Architecture — ZIDD 2.0

## Overview

ZIDD 2.0 is composed of multiple services that run as independent Docker
containers.

Docker Compose is used to orchestrate the complete local application stack.

---

# Application Containers

```text
                         User / Browser
                               │
                               ▼
                         Frontend / Nginx
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ▼                     ▼
              Auth Service          Chat Service
                    │                     │
                    ▼                ┌────┴────┐
                  MySQL             │         │
                                    ▼         ▼
                                 MongoDB    Redis
```

---

# Services

| Service | Container Image | Purpose | Port |
|---|---|---|---|
| `app` | `zidd2-devops-platform-app` | React frontend + Nginx | `3000 → 80` |
| `auth-service` | `zidd2-devops-platform-auth-service` | Authentication | `8005` |
| `chat-service` | `zidd2-devops-platform-chat-service` | Real-time chat | `8010` |
| `mysqldb` | `mysql:8.0.32` | Authentication database | `3306` |
| `mongodb` | `mongo` | Chat message database | `27017` |
| `redisdb` | `redis` | Caching | `6379` |

The backend service ports are not directly exposed to the host in the current
Docker Compose configuration. They communicate through the Docker network.

---

# 🌐 Docker Network

All application services communicate through:

```text
springboot-network
```

The logical communication structure is:

```text
springboot-network
│
├── app
├── auth-service
├── chat-service
├── mysqldb
├── mongodb
└── redisdb
```

Docker service names are used for internal communication.

Examples:

```text
auth-service → mysqldb:3306

chat-service → mongodb:27017

chat-service → redisdb:6379
```

---

# 🔐 Auth Service Architecture

```text
                Auth Service
                     │
                     ▼
             Spring Boot App
                     │
                     ▼
                  MySQL
```

The Auth Service is responsible for:

- User registration
- User authentication
- JWT generation
- User information

The application runs on port:

```text
8005
```

---

# 💬 Chat Service Architecture

```text
                 Chat Service
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
          MongoDB            Redis
             │                 │
       Message Storage       Cache
```

The Chat Service handles:

- Chat messages
- Message persistence
- WebSocket communication
- STOMP communication
- User-related cached data

The application runs on:

```text
8010
```

---

# ⚛️ Frontend Architecture

The frontend follows a build-time/runtime separation.

```text
React Source
     │
     ▼
Bun Builder
     │
     │ bun run build
     ▼
   dist/
     │
     ▼
Nginx Alpine
     │
     ▼
Browser
```

The runtime container contains the generated frontend files and Nginx rather
than the complete frontend build environment.

---

# 🔨 Multi-Stage Build Architecture

Backend services:

```text
┌─────────────────────────────┐
│       Builder Stage         │
│                             │
│ Maven + JDK 17              │
│ Source Code                 │
│ Dependencies                │
│                             │
│ mvn clean package           │
└──────────────┬──────────────┘
               │
               │ JAR
               ▼
┌─────────────────────────────┐
│       Runtime Stage         │
│                             │
│ Eclipse Temurin JRE 17      │
│ Alpine Linux                │
│ Application JAR             │
│ Non-root user               │
└─────────────────────────────┘
```

Frontend:

```text
┌─────────────────────────────┐
│       Builder Stage         │
│                             │
│ Bun Alpine                  │
│ React dependencies          │
│ Source Code                 │
│                             │
│ bun run build               │
└──────────────┬──────────────┘
               │
               │ dist/
               ▼
┌─────────────────────────────┐
│       Runtime Stage         │
│                             │
│ Nginx Alpine                │
│ Static React files          │
└─────────────────────────────┘
```

---

# ❤️ Health-Check Dependency Flow

Docker Compose uses health checks to control service startup dependencies.

```text
                    MySQL
                      │
                  HEALTHY
                      │
                      ▼
                Auth Service


                  MongoDB
                     │
                 HEALTHY
                     │
                     ├──────────┐
                     │          │
                     ▼          │
                  Chat Service ◄┘
                     ▲
                     │
                   Redis
                     │
                  HEALTHY
```

This ensures backend services wait for their required dependencies to become
healthy before startup.

---

# 🔒 Runtime Security

The Spring Boot services run using a dedicated non-root user:

```text
appuser
```

The user belongs to:

```text
appgroup
```

The runtime container therefore does not execute the application process as
the Docker `root` user.

---

# 📌 Architecture Summary

The container architecture provides:

- Service isolation
- Separate application responsibilities
- Independent runtime environments
- Internal Docker networking
- Health-based service dependencies
- Multi-stage builds
- Reduced runtime dependencies
- Non-root backend execution
