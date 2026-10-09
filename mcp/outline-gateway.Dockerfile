# Outline MCP gateway: native Streamable HTTP, no bridge required.
#
# outline-mcp-server (mmmeff/outline-mcp) supports streamable-http, sse and stdio.
# Running its default bin starts the HTTP/SSE server, so unlike Plane there is no
# need for a stdio->HTTP bridge.
#
# Auth: with OUTLINE_API_KEY set in the environment, HTTP clients need no headers
# (the server falls back to it). Clients may still override per request with
# x-outline-api-key / outline-api-key / Authorization: Bearer.
#
# Upstream requires Node.js v24 or higher.

FROM node:24-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g outline-mcp-server@5.8.5

# OUTLINE_API_URL is the API root of the self-hosted instance, i.e. <host>/api.
# The app is reached over the compose network by its service name.
ENV OUTLINE_MCP_HOST=0.0.0.0 \
    OUTLINE_MCP_PORT=8092 \
    OUTLINE_API_URL=http://sdlc-outline:3030/api

EXPOSE 8092

# Liveness only: any HTTP response proves the listener is up. There is no
# documented /healthz endpoint, so this deliberately does not use curl -f.
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -s -o /dev/null http://127.0.0.1:8092/ || exit 1

ENTRYPOINT ["outline-mcp-server"]
