# Logging Layout

## Log Driver Configuration
All containers use Docker's json-file driver with rotation:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Log Limits Per Service
| Service | Max Size | Max Files | Total Max |
|---------|----------|-----------|-----------|
| app | 10m | 5 | 50MB |
| proxy | 10m | 3 | 30MB |
| db | 10m | 3 | 30MB |

## Viewing Logs
```bash
docker compose logs app --tail=50
docker compose logs proxy --tail=50
docker compose logs db --tail=50
docker compose logs -f app
docker compose exec proxy cat /var/log/nginx/access.log
```

## Log Format Examples

### Nginx Access Log
172.18.0.1 - - [17/Apr/2026:14:37:14 +0000] "GET / HTTP/1.1" 200 24858 "-" "curl/7.81.0"
Fields: IP, timestamp, method+path, status, bytes, user-agent

### App Log (Sequelize queries)
Executing (default): SELECT Book.id, Book.title FROM Book LEFT OUTER JOIN Author LIMIT 9;
Executing (default): SELECT DISTINCT(genre) FROM Book;
Executing (default): SELECT count(*) FROM Cart;

## Why Log Rotation Matters
Without rotation, containers running for weeks will eventually
fill the VM disk and crash everything. The json-file driver with
max-size and max-file limits gives rolling logs that never grow
unbounded.

## Log Storage Decision
- App logs: Docker stdout (json-file) — works with docker compose logs
- Nginx access logs: bind mount to /var/log/nginx/ inside container
- All logs capped with rotation — no manual cleanup needed
