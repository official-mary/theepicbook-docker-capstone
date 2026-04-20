# Cloud Deployment Notes

## Infrastructure
| Resource | Value |
|----------|-------|
| Cloud Provider | Microsoft Azure |
| Region | South Africa North |
| VM Size | Standard_B2s_v2 |
| OS | Ubuntu 22.04 LTS |
| Public IP | 20.87.53.29 |
| Provisioned With | Terraform |

## Azure NSG Rules
| Rule | Port | Protocol | Direction | Action |
|------|------|----------|-----------|--------|
| allow-ssh | 22 | TCP | Inbound | Allow |
| allow-http | 80 | TCP | Inbound | Allow |
| allow-https | 443 | TCP | Inbound | Allow |

## Deployment Verification
| Check | Result |
|-------|--------|
| HTTPS live | 200 OK |
| HTTP redirect | 301 to HTTPS |
| App healthcheck | healthy |
| DB healthcheck | healthy |
| NODE_ENV | production |
| DB port published |  No |
| App port published |  No |

## Public URL
https://20.87.53.29

## Persistence Verified
Data survives full stack down/up cycles via db_data named volume.
Tested: 54 books before bounce, 54 books after bounce.

## Security Hardening
- .env chmod 600 — owner read/write only
- .env in .gitignore — never committed to Git
- DB port 3306 not published
- App port 3000 not published
- Non-root user inside app container
- Split networks — DB unreachable from proxy
