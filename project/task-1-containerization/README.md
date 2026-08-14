# 🐳 Task 1 — Containerization

## 📌 Objective

The objective of Task 1 is to containerize the complete **ZIDD 2.0 application** using production-oriented Docker practices.

The application consists of multiple components including:

- React frontend
- Spring Boot Auth Service
- Spring Boot Chat Service
- MySQL
- MongoDB
- Redis
- Nginx

The containerization implementation focuses on reducing image size, separating build and runtime environments, running application containers with restricted privileges, improving build efficiency, and validating the complete application using Docker Compose.

---

# 🎯 Task Requirements

The original task required the following:

- Use appropriate and lightweight base images
- Follow Docker security best practices
- Use multi-stage builds wherever applicable
- Keep Docker images lightweight and optimized
- Configure users and permissions securely
- Follow other relevant production-grade Docker practices

---

# 🏗️ Container Architecture

The complete application runs as multiple containers connected through a Docker network.

```text
                         User / Browser
                               │
                               ▼
                     ┌──────────────────┐
                     │  Frontend/Nginx  │
                     │     Port 3000    │
                     └────────┬─────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
        ┌─────────────────┐       ┌─────────────────┐
        │  Auth Service   │       │  Chat Service   │
        │    Port 8005    │       │    Port 8010    │
        └────────┬────────┘       └────────┬────────┘
                 │                         │
                 ▼                  ┌──────┴──────┐
              MySQL                 │             │
                                    ▼             ▼
                                 MongoDB        Redis
```

Docker Compose is used to build, start, connect and manage these containers.

---

# 📦 Containerized Services

| Component | Technology | Container Role |
|---|---|---|
| Frontend | React + Nginx | Serves the web application |
| Auth Service | Spring Boot | Authentication and user management |
| Chat Service | Spring Boot | Chat and WebSocket communication |
| MySQL | MySQL 8 | Authentication database |
| MongoDB | MongoDB | Message persistence |
| Redis | Redis | Caching and chat-related temporary data |

All services communicate through the Docker network:

```text
springboot-network
```

---

# 🔨 Multi-Stage Build Strategy

Multi-stage Docker builds were implemented for the application services.

The main goal was to separate the **build environment** from the **runtime environment**.

This prevents unnecessary build tools such as Maven, compilers and source files from being included in the final backend images.

---

## 🔐 Auth Service

The Auth Service originally used a Maven image for both the build and runtime stages.

The optimized Dockerfile uses:

```text
Build Stage
     │
     ▼
Maven + JDK 17
     │
     │ mvn clean package
     ▼
Spring Boot JAR
     │
     ▼
Runtime Stage
     │
     ▼
Eclipse Temurin JRE 17 Alpine
     │
     ▼
Non-root Application User
     │
     ▼
Auth Service
```

### Build Image

```dockerfile
FROM maven:3.8.3-openjdk-17 AS builder
```

The source code is compiled and packaged during this stage.

### Runtime Image

```dockerfile
FROM eclipse-temurin:17-jre-alpine
```

Only the generated application JAR is copied into the runtime image.

This removes Maven and other build-time dependencies from the final image.

---

# 💬 Chat Service

The Chat Service follows the same multi-stage strategy.

```text
Maven Builder
      │
      ▼
Compile Application
      │
      ▼
Generate JAR
      │
      ▼
Temurin JRE Alpine
      │
      ▼
Non-root Runtime
      │
      ▼
Chat Service
```

The final container therefore contains only the components required to run the Spring Boot application.

---

# ⚛️ Frontend Containerization

The React frontend also uses a multi-stage Docker build.

```text
Bun Builder
     │
     ▼
Install Dependencies
     │
     ▼
Build React Application
     │
     ▼
Static dist Files
     │
     ▼
Nginx Alpine
     │
     ▼
Serve Application
```

The build stage uses:

```dockerfile
FROM oven/bun:1-alpine AS builder
```

The runtime stage uses:

```dockerfile
FROM nginx:1.27-alpine
```

