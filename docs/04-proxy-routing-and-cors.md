# Proxy Routing & CORS

## Nginx Configuration

### HTTP → HTTPS Redirect
All port 80 traffic is permanently redirected to HTTPS:
```nginx
server {
  listen 80;
  return 301 https://$host$request_uri;
}```


### HTTPS Server
Listens on port 443, terminates TLS, proxies to app:
```nginx
server {
  listen 443 ssl;
  ssl_certificate     /etc/nginx/certs/epicbook.crt;
  ssl_certificate_key /etc/nginx/certs/epicbook.key;
}
```

### Upstream Resolution
Uses Docker's internal DNS resolver to resolve app hostname dynamically:
```nginx
resolver 127.0.0.11 valid=30s;
set $upstream app;
proxy_pass http://$upstream:3000;
```
This prevents Nginx from failing at startup if the app container
isn't registered in DNS yet.

## CORS Headers
```nginx
add_header 'Access-Control-Allow-Origin'  'https://20.87.53.29' always;
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, DELETE' always;
add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
```

The `always` directive ensures headers appear on ALL responses
including errors, not just 200s.

### Preflight Handling
OPTIONS requests are handled immediately without hitting the app:
```nginx
if ($request_method = 'OPTIONS') {
  add_header 'Access-Control-Max-Age' 1728000;
  add_header 'Content-Length' 0;
  return 204;
}
```

## TLS Certificate
- Type: Self-signed (OpenSSL)
- Algorithm: RSA 2048-bit
- Protocol: TLS 1.3
- Cipher: AES-256-GCM-SHA384
- Validity: 365 days
- CN: 20.87.53.29

Generated with:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/epicbook.key \
  -out nginx/certs/epicbook.crt \
  -subj "/C=NG/ST=Lagos/L=Lagos/O=EpicBook/CN=20.87.53.29"
```

## Network Isolation
- Proxy is on frontend network only
- DB is on backend network only
- App bridges both networks
- DB is completely unreachable from Nginx or the internet
