# Healthchecks & Startup Order

## Healthcheck Configuration

### Database (MySQL)
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```
Confirms MySQL is accepting connections before the app starts.

### App (Node.js)
```yaml
healthcheck:
  test: ["CMD", "wget", "-qO-", "http://localhost:3000"]
  interval: 30s
  timeout: 10s
  retries: 3
```
Confirms the Express server is responding on port 3000.

## Startup Order
```yaml
app:
  depends_on:
    db:
      condition: service_healthy
```

## Why This Matters
- `service_started` = container process launched (not enough)
- `service_healthy` = application inside container is functional
- Without this, the app tries to connect to MySQL before it's ready and crashes

## Startup Sequence

db container starts
mysqladmin ping runs every 10s
After MySQL passes healthcheck → db marked healthy
app container starts (only now)
app connects to MySQL successfully
proxy starts and routes traffic to app

