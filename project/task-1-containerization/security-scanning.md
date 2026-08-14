# 🔍 Container Security Scanning

## Objective

Container security scanning is performed to identify known vulnerabilities
present in the operating system packages and application dependencies inside
the Docker images.

Trivy is used as the container vulnerability scanner.

---

# 🛡️ Why Trivy?

Trivy can scan container images for known vulnerabilities.

It can identify vulnerabilities in:

- Operating system packages
- Application dependencies
- Java dependencies
- Nginx packages
- Other installed components

The scanner categorizes findings according to severity.

```text
UNKNOWN
LOW
MEDIUM
HIGH
CRITICAL
```

---

# 🔎 Images Scanned

The following project images are intended to be scanned:

```text
zidd2-devops-platform-auth-service:latest
zidd2-devops-platform-chat-service:latest
zidd2-devops-platform-app:latest
```

---

# 🧪 Scan Commands

## Auth Service

```bash
trivy image zidd2-devops-platform-auth-service:latest
```

## Chat Service

```bash
trivy image zidd2-devops-platform-chat-service:latest
```

## Frontend

```bash
trivy image zidd2-devops-platform-app:latest
```

---

# 📊 Scan Output

A Trivy scan generally provides information such as:

```text
Target
Type
Vulnerability ID
Package
Installed Version
Fixed Version
Severity
```

Example structure:

```text
Library / Package
       │
       ▼
CVE / Vulnerability ID
       │
       ▼
Installed Version
       │
       ▼
Fixed Version
       │
       ▼
Severity
```

The actual vulnerability counts and CVE identifiers should be recorded from
the scan performed against the current image versions.

---

# 🚦 Security Severity

The severity of findings is categorized as:

| Severity | Meaning |
|---|---|
| CRITICAL | Extremely serious vulnerability requiring immediate attention |
| HIGH | Serious vulnerability requiring prioritized remediation |
| MEDIUM | Moderate security risk |
| LOW | Lower-impact vulnerability |
| UNKNOWN | Severity could not be determined |

---

# 🔐 Docker Security Practices

Containerization also includes several security practices independent of
vulnerability scanning.

## Non-Root User

The backend services run as:

```text
appuser
```

instead of the default root user.

Dockerfile configuration:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser
```

---

## Minimal Runtime Environment

The backend runtime uses:

```text
eclipse-temurin:17-jre-alpine
```

instead of the Maven build image.

This reduces the number of unnecessary tools available inside the runtime
container.

---

## Build Context Restrictions

`.dockerignore` prevents unnecessary files from entering the Docker build
context.

Examples:

```text
.git
.env
*.log
.idea
.vscode
```

The frontend additionally excludes:

```text
node_modules
dist
```

---

# 🔄 Vulnerability Remediation Process

A vulnerability identified by Trivy should follow this process:

```text
Trivy Scan
    │
    ▼
Identify Vulnerability
    │
    ▼
Determine Affected Package
    │
    ▼
Check Fixed Version
    │
    ▼
Update Base Image / Dependency
    │
    ▼
Rebuild Image
    │
    ▼
Run Application Tests
    │
    ▼
Run Trivy Again
    │
    ▼
Verify Remediation
```

The objective is not simply to achieve a zero-vulnerability report by ignoring
findings, but to understand the affected package and safely remediate
vulnerabilities without breaking application functionality.

---

# 📁 Evidence

Actual scan outputs should be stored under:

```text
project/task-1-containerization/evidence/
```

Recommended files:

```text
evidence/
├── trivy-auth.txt
├── trivy-chat.txt
└── trivy-frontend.txt
```

Example:

```bash
trivy image zidd2-devops-platform-auth-service:latest \
  > evidence/trivy-auth.txt
```

```bash
trivy image zidd2-devops-platform-chat-service:latest \
  > evidence/trivy-chat.txt
```

```bash
trivy image zidd2-devops-platform-app:latest \
  > evidence/trivy-frontend.txt
```

---

# ⚠️ Important

A vulnerability scan is only one part of container security.

Additional security practices can be implemented in later project tasks:

- Image signing
- SBOM generation
- Registry vulnerability scanning
- CI/CD security gates
- Secrets management
- Runtime security
- IAM hardening
- Network security

These areas will be covered further under the project's Security and CI/CD
tasks.

---

# ✅ Task 1 Security Status

Container security baseline:

**Implemented**

Current implementation includes:

- Non-root backend containers
- Minimal runtime images
- Multi-stage builds
- `.dockerignore`
- Trivy-based vulnerability scanning
- Health checks
- Docker network isolation

Further remediation and automated security gates can be integrated as part of
the CI/CD and AWS security implementation.
