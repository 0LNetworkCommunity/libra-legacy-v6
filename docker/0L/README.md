# 0L Docker

This is an updated collection of Docker and Docker-Compose files that make use of the latest 0L binaries and guides.

> This is a work in progress, and the role of this file is to help to navigate the development.
> nourspace

## Goals

- Easily create account and get onboarded
- Easily run tower, full-node, and validator on a VPS that has Docker installed
- Ability to use custom upstream ips, data directory, etc
- Logging visibility

## Requirements

- VPS with Docker 19+ installed
- [Task](https://taskfile.dev/#/installation)
- Internet connection
- Dedicated IP with opened ports

## How to

### Build and run base image

```bash
# While in ./docker/0L
task docker:build

# Shell
task docker:shell
```

### Use Docker-Compose

WIP

## Todos

### Questions

- [x] Easy or Hard?
  > Hard as we need to build binaries, `ol start` requires proper onboarding which won't be the case
- [x] Build from source or binaries?

### Docker

- [x] Find good base image: `ubuntu:20.04`
- [x] Use easy mode instructions wherever possible?
  - ~~Using binaries for now~~
  - Moved to hard mode
- [ ] Allow passing configs: data directory, config, and other flags
      ~~I used an ugly way of creating alias scripts~~
  - Docker-Compose will allow mounting data paths easily so `--config` might not be needed
- [ ] Open and bind correct ports
- [ ] Security
  - [ ] use non-root user
  - [ ] what else?

### Compose

- [ ] Create docker-compose files to facilitate different scenarios
  - [ ] utils: onboarding
  - [ ] fullnode: running a fullnode
  - [ ] tower: running a miner
  - [ ] validator: running a validator

### Deployment

- Create a temporary image and host it on own Dockerhub
- Update CI to build image

### Cleanups

- [ ] Squash and remove unnecessary commits
- [ ] Optimise RUN commands and follow Docker best practices
- [ ] Update this README
