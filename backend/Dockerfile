# Multi-stage Dockerfile for Shawaf AI Edge Daemon (edged)
# Builder stage
FROM golang:1.23-alpine AS builder

WORKDIR /build

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum* ./
RUN go mod download || true

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /bin/edged ./cmd/edged

# Final runtime stage
FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app
COPY --from=builder /bin/edged /app/edged

EXPOSE 8080 50051

ENTRYPOINT ["/app/edged"]
