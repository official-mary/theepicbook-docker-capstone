# Reliability Tests

## Test 1 — Restart App Only
**Goal:** Verify DB stays up and app recovers after restart.

**Steps:**
docker compose restart app
sleep 10
docker compose ps
curl -k -s -o /dev/null -w "%{http_code}" https://localhost

**Result:**
- App restarted and returned to healthy status
- DB remained up throughout
- HTTPS returned 200 after restart
- **PASSED ✅**

## Test 2 — Take DB Down
**Goal:** Verify app returns clear errors when DB is unavailable.

**Steps:**
docker compose stop db
curl -k -s -o /dev/null -w "%{http_code}" https://localhost
docker inspect theepicbook-docker-capstone-app-1 --format '{{.State.Health.Status}}'

**Result:**
- App returned 502 Bad Gateway
- App healthcheck showed unhealthy
- After DB restart: app recovered to healthy, HTTPS returned 200
- **PASSED ✅**

## Test 3 — Full Stack Bounce (Persistence Test)
**Goal:** Verify data survives a full stack restart.

**Steps:**
Before
SELECT COUNT(*) FROM bookstore.Book; → 54 books
docker compose down
docker compose up -d
After
SELECT COUNT(*) FROM bookstore.Book; → 54 books

**Result:**
- All containers removed and recreated
- db_data named volume preserved all data
- 54 books present before and after bounce
- HTTPS returned 200 after restart
- **PASSED ✅**

## Summary
| Test | Scenario | Expected | Result |
|------|----------|----------|--------|
| 1 | Restart app | DB stays up, app recovers | ✅ PASSED |
| 2 | Kill DB | App returns 502, healthcheck fails | ✅ PASSED |
| 3 | Bounce stack | Data persists via named volume | ✅ PASSED |
