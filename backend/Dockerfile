# Multi-stage Dockerfile for Shawaf AI Edge Daemon (edged)
FROM golang:1.24-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /bin/edged ./cmd/edged

FROM alpine:3.20

WORKDIR /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /bin/edged /app/edged

EXPOSE 8080 50051

ENTRYPOINT ["/app/edged"]
