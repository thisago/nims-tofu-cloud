# Use the official Nim image as the base
FROM nimlang/nim:2.2.2-alpine-regular

# Copy sources
COPY . /app/
WORKDIR /app

# Build the project
RUN nimble build_release

# Clean
# Remove unnecessary files to reduce image size
RUN rm -rf /app/src /app/nims_tofu_cloud.nimble /tmp
# Remove the Nim compiler and other build tools
RUN apk del git mercurial openssl g++ curl tar xz nodejs
RUN rm -rf /nim/ /root/.nimble

# Set the entrypoint
ENTRYPOINT ["/app/build/nims_tofu_cloud"]

# Expose the port
EXPOSE 5000
