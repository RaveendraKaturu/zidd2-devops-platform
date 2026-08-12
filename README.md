# ⚡ ZIDD 2.0 — DevOps Platform

<p align="center">
  <strong>Batch 2 • Build • Deploy • Collaborate</strong>
</p>

<p align="center">
  A containerized real-time team collaboration platform built with Spring Boot, React, Docker, Nginx, MySQL, MongoDB and Redis.
</p>

---

## 📌 About The Project

**ZIDD 2.0** is a real-time team collaboration and chat platform developed as a **microservices-based application**.

The platform separates authentication and chat functionality into independent backend services while providing a React-based frontend for users.

The complete application is containerized using **Docker** and orchestrated using **Docker Compose**.

Nginx acts as the application's single entry point, serving the frontend and routing API and WebSocket traffic to the appropriate backend services.

The project is designed as a foundation for further DevOps implementation including CI/CD, container registry integration, Kubernetes deployment, monitoring, logging and observability.

---

## ✨ Features

- 🔐 User registration and authentication
- 🔑 JWT-based authentication
- 💬 Real-time team messaging
- ⚡ WebSocket / STOMP communication
- 👤 User identity and online status
- 🕐 Message timestamps
- ⚛️ React-based frontend
- 🎨 ZIDD 2.0 Batch 2 themed UI
- 🌐 Nginx reverse proxy
- 🐳 Dockerized microservices
- 🗄️ MySQL database for authentication
- 🍃 MongoDB database for chat messages
- ⚡ Redis for caching
- 🔄 Docker Compose based orchestration
- 📦 Independent backend services

---

## 🏗️ Architecture

The application follows a microservices architecture where individual responsibilities are separated into independent services.

Nginx acts as the single entry point for the application.

### Architecture Diagram

<!-- Keep the existing architecture image here exactly as it is -->

![ZIDD 2.0 Architecture](./architecture.png)

> **Note:** The architecture diagram above is the existing project architecture diagram.

---

## 🧩 System Architecture

```text
                         ┌─────────────────────┐
                         │        USER         │
                         │      Browser        │
                         └──────────┬──────────┘
                                    │
                                    │ HTTP / WebSocket
                                    ▼
                         ┌─────────────────────┐
                         │       NGINX         │
                         │   Reverse Proxy     │
                         │  Single Entry Point │
                         └──────────┬──────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
          ┌──────────────────┐             ┌──────────────────┐
          │   React Client   │             │ Backend Services │
          │  chat-app-client │             │                  │
          └──────────────────┘             └────────┬─────────┘
                                                      │
                                  ┌───────────────────┴───────────────────┐
                                  │                                       │
                                  ▼                                       ▼
                       ┌──────────────────┐                   ┌──────────────────┐
                       │   Auth Service   │                   │   Chat Service   │
                       │   Spring Boot    │                   │   Spring Boot    │
                       └────────┬─────────┘                   └────────┬─────────┘
                                │                                      │
                                ▼                                ┌─────┴─────┐
                         ┌──────────────┐                        │           │
                         │    MySQL     │                        ▼           ▼
                         │  Auth Data   │                    MongoDB      Redis
                         └──────────────┘                    Messages     Cache
```

### 🔄 Request Flow

**Authentication Flow**

```text
User
 │
 ▼
React Frontend
 │
 ▼
Nginx
 │
 ▼
Auth Service
 │
 ├── Validate Credentials
 ├── Authenticate User
 └── Generate JWT
 │
 ▼
React Frontend
 │
 ▼
Authenticated Session
```

**Real-Time Messaging Flow**

```text
User A
 │
 ▼
React Client
 │
 │ WebSocket / STOMP
 ▼
Nginx
 │
 ▼
Chat Service
 │
 ├──────────────► MongoDB
 │                 Message Storage
 │
 └──────────────► Redis
                   Caching
 │
 ▼
Real-Time Message
 │
 ▼
Connected Users
```

---

## 🧱 Services

### 🔐 Auth Service

The `auth-service` is responsible for authentication and user identity management.

**Responsibilities**
- User registration
- User login
- Authentication
- JWT generation
- JWT validation
- User information retrieval

**Technology**
- Spring Boot
- Spring Security
- JWT
- MySQL

### 💬 Chat Service

The `chat-service` manages real-time communication between users.

**Responsibilities**
- Sending messages
- Receiving messages
- Persisting chat messages
- Real-time message delivery
- WebSocket communication
- STOMP messaging

