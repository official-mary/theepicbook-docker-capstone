# ── Stage 1: deps ──────────────────────────────────────────
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ── Stage 2: production image ──────────────────────────────
FROM node:18-alpine AS production
WORKDIR /app

# Copy only production deps from stage 1
COPY --from=deps /app/node_modules ./node_modules

# Copy app source
COPY . .

# Don't run as root
RUN addgroup -S epicbook && adduser -S epicbook -G epicbook
USER epicbook

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:3000 || exit 1

CMD ["node", "server.js"]
