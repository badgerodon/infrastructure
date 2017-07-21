# Infrastructure

## Helpers

### caddy

Build:

    docker build \
        -t gcr.io/badgerodon-prod/caddy:1.0 \
        -f images/caddy.dockerfile \
        .

Run:

    docker run \
        -i -t \
        -v $(pwd)/config/Caddyfile:/etc/Caddyfile \
        -p 2015:2015 \
        gcr.io/badgerodon-prod/caddy:1.0

