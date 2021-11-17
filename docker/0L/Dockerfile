FROM ubuntu:20.04

# Todo (nourspace): Add user, create home dir, chmod, etc
# Todo (nourspace): Pass $OL_ROOT_DIR as env to be used in (ol, tower, ...) commands as --config $OL_ROOT_DIR/0L.toml
ENV PATH="${PATH}:~/aliases" \
    OL_ROOT_DIR="~/.0L" \
    OL_CONFIG="${OL_ROOT_DIR}/.0l.toml"

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Install 0L built binaries [Easy Mode]
# https://github.com/OLSF/libra/blob/main/ol/documentation/node-ops/validators/validator_onboarding_easy_mode.md
RUN curl -sL https://raw.githubusercontent.com/OLSF/libra/main/ol/util/install.sh | bash

# Fixme (nourspace): this is an ugly way of overriding the binaries...
# Replaces binaries with scripts that allow setting flags using env vars.
# For example: `ol` becomes `ol --config $OL_CONFIG`
COPY aliases/* /root/aliases/

CMD ["/bin/bash"]
