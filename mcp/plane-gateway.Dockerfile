# Plane MCP gateway: stdio -> shared Streamable HTTP endpoint.
#
# Why a bridge instead of Plane's own `http` mode:
# plane-mcp-server's HTTP mode builds an OAuth provider unconditionally
# (`oauth_mcp = get_oauth_mcp(...)` in plane_mcp/__main__.py) *before* mounting the
# API-key route, and raises `ValueError: client_id is required` when
# PLANE_OAUTH_PROVIDER_CLIENT_ID is unset. Plane Community Edition cannot register
# an OAuth app, so its /http/api-key/mcp endpoint is unreachable and the process
# never binds. stdio mode works fine with just a personal access token, so we run
# stdio behind supergateway, which holds the token in its own environment and
# exposes one HTTP endpoint for every MCP client on the host.

FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# uv/uvx to run the (Python) Plane MCP server
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && ln -sf /root/.local/bin/uv  /usr/local/bin/uv \
 && ln -sf /root/.local/bin/uvx /usr/local/bin/uvx

# supergateway: stdio -> Streamable HTTP
RUN npm install -g supergateway

# Hardlinks are unavailable across some docker storage drivers
ENV UV_LINK_MODE=copy \
    PLANE_BASE_URL=http://proxy

EXPOSE 8091

HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8091/healthz || exit 1

# PLANE_API_KEY and PLANE_WORKSPACE_SLUG come from ./mcp.env at runtime and are
# inherited by the spawned stdio server.
ENTRYPOINT ["supergateway", \
  "--stdio", "uvx plane-mcp-server stdio", \
  "--outputTransport", "streamableHttp", \
  "--port", "8091", \
  "--streamableHttpPath", "/mcp", \
  "--healthEndpoint", "/healthz"]
