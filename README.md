# Alex Game Jam

A portable Godot 4 project configured for browser builds (WebGL 2) and AI-assisted
development through a Godot MCP server.

The starter game displays **Hello, world!** and a counter starting at zero.
Click or tap **Count up!** to add one; refresh the browser to reset it.
The UI lives in `scenes/main.tscn`, with counter logic in `scripts/main.gd`.

## Quick start

The bootstrap keeps Godot, Node.js, the MCP server, export templates, and Godot's
user data under this repository. It does not require Homebrew or global npm
packages.

```sh
./scripts/bootstrap
./scripts/godot --editor
```

The first bootstrap downloads about 1.5 GB, mostly Godot's official export
template bundle. Downloads are pinned and checksum-verified. Later runs are
idempotent and reuse `.tools/cache`.

Supported bootstrap hosts:

- macOS (Apple silicon or Intel)
- Linux (ARM64 or x86-64)

## Commands

```sh
./scripts/godot --editor       # Open the project in Godot
./scripts/godot --path .       # Run the game
./scripts/export-web           # Build build/web/index.html
./scripts/serve-web            # Direct HTTPS on port 7777 using a Tailscale certificate
./scripts/verify               # Check tools, project import, and Web export
./scripts/godot-mcp            # Start the MCP server over stdio
```

Run `./scripts/export-web` before `./scripts/serve-web`. Do not open the exported
HTML directly from disk. Localhost HTTP works for development; remote Godot
Web builds require HTTPS (a browser secure context), even without threads.

### Share the preview over Tailscale

Install Tailscale, sign in, and enable **HTTPS Certificates** in the tailnet DNS
settings once (if not already enabled). Then:

```sh
./scripts/serve-web
```

Open the printed **`https://<machine>.<tailnet>.ts.net:7777`** URL from a permitted
tailnet device. Node serves HTTPS directly on **7777**. There is no proxy,
Tailscale Serve, Funnel, extra listener port, or per-browser certificate setup.
Tailnet rules and the host firewall must allow TCP 7777.

Do not use `http://<tailscale-ip>:7777` or an HTTP tailnet hostname to play:
although reachable, browsers do not consider these secure contexts and Godot
refuses to start. Tailscale's encrypted transport alone does not make HTTP a
browser secure context. Use the hostname, not a raw IP: certificates cover the
hostname only. Plain HTTP and HTTPS cannot be interchanged on this listener.

The script discovers this machine's DNS name and runs `tailscale cert` at startup,
then refreshes the certificate and the live TLS context every 12 hours.
Certificates must have at least 24 hours of validity; provisioning/renewal errors
are surfaced, never silently downgraded to HTTP. Restart after resolving an error.
Certificates and private keys live in git-ignored `.tools/tls/`, with restricted
directory/key permissions. Never commit or copy private keys to another machine.
Certificate issuance publishes the machine hostname in public Certificate
Transparency logs, but does not make the game publicly reachable.

**Network exposure:** the default also makes this unauthenticated development
preview reachable on the LAN (and any other reachable IPv4 interface).
Keep it on trusted networks; do not forward it from a public router.
To restrict HTTPS to the Tailscale interface:

```sh
HOST="$(tailscale ip -4)" ./scripts/serve-web
```

Override the port with `PORT=8888 ./scripts/serve-web`. Stop the preview with
Ctrl+C; no separate sharing configuration remains to disable.

For local development without Tailscale or certificates:

```sh
HTTP_ONLY=1 ./scripts/serve-web
```

This explicit mode defaults to localhost HTTP (`http://127.0.0.1:7777`), which
browsers treat as secure for local testing. It is not a remote-play solution.
Bootstrap and Web export remain independent of Tailscale; launching the HTTPS
preview is the opt-in certificate provisioning step on each machine.

## VS Code and MCP

Open the repository in VS Code and accept the recommended Godot Tools extension.
The workspace MCP configuration in `.vscode/mcp.json` launches the pinned,
repo-local Godot MCP automatically. If VS Code was already open during
bootstrap, reload the window so it discovers the server.

The MCP can launch the editor, run the project, inspect debug output, and perform
common scene operations. Its launcher always points `GODOT_PATH` at the
repo-local engine. Bootstrap also applies pinned patched versions of the MCP SDK
and HTTP client, builds the server, and requires a clean production dependency
audit.

### Repo-scoped Copilot approvals

`.vscode/settings.json` stores the terminal auto-approval rules selected for this
project. They travel with a clone and are available before and after bootstrap;
bootstrap never copies them into user-level settings. Open this repo as the
VS Code workspace and review/trust it before enabling its restricted settings.
VS Code can still require an initial auto-approval confirmation or enforce
organization policy.

The list preserves the existing 10 approvals, including the repo-local Node/npm
commands; it does not enable blanket tool approval or auto-approve all MCP tools.
Node/npm approvals permit arbitrary arguments, so review changes to these rules
and the scripts they allow just as you would executable code.

For future rules, edit **Preferences: Open Workspace Settings (JSON)**, or choose
workspace scope in an approval prompt when offered. Do not choose user/global
scope. Review and include `.vscode/settings.json` in your next Git commit.
MCP server trust and non-terminal tool confirmations may still be per-user;
these terminal rules do not bypass those confirmations.

## Portability

Only source and configuration are committed. Generated directories are ignored:

- `.tools/` contains downloaded toolchains, isolated Godot editor data, export
  templates, and the MCP checkout.
- `.godot/` contains imported project assets.
- `build/` contains exports.

Clone the repository on another supported computer and run
`./scripts/bootstrap` to recreate the same versions. Upgrade pins and checksums
in `tools/versions.env`; do not edit generated files under `.tools/`.

The Web preset uses Godot's Compatibility renderer and the non-threaded Web
template for broad hosting compatibility. This avoids requiring cross-origin
isolation headers. Web exports target WebGL 2, as required by Godot 4.