**Technology**
- Spring Boot
- WebSocket
- STOMP
- MongoDB
- Redis

### ⚛️ Chat Application Client

The `chat-app-client` provides the frontend interface for users.

**Responsibilities**
- User registration
- User login
- Chat interface
- Real-time messaging
- User identity display
- Message history
- Logout

**Technology**
- React
- STOMP Client
- Chat UI Kit
- JavaScript

### 🌐 Nginx

Nginx works as the application's reverse proxy and single entry point.

**Responsibilities**
- Serving React static files
- Routing API requests
- Routing authentication requests
- Routing chat requests
- WebSocket proxying
- Connecting frontend requests with backend services

The application can therefore be accessed through a single endpoint instead of exposing every backend service directly.

```text
Browser
   │
   ▼
localhost:80
   │
   ▼
 Nginx
   │
   ├── Frontend
   ├── Auth API
   └── Chat API / WebSocket
```

---

## 🛠️ Technology Stack

| Category | Technology |
|---|---|
| Frontend | React |
| Backend | Spring Boot |
| Authentication | Spring Security |
| Authentication Token | JWT |
| Real-Time Communication | WebSocket / STOMP |
| Reverse Proxy | Nginx |
| Authentication Database | MySQL |
| Chat Database | MongoDB |
| Caching | Redis |
| Containerization | Docker |
| Orchestration | Docker Compose |
| Version Control | Git / GitHub |

---

## 📁 Project Structure

```text
zidd2-devops-platform/
│
├── auth-service/
│   ├── src/
│   ├── Dockerfile
│   └── ...
│
├── chat-service/
│   ├── src/
│   ├── Dockerfile
│   └── ...
│
├── chat-app-client/
│   ├── src/
│   │   ├── api/
│   │   ├── hooks/
│   │   ├── pages/
│   │   └── utils/
│   ├── Dockerfile
│   └── ...
│
├── nginx.conf
├── docker-compose.yml
└── README.md
```

---

## 🐳 Docker Architecture

All major application components are containerized.

```text
Docker Compose
      │
      ├── React Client
      │
      ├── Nginx
      │
      ├── Auth Service
      │
      ├── Chat Service
      │
      ├── MySQL
      │
      ├── MongoDB
      │
      └── Redis
```

Docker Compose provides a reproducible local environment where the services can communicate using the Docker network.

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed on your system:

- Git
- Docker
- Docker Compose

Verify the installations:

```bash
git --version
docker --version
docker compose version
```

### 📥 Installation

**1. Clone the Repository**

```bash
git clone https://github.com/yashtrivedi0402/zidd2-devops-platform.git
```

Move into the project directory:

```bash
cd zidd2-devops-platform
```

### 🔨 Build the Application

Build all Docker images:

```bash
docker compose build
```

### ▶️ Start the Application

Start all services in detached mode:

```bash
docker compose up -d
```

Check the running containers:

```bash
docker compose ps
```

You can also use:

```bash
docker ps
```

### 🌐 Access the Application

Once all services are healthy, open:

```
http://localhost
```

The application is served through Nginx.

### 🧪 Verify Services

Check the status of all containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Follow logs in real time:

```bash
docker compose logs -f
```

---

## 📋 Useful Docker Commands

**View Running Containers**
```bash
docker compose ps
```

**View All Containers**
```bash
docker ps -a
```

**View Application Logs**
```bash
docker compose logs -f
```

**Auth Service Logs**
```bash
docker compose logs -f auth-service
```

**Chat Service Logs**
```bash
docker compose logs -f chat-service
```

**Nginx / Frontend Logs**
```bash
docker compose logs -f app
```

**Restart Services**
```bash
docker compose restart
```

**Stop the Application**
```bash
docker compose down
```

**Rebuild Everything**
```bash
docker compose down
docker compose build
docker compose up -d
```

---

## 🔌 Network Communication

The services communicate through the Docker Compose network.

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

Services can communicate with each other using their Docker service names.

For example:

- `auth-service` → `mysqldb`
- `chat-service` → `mongodb`
- `chat-service` → `redisdb`
- `nginx` → `auth-service`
- `nginx` → `chat-service`

---

## 🔐 Authentication

The application uses JWT-based authentication.

The general flow is:

```text
Register / Login
       │
       ▼
 Auth Service
       │
       ▼
 Credentials Validation
       │
       ▼
 JWT Token
       │
       ▼
 Client
       │
       ▼
 Authenticated Requests
```

