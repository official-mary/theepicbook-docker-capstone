# Persistence & Backup

## Volume Configuration
```yaml
volumes:
  db_data:
    driver: local
```
The db_data named volume persists MySQL data across all container
restarts including full stack down/up cycles.

## What Persists
| Data | Storage | Survives docker compose down? |
|------|---------|-------------------------------|
| MySQL tables + rows | db_data volume |  Yes |
| App code | Container image |  Yes (rebuilt on deploy) |
| SSL certs | Host filesystem |  Yes |
| Logs | Docker json-file |  Yes (with rotation) |

## Backup Procedure

### Manual Backup
```bash
mkdir -p ~/backups
docker exec theepicbook-docker-capstone-db-1 \
  mysqldump -u root -pRootPass123! --no-tablespaces bookstore \
  > ~/backups/bookstore_$(date +%Y%m%d_%H%M%S).sql
```

### Restore Procedure
```bash
docker exec -i theepicbook-docker-capstone-db-1 \
  mysql -u root -pRootPass123! bookstore \
  < ~/backups/bookstore_<timestamp>.sql

# Verify
docker exec theepicbook-docker-capstone-db-1 \
  mysql -u root -pRootPass123! \
  -e "SELECT COUNT(*) FROM bookstore.Book;"
```

## Backup Schedule Recommendation
| Frequency | Type | Storage Location |
|-----------|------|-----------------|
| Daily | SQL dump | VM disk ~/backups/ |
| Weekly | SQL dump | Azure Blob Storage |
| Pre-deploy | SQL dump | VM disk before pipeline runs |

## Restore Test Results
| Step | Result |
|------|--------|
| Books before disaster | 54 |
| Database dropped | ERROR 1146 Table doesn't exist |
| Restore from backup | Success |
| Books after restore | 54 |
| App serving data |  200 OK |

Restore completed in under 5 seconds.
