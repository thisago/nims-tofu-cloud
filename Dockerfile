# Build stage
FROM nimlang/nim:2.2.2-alpine-regular AS builder

# Install build dependencies and tini
RUN apk add --no-cache git curl gcc g++ make tini

# Copy sources
COPY . /app/
WORKDIR /app

# Build the project
RUN nimble build_release

# Runtime stage
FROM alpine:3.18

# Copy tini from the builder stage
COPY --from=builder /sbin/tini /sbin/tini

# Copy the built binary from the builder stage
COPY --from=builder /app/build/nims_tofu_cloud /app/nims_tofu_cloud

# Set the entrypoint through tini
ENTRYPOINT ["/sbin/tini", "--", "/app/nims_tofu_cloud"]

# Expose the port
EXPOSE 5000
