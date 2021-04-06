FROM mcr.microsoft.com/vscode/devcontainers/rust:1

# Install extra packages specified in ../util/setup.sh
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends build-essential cmake clang llvm secure-delete lld
