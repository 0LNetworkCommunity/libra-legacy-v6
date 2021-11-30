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

# Clone main branch of this repo
# Fixme(nourspace): depending where these tools are hosted, we might not need to pull
RUN git clone -b main --single-branch https://github.com/OLSF/libra.git /libra

# Build 0L binaries
RUN RUSTC_WRAPPER=sccache make bins

# Download web files
RUN make web-files

# Production image
# Todo(nourspace): find a smaller base image
FROM ubuntu:20.04 AS prod

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  curl \
  libssl1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*


ENV OL_DIR="/root/.0L" \
  PATH="/root/.0L/bin:${PATH}"

WORKDIR /root/.0L

# Fixme(nourspace): user better logging method Create logs dir
RUN mkdir /root/.0L/logs

# Copy binaries from builder
RUN mkdir -p /0L/bin
COPY --from=builder [ \
  "/libra/target/release/tower", \
  "/libra/target/release/diem-node", \
  "/libra/target/release/db-restore", \
  "/libra/target/release/db-backup", \
  "/libra/target/release/db-backup-verify", \
  "/libra/target/release/ol", \
  "/libra/target/release/txs", \
  "/libra/target/release/onboard", \
  "${OL_DIR}/bin/" \
]

# Copy web-files
COPY --from=builder ["/root/.0L/web-monitor", "${OL_DIR}/web-monitor"]

# Fixme (noursapce): unzip can't be used with tars
# RUN ol serve --update

# Download Task binary
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -b /usr/local/bin

COPY Taskfile.node.yml Taskfile.yml

ENTRYPOINT [ "task" ]

# Capture backtrace on error
ENV RUST_BACKTRACE 1
