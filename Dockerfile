# syntax=docker/dockerfile:1.7

# Build stage: compile a static Linux binary
FROM golang:1.26-alpine AS builder
WORKDIR /src

# Cache module downloads in their own layer
COPY go.mod ./
RUN go mod download

# Build a stripped static binary (CGO off, no symbol/debug info)
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/api .

# Runtime stage: distroless, no shell, runs as non-root
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /out/api /api
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/api"]
