# Environment Variables & Ports

## Environment Variables

| Variable | Service | Purpose |
|----------|---------|---------|
| PORT | app | Node.js listening port (3000) |
| NODE_ENV | app | Set to production to use JAWSDB_URL |
| JAWSDB_URL | app | Full MySQL connection string |
| MYSQL_DATABASE | db | Database name (bookstore) |
| MYSQL_USER | db | App database user |
| MYSQL_PASSWORD | db | App database password |
| MYSQL_ROOT_PASSWORD | db | MySQL root password |

## .env File Template
PORT=3000
NODE_ENV=production
JAWSDB_URL=mysql://epicbook:<password>@db:3306/bookstore
MYSQL_DATABASE=bookstore
MYSQL_USER=epicbook
MYSQL_PASSWORD=<password>
MYSQL_ROOT_PASSWORD=<root-password>

## Security Notes
- .env is listed in .gitignore — never committed to Git
- .env has chmod 600 — only owner can read/write
- DB port 3306 is NOT published — only accessible inside Docker network
- Passwords should be rotated for real production use

## Public Ports
| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH (Azure NSG restricted) |
| 80 | TCP | HTTP (redirects to HTTPS) |
| 443 | TCP | HTTPS (app traffic) |
