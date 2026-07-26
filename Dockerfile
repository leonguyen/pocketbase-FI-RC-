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

# Render injects $PORT - bind to it instead of a fixed port
CMD ["sh", "-c", "/pb/pocketbase serve --http=0.0.0.0:${PORT:-8090}"]
