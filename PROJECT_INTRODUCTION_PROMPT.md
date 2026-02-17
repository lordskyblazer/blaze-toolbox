# Project Introduction Prompt

## Overview

This prompt introduces two parallel projects: **Blaze-Toolbox K8s Development** and **NJS Web Server Development**. Both projects work together to create a comprehensive web application ecosystem with containerized services and Kubernetes orchestration.

## Blaze-Toolbox K8s Development Project

### Architecture Overview
The Blaze-Toolbox project features a sophisticated local Kubernetes cluster architecture with the following key components:

#### Core Services
- **Next.js Webserver**: Production-ready deployment with health probes and resource management
- **PostgreSQL Database**: Persistent storage with local PV/PVC setup and trust authentication for development
- **Redis Cache**: Password-secured caching service with persistent storage and comprehensive configuration

#### Infrastructure Components
- **Kubernetes Dashboard**: Web-based cluster management interface with RBAC configuration
- **Storage Management**: Local persistent volumes for database and Redis data persistence
- **Network Policies**: Security and isolation for cluster services

#### Configuration Management
- **Kustomize-based Deployment**: Modular configuration with overlays for different environments
- **Secret Management**: Secure handling of sensitive data (database credentials, Redis passwords)
- **ConfigMap Management**: Non-sensitive configuration values and application settings

### Key Features
- **Multi-tier Architecture**: Web server → Database/Cache → Storage layers
- **Health Monitoring**: Liveness and readiness probes for all services
- **Resource Management**: CPU and memory limits/requests for optimal performance
- **Development-Ready**: Trust authentication for PostgreSQL, local storage for rapid iteration
- **Production-Ready**: Proper secrets, resource limits, and health checks

## NJS Web Server Development Project

### Technology Stack
- **Backend Framework**: Express.js server (Node.js 18+ compatible)
- **Database**: PostgreSQL with connection pooling and transaction support
- **Caching**: Redis with authentication, pub/sub, and data structure operations
- **Frontend**: Next.js 13.5.6 with React 18.2.0
- **Containerization**: Docker with multi-stage builds and optimized images

### API Capabilities
- **Health Monitoring**: `/api/health` endpoint with service status reporting
- **Redis Operations**: Complete CRUD operations for caching and session management
- **Database Integration**: PostgreSQL query execution with connection management
- **Session Storage**: Redis-based session handling with TTL and automatic cleanup
- **Authentication Support**: Secure Redis connections with password authentication

### Development Features
- **Comprehensive Documentation**: COMMANDS_GUIDE.md and LIBRARIES_GUIDE.md
- **Testing Infrastructure**: Multiple test scripts for validation and debugging
- **Environment Configuration**: Flexible environment variable management
- **Error Handling**: Robust error handling and logging throughout the application

## Integration Points

### Service Communication
- **Next.js ↔ PostgreSQL**: Direct database connections for data persistence
- **Next.js ↔ Redis**: Caching, session storage, and real-time features
- **Container Networking**: Kubernetes service discovery and internal networking

### Deployment Strategy
- **Docker Images**: Containerized applications ready for Kubernetes deployment
- **Environment Variables**: Seamless configuration between development and production
- **Health Checks**: Integrated monitoring across all services

### Development Workflow
- **Local Development**: Docker Compose for local testing and development
- **Kubernetes Deployment**: Kustomize-based deployments with environment-specific overlays
- **CI/CD Ready**: Container images and Kubernetes manifests ready for automated deployment

## Project Goals

### Short-term Objectives
1. **Complete Integration**: Deploy NJS Web Server to the Blaze-Toolbox Kubernetes cluster
2. **Service Validation**: Test all API endpoints and database connections in cluster environment
3. **Performance Optimization**: Fine-tune resource allocation and caching strategies
4. **Security Hardening**: Implement production-ready authentication and authorization

### Long-term Vision
1. **Scalability**: Design for horizontal scaling of web servers and database read replicas
2. **Monitoring**: Implement comprehensive observability with metrics and logging
3. **Multi-environment**: Support for development, staging, and production environments
4. **Developer Experience**: Streamlined development workflow with hot reloading and debugging

## Technical Highlights

### Kubernetes Best Practices
- **Resource Management**: Proper CPU/memory limits and requests
- **Health Checks**: Liveness and readiness probes for all services
- **Security**: RBAC, network policies, and secret management
- **Storage**: Persistent volumes with appropriate access modes

### Modern Web Development
- **API Design**: RESTful endpoints with proper error handling
- **Database Patterns**: Connection pooling, transactions, and query optimization
- **Caching Strategy**: Redis for sessions, caching, and real-time features
- **Container Optimization**: Multi-stage builds and minimal base images

### Development Infrastructure
- **Documentation**: Comprehensive guides for commands, libraries, and deployment
- **Testing**: Multiple test scripts for different aspects of the application
- **Configuration**: Environment-based configuration management
- **Debugging**: Tools and scripts for troubleshooting in development and production

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Kubernetes cluster (local or cloud-based)
- kubectl command-line tool
- Node.js 18+ for local development

### Quick Start
1. **Clone the repository**: `git clone [repository-url]`
2. **Build Docker images**: `docker build -t njswebserver:latest ./njswebserver`
3. **Deploy to Kubernetes**: `kubectl apply -k applications/base/`
4. **Access services**: Use port forwarding or ingress to access web interface
5. **Monitor deployment**: Use Kubernetes Dashboard for cluster management

This architecture provides a solid foundation for modern web application development with containerization, orchestration, and scalable infrastructure.
