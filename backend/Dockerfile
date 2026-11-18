FROM golang:1.23-alpine AS builder

WORKDIR /app
COPY go.mod ./
# Download dependencies if go.sum exists
RUN go mod download || true

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /edged ./cmd/edged

FROM alpine:3.20

RUN apk --no-cache add ca-certificates tzdata
WORKDIR /app
COPY --from=builder /edged /usr/local/bin/edged

EXPOSE 8080 50051
USER 10001:10001

ENTRYPOINT ["/usr/local/bin/edged"]
