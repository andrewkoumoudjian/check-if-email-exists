FROM rust:1.74-slim as builder

WORKDIR /app

# Install dependencies for compilation
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Copy the source code
COPY src ./src

# Build the application
RUN cargo build --release

# Create a slim runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates libssl1.1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/target/release/check-if-email-exists ./

# Expose the port
EXPOSE 8080

# Set environment variables
ENV RUST_LOG=info
ENV RCE_HTTP_HOST=0.0.0.0
ENV RCE_HTTP_PORT=8080

# Run the application
CMD ["./check-if-email-exists"]
