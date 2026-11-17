# Multi-Container Web Application with Docker Compose

A production-style containerized web application deployed on **CentOS Stream 9** using **Docker**, **Docker Compose**, **Nginx**, **Python (Flask)**, and **Redis**.

## Architecture
- **Frontend (`web`):** Custom Nginx container serving static UI on port `8080`.
- **Backend API (`api`):** Python Flask microservice on port `5000` tracking real-time hits.
- **Database (`redis-db`):** Redis in-memory data store persisting visitor counts across container restarts.

## Quick Start
```bash
docker compose up -d --build
```