The token is used when making authenticated API and WebSocket requests.

---

## 💬 Real-Time Communication

The chat application uses WebSocket and STOMP for real-time communication.

Instead of repeatedly polling the backend for new messages, connected clients maintain a WebSocket connection.

```text
Client A
   │
   │ WebSocket
   ▼
Chat Service
   │
   │ STOMP
   ▼
Message Topic
   │
   ├──────────────► Client B
   │
   ├──────────────► Client C
   │
   └──────────────► Client D
```

This allows messages to appear in connected clients in real time.

---

## 🗄️ Data Storage

The application uses different databases for different responsibilities.

**MySQL**

Used by the authentication service.

```text
Auth Service
     │
     ▼
   MySQL
```

**MongoDB**

Used by the chat service for storing messages.

```text
Chat Service
     │
     ▼
  MongoDB
```

**Redis**

Used by the chat service for caching and fast-access data.

```text
Chat Service
     │
     ▼
   Redis
```

This separation follows the microservices principle of giving services ownership over their relevant data.

---

## 🎨 ZIDD 2.0 UI

The frontend has been customized around the ZIDD 2.0 — Batch 2 identity.

**UI Characteristics**
- Dark developer-focused interface
- ZIDD 2.0 branding
- Batch 2 identity
- Team collaboration messaging
- Online user indicator
- Message timestamps
- Responsive layout
- Real-time message updates

---

## 🧑‍💻 Development Workflow

A typical development workflow for the project is:

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Feature Branch
    │
    ▼
Code Changes
    │
    ▼
Local Docker Environment
    │
    ├── Build
    ├── Test
    └── Run
    │
    ▼
Pull Request
    │
    ▼
Code Review
    │
    ▼
Merge
```

---

## 🔮 Future DevOps Roadmap

ZIDD 2.0 can be extended into a complete DevOps platform.

**Phase 1 — Current**
```text
React
   │
Docker
   │
Docker Compose
   │
Spring Boot Microservices
```

**Phase 2 — CI/CD**
```text
GitHub
   │
   ▼
GitHub Actions / Jenkins
   │
   ├── Build
   ├── Test
   ├── Docker Build
   └── Push Image
```

**Phase 3 — Container Registry**
```text
CI/CD
  │
  ▼
Docker Registry
  │
  ▼
Versioned Images
```

**Phase 4 — Kubernetes**
```text
Container Registry
        │
        ▼
   Kubernetes
        │
        ├── Deployments
        ├── Services
        ├── ConfigMaps
        ├── Secrets
        └── Ingress
```

**Phase 5 — Observability**
```text
Kubernetes
    │
    ├── Prometheus
    ├── Grafana
    ├── Centralized Logging
    └── Application Monitoring
```

---

## 📈 Planned Improvements

Some potential improvements for future iterations include:

- [ ] CI/CD pipeline
- [ ] Automated testing
- [ ] Docker image versioning
- [ ] Container registry integration
- [ ] Kubernetes deployment
- [ ] Kubernetes Ingress
- [ ] Horizontal Pod Autoscaling
- [ ] Infrastructure as Code
- [ ] Prometheus monitoring
- [ ] Grafana dashboards
- [ ] Centralized logging
- [ ] Application health monitoring
- [ ] Production-grade secrets management
- [ ] Automated deployment
- [ ] Improved test coverage

---

## 🤝 Team Collaboration

ZIDD 2.0 is being developed as a collaborative Batch 2 project.

Different contributors can work on independent areas such as:

```text
Frontend
   │
Backend
   │
DevOps
   │
Infrastructure
   │
Testing
   │
Monitoring
   │
Documentation
```

For development, contributors should preferably use feature branches:

```bash
git checkout -b feature/your-feature
```

After completing the work:

```bash
git add .
git commit -m "feat: add your feature"
git push origin feature/your-feature
```

Then open a Pull Request for review.

---

## ⚠️ Important Notes

This project is currently intended for development, learning and demonstration purposes.

Before using it in a production environment, additional work would be required around:

- Security hardening
- Secret management
- Database security
- TLS/HTTPS
- Production configuration
- High availability
- Monitoring
- Logging
- Backup and recovery
- Scalability
- Infrastructure automation

Do not use development credentials or development configuration in production.

---

## 📜 License

This project is licensed under the MIT License.

See the LICENSE file for more information.

<p align="center"> <strong>⚡ ZIDD 2.0</strong> </p>
<p align="center"> Batch 2 • Build • Deploy • Collaborate </p>
