FROM ubuntu:20.04 AS builder

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

# Download Task binary
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -b /usr/local/bin

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo libraries
RUN cargo install toml-cli
RUN cargo install sccache

WORKDIR /libra

# Clone main branch of this repo
# Fixme(nourspace): depending where these tools are hosted, we might not need to pull
RUN git clone -b main --single-branch https://github.com/OLSF/libra.git /libra

# Build binaries
RUN RUSTC_WRAPPER=sccache make bins

# Production image
# Todo(nourspace): find a smaller base image
FROM ubuntu:20.04 AS prod

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  libssl1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/0L/bin:${PATH}"

# Copy binaries from builder
RUN mkdir -p /0L/bin
COPY --from=builder /libra/target/release/tower /0L/bin
COPY --from=builder /libra/target/release/diem-node /0L/bin
COPY --from=builder /libra/target/release/db-restore /0L/bin
COPY --from=builder /libra/target/release/db-backup /0L/bin
COPY --from=builder /libra/target/release/db-backup-verify /0L/bin
COPY --from=builder /libra/target/release/ol /0L/bin
COPY --from=builder /libra/target/release/txs /0L/bin
COPY --from=builder /libra/target/release/onboard /0L/bin
COPY --from=builder /usr/local/bin/task /usr/local/bin

WORKDIR /0L

COPY Taskfile.node.yml Taskfile.yml

ENTRYPOINT [ "task" ]

# Capture backtrace on error
ENV RUST_BACKTRACE 1
