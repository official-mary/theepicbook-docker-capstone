# CI/CD Pipeline

## Tool
Azure Pipelines (Azure DevOps organisation: marydevOps)
Project: Epicbook

## Agent
Self-hosted agent installed directly on the Azure VM.
- Agent name: epicbook-vm-agent
- Pool: Default
- Version: 4.271.0
- Runs as: systemd service (survives VM reboots)

## Pipeline Trigger
Runs automatically on every push to the main branch.

## Pipeline Stages

### Stage 1 — Build
- Builds Docker image from Dockerfile
- Tags image with $(Build.BuildId)
- Tags image as latest

### Stage 2 — Deploy
- Pulls latest code: git pull origin main
- Runs: docker compose up --build -d
- Prunes old images: docker image prune -f

## Version Tagging Strategy
Images tagged with $(Build.BuildId) — Azure's auto-incremented
run number. Format: YYYYMMDD.N (e.g. 20260418.1).
Gives a clear audit trail of which build is running in production.

## First Successful Run
- Run ID: 20260418.1
- Build stage: 38 seconds
- Deploy stage: 42 seconds
- Total time: under 2 minutes
- Result: all green

## Why Self-Hosted Agent
- Agent runs where the app lives — no SSH needed
- Direct access to Docker and docker compose
- More control over the build environment
- Survives VM reboots via systemd service
