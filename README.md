# Self-hosted SDLC stack

A Docker Compose workspace for running Gitea, Plane, Outline, and local MCP gateways together on a Docker network. The MCP endpoints bind to loopback so they are available to tools on the host without being exposed directly to the network.

## Services

| Service | Local address | Purpose |
| --- | --- | --- |
| Gitea | <http://localhost:3000> | Git hosting and issue management |
| Plane | <http://localhost:8080> | Projects and boards |
| Outline | <http://localhost:8888> | Wiki and knowledge base |
| Dex | <http://localhost:5556> | Local OIDC provider for Outline |
| Gitea MCP | <http://127.0.0.1:8090/mcp> | MCP access to Gitea |
| Plane MCP | <http://127.0.0.1:8091/mcp> | MCP access to Plane |
| Outline MCP | <http://127.0.0.1:8092/mcp> | MCP access to Outline |

## Requirements

- Docker Engine and the Docker Compose plugin
- API tokens for any MCP services you intend to use

## Setup

1. Clone this repository and copy `.env.example` to `.env`, `mcp.env.example` to `mcp.env`, and `dex-config.example.yml` to `dex-config.yml`.
2. Set unique URL-safe random values in `.env` and add tokens for the MCP services you use to `mcp.env`. These local files are excluded by `.gitignore`.
3. Set the Dex static client secret in `dex-config.yml` to the same value as `DEX_CLIENT_SECRET` in `.env`, and add a Dex password user with your own bcrypt password hash.
4. Start the stack with `docker compose up -d`.
5. Open the service addresses above. On the first Gitea registration, create the account that will administer the instance.

To stop the services, run `docker compose down`. Add `-v` only when you intend to permanently remove the named database and file storage volumes.

## Credentials and publishing

Never commit `mcp.env`, `.env`, `dex-config.yml`, database credentials, signing keys, API tokens, or production identity provider credentials. Use the example files as templates and set unique random values before starting a copy. The local Dex template has no sample user or real client secret; configure both locally before using Outline login.

If any real credential has previously been committed or shared, revoke or rotate it. Removing a file from the latest revision does not remove it from Git history.

## MCP gateway notes

The gateways run inside the Compose network and publish ports only on `127.0.0.1`. Configure your MCP client to use the corresponding Streamable HTTP URL above. Plane runs its stdio server behind Supergateway because its HTTP mode requires OAuth configuration unavailable in the Community Edition.
