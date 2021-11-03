# 0L Desktop Wallet and Miner

- [x] create new keys & mnemonic
- [x] initialize local files user-wizard, val-wizard
- [x] dev mode, to connect to a swarm (bonus: app can start-up a swarm, and shut down).
- [ ] create new account
- [ ] import existing mnemonic (create block 0 if necessary)
- [ ] ability to start 'miner' and send proofs (send to swarm in dev mode)
- [x] ability to send common txs: create account, upgrade, rotate keys (multiple accounts?)
- [ ] include all web-monitor views
- [ ] ability to upgrade (tauri self updater)
- [ ] display help content from a github-hosted markdown file.

# Tauri Svelte App Template

This is a project template for [Tauri](https://tauri.studio) and [Svelte](https://svelte.dev) apps. It lives at https://github.com/jbarszczewski/tauri-svelte-template.

To create a new project based on this template follow the official guide here: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template

## Get started

### Dependencies

- NodeJS version 16
- Yarn
- Rust (version will install on its own)

Before using template please see [Tauri Introduction](https://tauri.studio/en/docs/getting-started/intro) and follow instructions to setup your environment.

Install the dependencies...

First Rust:
```
cd src-tauri/
cargo build

```

Then Javascript:

```bash
yarn
```

...then start development server:

```bash
yarn tauri dev
```

This will take care of running both frontend and backend of your app with watch attached to both. That means whenever you change something in `src` (svelte frontend code) or `src-tauri` (rust backend code), it will be automatically processed and hot reloaded. To finish dev/debug mode simply close the app window.

## Building and running in production mode

To create an optimised version of the app:

```bash
yarn tauri build
```

This will create standalone app and installer in `src-tauri/target/release` directory.

## Useful links

-   [Tauri](https://tauri.studio)
-   [Svelte](https://svelte.dev)
-   [Sveltestrap](https://sveltestrap.js.org)