Only the generated frontend build is copied into the final Nginx image.

This ensures that frontend source code and build tooling are not required in the runtime container.

---

# 🔐 Container Security Practices

Several Docker security practices were implemented during containerization.

## 1. Non-Root Backend Containers

The Auth and Chat services create a dedicated application user.

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
```

Application ownership is assigned to this user:

```dockerfile
RUN chown -R appuser:appgroup /app
```

The container then switches from the default root user:

```dockerfile
USER appuser
```

This reduces the privileges available to the application process inside the container.

---

## 2. Minimal Runtime Images

The backend runtime was changed from a full Maven environment to:

```text
eclipse-temurin:17-jre-alpine
```

The runtime container therefore does not require:

- Maven
- Java compiler
- Source code
- Build dependencies

This reduces both image size and unnecessary runtime components.

---

## 3. Build and Runtime Separation

Build tools exist only in the builder stage.

```text
Builder Image
   │
   ├── Maven
   ├── JDK
   ├── Source Code
   └── Build Dependencies
          │
          ▼
       JAR File
          │
          ▼
Runtime Image
   │
   ├── JRE
   └── Application JAR
```

This follows the principle of keeping production containers focused only on runtime requirements.

---

# 🚫 `.dockerignore` Implementation

Separate `.dockerignore` files were added to reduce unnecessary Docker build context.

## Backend Services

The Auth and Chat services exclude files such as:

```text
target
.git
.gitignore
.idea
.vscode
*.log
.env
README.md
```

## Frontend

The frontend excludes:

```text
node_modules
dist
.git
.gitignore
.idea
.vscode
*.log
.env
```

This prevents unnecessary files from being sent to the Docker daemon during image builds.

---

# ❤️ Container Health Checks

Health checks are configured through Docker Compose.

They allow Docker to determine whether important application components are actually operational rather than simply checking whether the process is running.

The environment includes health checks for:

- MySQL
- MongoDB
- Redis
- Auth Service
- Chat Service

Service dependencies use health status before dependent services are started.

For example:

```text
MySQL Healthy
     │
     ▼
Auth Service

MongoDB Healthy ──┐
                  ├──► Chat Service
Redis Healthy ────┘
```

This improves startup reliability because backend services wait for their dependencies.

---

# 🐳 Docker Compose Orchestration

The complete application is managed using Docker Compose.

The major services are:

```text
mysqldb
mongodb
redisdb
auth-service
chat-service
app
```

All services are connected through:

```text
springboot-network
```

The complete environment can be built using:

```bash
docker compose build
```

and started using:

```bash
docker compose up -d
```

Container status can be verified using:

```bash
docker compose ps
```

---

# 📊 Docker Image Optimization

One of the major improvements during Task 1 was reducing the backend Docker image sizes.

## Before Optimization

The original images were approximately:

| Image | Size |
|---|---:|
| Auth Service | 835 MB |
| Chat Service | 821 MB |
| Frontend | 21.7 MB |

The backend runtime images contained the complete Maven environment.

---

## After Optimization

After implementing multi-stage builds and JRE-based runtime images:

| Image | Optimized Size |
|---|---:|
| Auth Service | ~285 MB |
| Chat Service | ~257 MB |
| Frontend | ~48.7 MB |

### Backend Reduction

Auth Service:

```text
835 MB
  ↓
285 MB
```

Approximate reduction:

```text
~66%
```

Chat Service:

```text
821 MB
  ↓
