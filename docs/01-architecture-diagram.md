# Architecture Diagram

## Component Overview
                     Internet
                        │
                     Port 443 (HTTPS)
                     Port 80 (HTTP → redirects to HTTPS)
                        │
                ┌───────▼────────┐
                │   Nginx Proxy  │  (nginx:alpine)
                │   frontend     │  Terminates TLS
                │   network      │  CORS headers
                └───────┬────────┘
                        │ Port 3000 (internal)
                ┌───────▼────────┐
                │   Node.js App  │  (theepicbook-app)
                │   frontend +   │  Express + Sequelize
                │   backend      │  Handlebars templates
                │   networks     │
                └───────┬────────┘
                        │ Port 3306 (internal)
                ┌───────▼────────┐
                │     MySQL      │  (mysql:5.7)
                │   backend      │  Auto-seeded on boot
                │   network      │  db_data volume
                └────────────────┘

## Networks
| Network | Services | Purpose |
|---------|----------|---------|
| frontend | proxy, app | Public-facing traffic |
| backend | app, db | Internal DB communication |

## Ports
| Port | Public | Service | Purpose |
|------|--------|---------|---------|
| 80 | ✅ | Nginx | HTTP → HTTPS redirect |
| 443 | ✅ | Nginx | HTTPS traffic |
| 3000 | ❌ | Node.js | Internal only |
| 3306 | ❌ | MySQL | Internal only |

## Volumes
| Volume | Service | Purpose |
|--------|---------|---------|
| db_data | MySQL | Persistent database storage |
