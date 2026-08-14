# 📦 Docker Image Optimization

## Objective

The original application used Maven-based runtime images for the Spring Boot
services.

This resulted in large production images because the runtime container also
contained the Maven build environment and JDK.

The objective was to separate the build environment from the runtime
environment and reduce unnecessary components from the final images.

---

# 🔴 Original Backend Architecture

The original backend Dockerfiles used Maven for both stages.

Conceptually:

```text
Maven Image
     │
     ├── Maven
     ├── JDK
     ├── Build Tools
     ├── Source Code
     └── Application JAR
```

The same large Maven image was used as the runtime environment.

---

# 🟢 Optimized Backend Architecture

The optimized implementation separates build and runtime.

```text
Maven + JDK 17
      │
      │ Build
      ▼
Application JAR
      │
      ▼
Eclipse Temurin 17 JRE Alpine
      │
      ▼
Minimal Runtime
```

---

# 📊 Image Size Comparison

| Service | Original Size | Optimized Size | Approx. Reduction |
|---|---:|---:|---:|
| Auth Service | ~835 MB | ~285 MB | ~66% |
| Chat Service | ~821 MB | ~257 MB | ~69% |

The image sizes were measured using:

```bash
docker images
```

---

# 🔐 Why the Images Became Smaller

The main optimization came from removing build-time dependencies from the
runtime image.

The runtime image no longer requires:

- Maven
- Java compiler
- Build dependencies
- Application source code
- Maven cache

Only the generated Spring Boot JAR is copied into the runtime image.

---

# 🧱 Auth Service

### Builder

```dockerfile
FROM maven:3.8.3-openjdk-17 AS builder
```

The application is packaged using:

```bash
mvn clean package -DskipTests
```

### Runtime

```dockerfile
FROM eclipse-temurin:17-jre-alpine
```

Only the generated JAR is copied:

```dockerfile
COPY --from=builder /app/target/auth-api-0.0.1-SNAPSHOT.jar app.jar
```

---

# 🧱 Chat Service

The Chat Service follows the same pattern.

### Builder

```dockerfile
FROM maven:3.8.3-openjdk-17 AS builder
```

### Runtime

```dockerfile
FROM eclipse-temurin:17-jre-alpine
```

Only the application JAR is copied into the runtime image.

---

# ⚛️ Frontend Build Optimization

The frontend uses a multi-stage build.

```text
Bun Alpine
    │
    ▼
Install Dependencies
    │
    ▼
React Build
    │
    ▼
dist/
    │
    ▼
Nginx Alpine
```

Builder:

```dockerfile
FROM oven/bun:1-alpine AS builder
```

Runtime:

```dockerfile
FROM nginx:1.27-alpine
```

The final runtime container contains the generated static frontend files and
Nginx.

---

# ⚠️ Frontend Image Size Observation

The previous local frontend image was approximately:

```text
21.7 MB
```

The current optimized multi-stage frontend image is approximately:

```text
48.7 MB
```

Therefore, the frontend image size increased.

This is not considered an image-size reduction.

The improvement here is primarily architectural:

- Build/runtime separation
- Alpine-based runtime
- Build dependencies excluded from runtime
- Static files served by Nginx

Further image-size optimization can be evaluated separately.

---

# 🚫 Build Context Optimization

`.dockerignore` files were added to avoid sending unnecessary files into the
Docker build context.

Examples:

```text
.git
.gitignore
.idea
.vscode
*.log
.env
```

For the frontend:

```text
node_modules
dist
```

This reduces unnecessary build context and prevents local/generated files from
being copied into the build process.

---

# 🧪 Validation

After changing the Dockerfiles, the images were rebuilt:

```bash
docker compose build
```

The application was started:

```bash
docker compose up -d
```

Image sizes were verified:

```bash
docker images | grep zidd2-devops-platform
```

The resulting images were:

```text
zidd2-devops-platform-auth-service    ~285 MB
zidd2-devops-platform-chat-service    ~257 MB
zidd2-devops-platform-app              ~48.7 MB
```

---

# ✅ Result

The backend image optimization successfully reduced the image footprint by
hundreds of megabytes.

The major improvement was achieved through:

1. Multi-stage Docker builds
2. JRE-based runtime images
3. Alpine-based runtime environment
4. Removal of Maven from runtime
5. Copying only the generated application JAR
6. `.dockerignore` implementation

This makes the backend containers more suitable for deployment to a container
registry and cloud environment.
