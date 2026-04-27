# amail

**amail** is a small, self-hostable **Maildir archive browser** based on [netviel](https://github.com/DavidMStraub/netviel) and [notmuch](https://notmuchmail.org/): you point the container at a **Maildir** tree on the host, it keeps a private working copy and a **notmuch** index, and serves a web UI (port **5000**) to search and read mail—no IMAP server on top. It follows the **netviel half** of the flow described in the article below.

**Original write-up (concept and design):** [Simple Email Archival and Indexing](https://www.richyhbm.co.uk/posts/2023/simple-email-archive/) (Richy HBM, 2023). That post also used **mbsync** in Docker; in this repo the **default** is **netviel only** so you can keep **mbsync on bare metal** (or any other IMAP → Maildir sync) and only run the browser in Portainer. An **optional** compose file still wires up **mbsync + netviel** if you want the two-container story.

## What you get

| Piece | Role |
|--------|------|
| **netviel** (default) | Rsyncs from your read-only Maildir mount, runs `notmuch new`, serves the UI on **5000** |
| **mbsync** (optional) | Only if you use `docker-compose.with-mbsync.yml` — IMAP → Maildir inside Docker |

The netviel service keeps the mounted archive **read-only** and stores the notmuch database in a **separate volume** (`/app/mail/.notmuch`) so the source tree on disk stays a clean copy of what your real sync produced.

**Host install of notmuch?** **No.** The index path on the host is just an **empty directory** you choose (e.g. `mkdir -p /var/lib/amail-notmuch`); the container runs `notmuch` and **creates** the `.notmuch` database on first start. The bind mount only **persists** that data between container recreations.

**Security:** netviel is for **private/trusted** networks. Do not expose it to the public internet without auth and TLS in front (reverse proxy, VPN, or both). The [upstream project](https://github.com/DavidMStraub/netviel#requirements) says the same.

## Quick start (netviel only, local build)

1. Point Compose at the Maildir your host already maintains (e.g. where **mbsync** writes), or use `./storage/mail` for a local test tree.
2. From the repo root:

   ```bash
   docker compose build
   docker compose up -d
   ```

3. Open `http://localhost:5000` after that directory contains mail (and after the first `notmuch new` in the container has run).

**Compose file:** `docker-compose.yml` (single `netviel` service).  
**Optional mbsync in Docker:** `docker-compose.with-mbsync.yml` — also copy `config/mbsync/mbsync.rc.example` to `config/mbsync/mbsync.rc` and run:

```bash
docker compose -f docker-compose.with-mbsync.yml up -d
```

## Pre-built image (GitHub Container Registry)

CI publishes the **netviel** image (and, for the optional stack, **mbsync**), for example:

- `ghcr.io/<github-username>/amail-netviel:latest`  
- `ghcr.io/<github-username>/amail-mbsync:latest` (only needed for `docker-compose.with-mbsync.yml`)

Tags also include the branch name and a short **git SHA** (e.g. `sha-abc1234`) so you can **pin a stack to an exact commit** in Portainer.

**Package visibility:** GitHub → *Packages* → each package → *Package settings* → *Public* (or `docker login ghcr.io` on the host) if you want unauthenticated pulls.

## Portainer (bare-metal mbsync + container netviel)

1. Push the repo to GitHub and let Actions build **amail-netviel** (or run the workflow by hand).  
2. Add a **stack** from `compose.portainer.example.yml`: set the host path to your **existing Maildir** (`/mail:ro` in the file) and a path for the **notmuch** index, and replace `YOUR_GH_USER`. You only need the **netviel** image.  
3. To pin, use a tag like `sha-…` instead of `latest`.

The optional two-image stack (mbsync + netviel) is in `compose.portainer.with-mbsync.example.yml`.

## Upstream and credits

- **Article / idea:** <https://www.richyhbm.co.uk/posts/2023/simple-email-archive/>
- **Web UI:** [DavidMStraub/netviel](https://github.com/DavidMStraub/netviel) (MIT)
- **Index / search:** [notmuch](https://notmuchmail.org/)
- **Sync (optional in Docker):** [isync / mbsync](https://isync.sourceforge.io/)

## License

The Docker and compose files in this repository are [MIT](LICENSE) unless you prefer otherwise. **netviel** and other upstream projects keep their own licenses.
