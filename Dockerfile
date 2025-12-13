# Stage 1: Build Stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata wget

# Set working directory
WORKDIR /build

# Set Go proxy with fallback and enable retries
ENV GOPROXY=https://proxy.golang.org,direct
ENV GOSUMDB=sum.golang.org
ENV GOTOOLCHAIN=auto

# Copy go mod files from the actual app location
COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./

# Download dependencies with retries
RUN go mod download || \
    (sleep 5 && go mod download) || \
    (sleep 10 && go mod download)

# Copy the entire application source
COPY Server/MuchToDo/ ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/muchtodo ./cmd/api/main.go

# Copy entrypoint script to /app
COPY Server/MuchToDo/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Stage 2: Runtime Stage
FROM alpine:3.19

# Install ca-certificates for HTTPS requests and tzdata for timezone
RUN apk --no-cache add ca-certificates tzdata wget

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy the binary and entrypoint from builder
COPY --from=builder /app/muchtodo .
COPY --from=builder /app/entrypoint.sh .

# Copy timezone data
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the entrypoint script
CMD ["./entrypoint.sh"]