257 MB
```

Approximate reduction:

```text
~69%
```

The backend optimization removed hundreds of megabytes of unnecessary build tooling from the runtime images.

> The frontend image increased compared with the earlier local image. Therefore, it should not be presented as an image-size optimization result. Its current implementation is documented as a multi-stage production build using Bun and Nginx Alpine.

---

# 🔍 Container Vulnerability Scanning

Container images were also evaluated using **Trivy**.

Trivy is a vulnerability and misconfiguration scanner commonly used for container security.

It can inspect container images for known vulnerabilities affecting:

- Operating system packages
- Java dependencies
- Application libraries
- Nginx packages
- Other installed dependencies

Example scan:

```bash
trivy image zidd2-devops-platform-auth-service:latest
```

Chat Service:

```bash
trivy image zidd2-devops-platform-chat-service:latest
```

Frontend:

```bash
trivy image zidd2-devops-platform-app:latest
```

The scan provides severity-based findings such as:

```text
UNKNOWN
LOW
MEDIUM
HIGH
CRITICAL
```

Trivy scanning provides a security baseline for identifying packages that may require upgrades or remediation.

Detailed scan evidence can be maintained under:

```text
project/task-1-containerization/evidence/
```

---

# 🧪 Build and Runtime Validation

After optimizing the Dockerfiles, the application was rebuilt and tested locally.

Build:

```bash
docker compose build
```

Start:

```bash
docker compose up -d
```

Verification:

```bash
docker compose ps
```

The resulting environment successfully started:

```text
Frontend        → Running
Auth Service    → Healthy
Chat Service    → Healthy
MySQL           → Healthy
MongoDB         → Healthy
Redis           → Healthy
```

The frontend application was also tested locally and confirmed to be functioning correctly.

---

# 📈 Final Containerization Flow

```text
                     Source Code
                         │
                         ▼
                  Docker Build Context
                         │
                    .dockerignore
                         │
                         ▼
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
       Backend Builder         Frontend Builder
        Maven + JDK                  Bun
             │                       │
             ▼                       ▼
        Spring Boot JAR         React dist/
             │                       │
             ▼                       ▼
       JRE Alpine Runtime       Nginx Alpine
             │                       │
        Non-root User                 │
             │                       │
             └───────────┬───────────┘
                         ▼
                   Docker Images
                         │
                         ▼
                    Trivy Scan
                         │
                         ▼
                  Docker Compose
                         │
                         ▼
              Complete Application
                         │
                         ▼
                   Health Checks
                         │
                         ▼
                    VALIDATED
```

---

# 🛡️ Production Practices Implemented

| Practice | Status |
|---|:---:|
| Multi-stage backend builds | ✅ |
| Multi-stage frontend build | ✅ |
| Lightweight backend runtime | ✅ |
| Alpine-based runtime images | ✅ |
| Non-root backend execution | ✅ |
| `.dockerignore` | ✅ |
| Docker health checks | ✅ |
| Service dependency health checks | ✅ |
| Docker network isolation | ✅ |
| Docker Compose orchestration | ✅ |
| Container vulnerability scanning | ✅ |
| Backend image optimization | ✅ |

---

# ⚠️ Current Limitations

Task 1 establishes a strong containerization baseline, but further production hardening can still be implemented.

Potential improvements include:

- Dependency vulnerability remediation
- Pinning images by immutable digest
- Read-only container filesystems where possible
- Runtime CPU and memory limits
- Improved secrets management
- Container image signing
- SBOM generation
- Registry-side vulnerability scanning
- Automated security gates in CI/CD

These improvements can be integrated progressively with the later security and CI/CD tasks.

---

# 📁 Related Files

```text
auth-service/
├── Dockerfile
└── .dockerignore

chat-service/
├── Dockerfile
└── .dockerignore

chat-app-client/
├── Dockerfile
└── .dockerignore

docker-compose.yml

project/task-1-containerization/
├── README.md
├── docker-architecture.md
├── image-optimization.md
├── security-scanning.md
└── evidence/
```

---

# ✅ Task 1 Status

## Containerization — Completed

The complete ZIDD 2.0 application has been successfully containerized and validated locally using Docker Compose.

Key outcomes include:

- Production-oriented multi-stage Docker builds
- Lightweight JRE runtime images for Spring Boot services
- Non-root backend containers
- Optimized backend image sizes
- Reduced Docker build context using `.dockerignore`
- Dependency-aware container startup using health checks
- Successful local execution of the complete application stack
- Container vulnerability assessment using Trivy

The containerized application now provides the foundation for the next stage of the project:

**Task 2 — Deployment**
