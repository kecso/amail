FROM debian:bookworm-slim

ENV NOTMUCH_PATH=/app/mail
ENV PATH=/opt/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    python3-venv \
    python3-pip \
    python3-notmuch \
    notmuch \
    rsync \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Venv: use Debian's notmuch Python bindings (pip notmuch is not compatible with Python 3.12+)
RUN python3 -m venv --system-site-packages /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir netviel gunicorn

ENV NOTMUCH_CONFIG=/app/notmuch-config
COPY docker/netviel/run.sh /usr/local/bin/run.sh
COPY docker/netviel/notmuch-config /app/notmuch-config
RUN chmod +x /usr/local/bin/run.sh

WORKDIR /app
EXPOSE 5000
VOLUME ["/app/mail"]
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/run.sh"]
