

# Fullstack Todo List Application — Docker Setup Documentation

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Repository Setup](#3-repository-setup)
4. [Docker Configuration](#4-docker-configuration)

   * [Dockerfiles](#41-dockerfiles)
   * [Docker Compose](#42-docker-compose)
5. [Running the Application](#5-running-the-application)

   * [Build and Start](#51-build-and-start)
   * [Stop and Cleanup](#52-stop-and-cleanup)
6. [Network and Security Configuration](#6-network-and-security-configuration)
7. [Troubleshooting](#7-troubleshooting)
8. [Testing the Setup](#8-testing-the-setup)
9. [Live Deployment](#9-live-deployment)
10. [Summary](#10-summary)

---

## 1. Overview

This document provides instructions for containerizing and running a 3-tier fullstack application using Docker and Docker Compose. The application is composed of:

* **Frontend**: React
* **Backend**: Node.js with Express
* **Database**: MongoDB

Each component runs in its own container, with orchestration handled by Docker Compose.

---

## 2. Prerequisites

Ensure the following tools are installed on your machine:

* Docker (version 20.10 or higher)
* Docker Compose (version 1.27 or higher)
* Git

---

## 3. Repository Setup

1. Clone the project repository:

   ```bash
   git clone https://github.com/guderian120/fullstack-todo-list.git
   cd fullstack-todo-list
   ```

2. Review the `.env.example` file and create a `.env` file if necessary for environment variable customization.

---

## 4. Docker Configuration

### 4.1 Dockerfiles

Each component includes its own Dockerfile:

* `./Frontend/Dockerfile`
* `./Backend/Dockerfile`
* `./Database/Dockerfile`

These Dockerfiles specify the build instructions, dependencies, and runtime configurations for each service.

### 4.2 Docker Compose

The `docker-compose.yml` file coordinates the multi-container setup with:

* Service definitions for frontend, backend, and database
* Shared Docker bridge network for inter-container communication
* Named volumes for MongoDB data persistence
* Environment variables for database access
* Port mappings for accessing services locally

---

## 5. Running the Application

### 5.1 Build and Start

To build images and start the containers:

```bash
docker-compose up --build
```

Access the application using:

* Frontend: [http://localhost:8000](http://localhost:8000)
* Backend: [http://localhost:3000](http://localhost:3000)
* MongoDB: Accessible at port 27017 (for development purposes)

### 5.2 Stop and Cleanup

To stop containers:

```bash
docker-compose down
```

To stop and remove containers, networks, and volumes:

```bash
docker-compose down -v
```

---

## 6. Network and Security Configuration

* **Network**: All services run on a user-defined bridge network (`app-network`) for isolated communication.

* **Ports**:

  | Service  | Host Port | Container Port |
  | -------- | --------- | -------------- |
  | Frontend | 3000      | 8000           |
  | Backend  | 5000      | 3000           |
  | Database | 27017     | 27017          |

* **Environment Variables**:

  Backend uses:

  ```env
  MONGODB_URI=mongodb://user:password@database:27017/appdb?authSource=admin
  ```

  MongoDB service uses:

  ```env
  MONGO_INITDB_ROOT_USERNAME=user
  MONGO_INITDB_ROOT_PASSWORD=password
  MONGO_INITDB_DATABASE=appdb
  ```

* **Volumes**:

  MongoDB persists data using a named volume (`db-data`) mounted at `/data/db`.

---

## 7. Troubleshooting

| Issue                        | Possible Cause                                    | Solution                                                                                      |
| ---------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Backend cannot connect to DB | Wrong connection string or service name           | Verify `MONGODB_URI`, service name (`database`), and credentials                              |
| MongoDB shell not working    | `mongosh` not installed in container              | Use `docker exec -it database mongosh -u user -p password --authenticationDatabase admin`     |
| Port already in use          | Host port conflict                                | Stop other applications or change the host port in `docker-compose.yml`                       |
| Containers not starting      | Dockerfile error or build failure                 | Review logs using `docker-compose logs` and correct any syntax or dependency issues           |
| Data loss on restart         | Volume not mounted correctly                      | Ensure volume `db-data` is defined and mapped to `/data/db` in MongoDB container              |
| Services unreachable         | Network misconfiguration or container not running | Check container status with `docker ps` and network with `docker network inspect app-network` |

---

## 8. Testing the Setup

A test script (`test-containers.sh`) is available under the `test_connections/` directory to verify the containerized services.

### Usage

```bash
chmod +x test-containers.sh
./test-containers.sh
```

This script performs:

* MongoDB connectivity check using `mongosh`
* Backend API check at `/api/gettodos`
* Frontend availability check on port 8000

Expected result: HTTP status code `200` for backend and frontend endpoints.

---

## 9. Live Deployment

Here is the revised **Live Deployment** section with detailed deployment methodologies included:

---

## 9. Live Deployment

The application is deployed on AWS using a Virtual Private Cloud (VPC) with the following architecture:

### Deployment Architecture

* **VPC**: A custom VPC was created to isolate and manage network resources securely.
* **Subnets**:

  * **Public Subnet**: Hosts the **frontend** and **backend** services. These are exposed to the internet via a public IP and an Application Load Balancer (ALB).
  * **Private Subnet**: Hosts the **MongoDB database** to prevent direct internet access. This enhances security by restricting exposure to external threats.
* **Security Groups**:

  * Configured to allow only necessary traffic. For instance, the backend can communicate with the database over the internal network, and the frontend can call the backend APIs.
* **Internet Gateway**: Attached to the VPC to enable internet access for instances in the public subnet.
* **NAT Gateway**: Allows instances in the private subnet (e.g., MongoDB) to initiate outbound traffic for updates without being exposed to the internet.

### Hosting

* **Frontend**: Served using an Nginx container running in the public subnet, accessible via a domain mapped using a DNS record pointing to the ALB.
* **Backend**: Also hosted in the public subnet with API routes protected via security group rules and environment-level secrets.
* **Database**: Runs securely in a private subnet. Only backend services within the VPC can access it.

### Access URL

The application is publicly accessible via the following endpoint:

**[https://todo.34.245.120.229.sslip.io](https://todo.34.245.120.229.sslip.io)**

SSL termination is handled at the load balancer level, and domain routing is managed via Route 53 and DNS resolution through sslip.io for demonstration purposes.



## 10. Summary

This Docker setup enables the development and testing of a fullstack todo application with:

* Independent Dockerfiles for each component
* Centralized orchestration using Docker Compose
* Secure handling of environment variables
* Persistent storage for database data
* Isolated container networking
* Built-in testing to validate service operation

Ensure this setup is running locally during your interview, as you will be required to demonstrate it.
