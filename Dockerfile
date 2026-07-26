# --- Build stage ---
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app
RUN git clone --depth 1 https://github.com/pocketbase/pocketbase.git .

WORKDIR /app/examples/base
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /pocketbase

# --- Runtime stage ---
FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /pb
COPY --from=builder /pocketbase /pb/pocketbase

EXPOSE 8090

# Render injects $PORT - bind to it instead of a fixed port.
# On boot, upsert a superuser from env vars (PB_ADMIN_EMAIL / PB_ADMIN_PASSWORD)
# since PocketBase 0.23+ no longer allows creating the first admin via /_/.
CMD ["sh", "-c", "if [ -n \"$PB_ADMIN_EMAIL\" ] && [ -n \"$PB_ADMIN_PASSWORD\" ]; then /pb/pocketbase superuser upsert \"$PB_ADMIN_EMAIL\" \"$PB_ADMIN_PASSWORD\"; fi; /pb/pocketbase serve --http=0.0.0.0:${PORT:-8090}"]
