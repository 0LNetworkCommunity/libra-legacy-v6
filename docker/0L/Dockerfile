# Toolchain (Rust) image
FROM ubuntu:20.04 AS toolchain

ARG DEBIAN_FRONTEND=noninteractive

# Install system prerequisites
RUN apt-get update -y -q && apt-get install -y -q \
  build-essential \
  curl \
  cmake \
  clang \
  git \
  libgmp3-dev \
  libssl-dev \
  llvm \
  lld \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo libraries
RUN cargo install toml-cli
RUN cargo install sccache

# Builder image
FROM toolchain as builder

WORKDIR /libra

# Clone given release tag or branch of this repo
ARG TAG=v5.0.6
# Fixme(nourspace): depending where these tools are hosted, we might not need to pull
RUN git clone --branch ${TAG} --depth 1 https://github.com/OLSF/libra.git /libra

# Build 0L binaries
RUN RUSTC_WRAPPER=sccache make bins

# Production image
# Todo(nourspace): find a smaller base image
FROM ubuntu:20.04 AS prod

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  curl \
  libssl1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/0L/bin:${PATH}" \
  # Capture backtrace on error
  RUST_BACKTRACE="1"

WORKDIR /0L

# Copy binaries from builder
COPY --from=builder [ \
  "/libra/target/release/tower", \
  "/libra/target/release/diem-node", \
  "/libra/target/release/db-restore", \
  "/libra/target/release/db-backup", \
  "/libra/target/release/db-backup-verify", \
  "/libra/target/release/ol", \
  "/libra/target/release/txs", \
  "/libra/target/release/onboard", \
  "/0L/bin/" \
]
