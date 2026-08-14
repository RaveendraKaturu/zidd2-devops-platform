# =========================
# Build Stage
# =========================
FROM oven/bun:1-alpine AS builder

WORKDIR /app

COPY package.json ./

RUN bun install

COPY . .

RUN bun run build


# =========================
# Runtime Stage
# =========================
FROM nginx:1.27-alpine

COPY --from=builder /app/dist /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]