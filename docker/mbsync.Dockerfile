FROM alpine:3.20

RUN apk add --no-cache isync ca-certificates curl tini

RUN echo '#!/bin/sh' > /usr/local/bin/fetch-mail.sh && \
    echo 'set -e' >> /usr/local/bin/fetch-mail.sh && \
    echo 'mbsync -V -a -c /config/mbsync.rc' >> /usr/local/bin/fetch-mail.sh && \
    chmod +x /usr/local/bin/fetch-mail.sh

RUN echo '#!/bin/sh' > /etc/periodic/hourly/fetch-mail && \
    echo '/usr/local/bin/fetch-mail.sh' >> /etc/periodic/hourly/fetch-mail && \
    chmod +x /etc/periodic/hourly/fetch-mail

# One sync on start, then busybox crond in foreground
ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "/usr/local/bin/fetch-mail.sh; exec crond -f -L /dev/stdout"
