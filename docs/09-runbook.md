# Ops Runbook — The EpicBook

## 1. Start / Stop Stack

### Start the stack
```bash
cd ~/theepicbook-docker-capstone
docker compose up -d
```

### Stop the stack
```bash
docker compose down
```

### Restart a single service
```bash
docker compose restart app      # restart app only
docker compose restart proxy    # restart nginx only
docker compose restart db       # restart database only
```

### Check status
```bash
docker compose ps
```

---

## 2. Rollback Procedure

If a bad deployment breaks the app:

### Step 1 — Identify the last working image
```bash
docker images theepicbook-docker-capstone-app
```

### Step 2 — Roll back to previous image
```bash
# Tag the previous image as latest
docker tag theepicbook-docker-capstone-app:<previous-build-id> theepicbook-docker-capstone-app:latest

# Restart the app with the previous image
docker compose up -d --no-build app
```

### Step 3 — Verify rollback
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost
docker compose ps
```

---

## 3. Rotating Secrets

### Step 1 — Update .env on the VM
```bash
cd ~/theepicbook-docker-capstone
nano .env
# Update MYSQL_PASSWORD, MYSQL_ROOT_PASSWORD, JAWSDB_URL
```

### Step 2 — Recreate containers with new secrets
```bash
docker compose down
docker compose up -d
```

### Step 3 — Verify app connects to DB
```bash
docker compose logs app --tail=20
docker compose ps
```

---

## 4. Log Locations

| Service | Log Location | Command |
|---------|-------------|---------|
| App | Docker json-file (max 10m, 5 files) | `docker compose logs app` |
| Nginx | Docker json-file (max 10m, 3 files) | `docker compose logs proxy` |
| MySQL | Docker json-file (max 10m, 3 files) | `docker compose logs db` |
| Nginx access | Inside proxy container | `docker compose exec proxy cat /var/log/nginx/access.log` |

### Live log tailing
```bash
docker compose logs -f app          # follow app logs
docker compose logs -f proxy        # follow nginx logs
docker compose logs --tail=50 db    # last 50 db logs
```

---

## 5. Backup & Restore

### Manual backup
```bash
mkdir -p ~/backups
docker exec theepicbook-docker-capstone-db-1 \
  mysqldump -u root -pRootPass123! --no-tablespaces bookstore \
  > ~/backups/bookstore_$(date +%Y%m%d_%H%M%S).sql
```

### Restore from backup
```bash
docker exec -i theepicbook-docker-capstone-db-1 \
  mysql -u root -pRootPass123! bookstore \
  < ~/backups/bookstore_<timestamp>.sql

# Verify restore
docker exec theepicbook-docker-capstone-db-1 \
  mysql -u root -pRootPass123! \
  -e "SELECT COUNT(*) FROM bookstore.Book;"
```

### Backup schedule recommendation
| Frequency | Type | Storage |
|-----------|------|---------|
| Daily | SQL dump | VM disk ~/backups/ |
| Weekly | SQL dump | Azure Blob Storage |
| On deploy | SQL dump | VM disk before pipeline runs |

---

## 6. Common Errors & Fixes

### Port already allocated
```bash
sudo fuser -k 80/tcp 443/tcp
sudo systemctl restart docker
docker compose up -d
```

### App unhealthy / 502 Bad Gateway
```bash
# Check if DB is running
docker compose ps
# Restart DB if stopped
docker compose start db
# Wait for healthy then check app
sleep 15 && docker compose ps
```

### DNS resolution failed in Nginx
```bash
# Verify nginx.conf uses Docker internal resolver
grep "resolver" nginx/nginx.conf
# Should show: resolver 127.0.0.11 valid=30s;
# If missing, recreate proxy
docker compose up -d --force-recreate proxy
```

### Container won't start after git pull
```bash
# Force recreate all containers
docker compose down
docker compose up -d --force-recreate
```

### SSL certificate error
```bash
# Regenerate self-signed cert
mkdir -p ~/theepicbook-docker-capstone/nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ~/theepicbook-docker-capstone/nginx/certs/epicbook.key \
  -out ~/theepicbook-docker-capstone/nginx/certs/epicbook.crt \
  -subj "/C=NG/ST=Lagos/L=Lagos/O=EpicBook/CN=<YOUR-VM-IP>"
docker compose up -d --force-recreate proxy
```

### VM DNS broken (curl fails)
```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Azure Pipelines agent offline
```bash
cd ~/azagent
sudo ./svc.sh status
sudo ./svc.sh start
```
