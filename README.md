# amail

**amail** is a small, self-hostable **mail backup + browser** stack: [mbsync](https://isync.sourceforge.io/mbsync.html) (isync) pulls mail from IMAP into **Maildir**, and [netviel](https://github.com/DavidMStraub/netviel) (with [notmuch](https://notmuchmail.org/)) provides a **web UI** to search and read that archive—without running a full IMAP server on top. It follows the same pattern described in the article below.

**Original write-up (concept and design):** [Simple Email Archival and Indexing](https://www.richyhbm.co.uk/posts/2023/simple-email-archive/) (Richy HBM, 2023). This repository packages that idea as two production-ready images plus Compose for local use and CI-built images for **Portainer** (or any registry-driven stack).

## What you get

| Piece | Role |
|--------|------|
| **mbsync** | Periodically syncs IMAP → Maildir on disk |
| **netviel** | Rsyncs a working copy, runs `notmuch new`, serves the UI on port **5000** |

The netviel service keeps your mounted Maildir **read-only** and maintains the notmuch database on a **separate volume** (`/app/mail/.notmuch`) so the index is durable and the source tree stays a clean backup.

**Security:** netviel is intended for **private/trusted** networks. Do not expose it to the public internet without authentication and TLS in front (reverse proxy, VPN, or both). The [upstream project](https://github.com/DavidMStraub/netviel#requirements) says the same.

## Quick start (build locally)

1. Copy `config/mbsync/mbsync.rc.example` to `config/mbsync/mbsync.rc` and fill in IMAP + Maildir paths (Gmail and others: use an app password where required).
2. From the repo root:

   ```bash
   docker compose build
   docker compose up -d
   ```

3. Open `http://localhost:5000` after the first mbsync run has written mail into `./storage/mail`.

## Pre-built images (GitHub Container Registry)

Pushes to the default branch build and push two images, for example:

- `ghcr.io/<github-username>/amail-mbsync:latest`
- `ghcr.io/<github-username>/amail-netviel:latest`

Tags also include the branch name and a short **git SHA** (e.g. `sha-abc1234`) so you can **pin a stack to an exact commit** in Portainer.

**Package visibility:** in GitHub → *Packages* → each package → *Package settings*, set visibility to *Public* (or log in to GHCR from the host) if pulls should work without `docker login`.

## Portainer

1. Create the repo on GitHub under your user (e.g. `youruser/amail`) and push this project.
2. Let Actions run once so both images exist on GHCR (or use *Run workflow* on *Build and push container images*).
3. In Portainer, add a **stack** using `compose.portainer.example.yml` as a template: set host paths for `mbsync.rc`, mail, and notmuch, and replace `YOUR_GH_USER` with your GitHub name (lowercase). Optionally change image tags from `latest` to a **SHA tag** for reproducibility.

## Upstream and credits

- **Article / idea:** <https://www.richyhbm.co.uk/posts/2023/simple-email-archive/>
- **Web UI:** [DavidMStraub/netviel](https://github.com/DavidMStraub/netviel) (MIT)
- **Index / search:** [notmuch](https://notmuchmail.org/)
- **Sync:** [isync / mbsync](https://isync.sourceforge.io/)

## License

The Docker and compose files in this repository are [MIT](LICENSE) unless you prefer otherwise. **netviel** and other upstream projects keep their own licenses.
