# theepicbook-docker-capstone

Production deployment of a Node.js bookstore app on Azure — multi-stage Docker builds, Nginx reverse proxy with HTTPS, MySQL with seed data, Docker Compose orchestration, healthchecks, log rotation, and GitHub Actions CI/CD. Provisioned with Terraform.

## Stack
Node.js + Express + Sequelize + MySQL + Nginx + Docker Compose + Terraform + GitHub Actions

## Features
- Multi-stage Docker build (lean production image, non-root user)
- MySQL 5.7 with automatic seed data on first boot
- Nginx reverse proxy with CORS headers and HTTPS (self-signed cert)
- HTTP → HTTPS redirect
- Healthchecks and dependency ordering with depends_on: service_healthy
- Log rotation on all containers
- Environment management with .env and chmod 600
- GitHub Actions CI/CD pipeline for automated deployments

## Architecture
Browser → Nginx (port 443) → Node.js app (port 3000) → MySQL (port 3306)
