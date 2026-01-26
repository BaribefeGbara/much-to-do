# Build stage
FROM golang:1.25-alpine AS builder
WORKDIR /app

# Copy the entire MuchToDo directory
COPY MuchToDo/ .

# Download dependencies
RUN go mod download

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/api

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/server .

# Copy .env.example as template
COPY --from=builder /app/.env.example .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./server"]
