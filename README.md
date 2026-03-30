![Decodie](https://raw.githubusercontent.com/owenbush/decodie/main/assets/decodie-logo.png)

# Decodie DDEV Add-on

A DDEV add-on that integrates the Decodie learning companion into your local development environment.

## Requirements

- DDEV v1.22+

## Installation

```bash
ddev add-on get owenbush/decodie-ddev
ddev restart
```

The UI will be available at `https://decodie.SITENAME.ddev.site` (where SITENAME is your DDEV project name).

## Usage

```bash
ddev decodie            # Open in your browser
ddev decodie status     # Show entry statistics
ddev decodie cleanup    # Open the archival review page
ddev decodie help       # Show available commands
```

## Q&A Configuration

The Q&A feature requires authentication with Claude. Edit `.ddev/decodie/.env` and set one of the following:

### Option A: OAuth token (recommended -- uses your Claude subscription)

1. On your **host machine** (not inside DDEV), run: `claude setup-token`
2. Copy the token and add it to `.ddev/decodie/.env`:
   ```
   CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...
   ```
3. `ddev restart`

### Option B: API key

1. Get a key from [console.anthropic.com](https://console.anthropic.com/)
2. Add it to `.ddev/decodie/.env`:
   ```
   CLAUDE_API_KEY=sk-ant-...
   ```
3. `ddev restart`

## How It Works

The add-on runs the Decodie UI as a daemon inside the DDEV web container and uses Traefik for subdomain routing. No separate container is needed.

## Related Repositories

- [owenbush/decodie](https://github.com/owenbush/decodie) -- Main Decodie site
- [owenbush/decodie-ui](https://github.com/owenbush/decodie-ui) -- The learning companion UI
- [owenbush/decodie-skill](https://github.com/owenbush/decodie-skill) -- Claude Code skill for generating learning entries
