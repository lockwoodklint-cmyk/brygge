# brygge

**Chat with Claude Code directly inside your Obsidian notes.**

`brygge` watches your Obsidian vault. Type your message in any note, end it with `@claude` on its own line, save — and Claude answers you inline, right in the note.

```markdown
So the transport layer is point-to-point, and the network layer is end-to-end
because it's only read by the sender and receiver, not by the routers in
between. Sound right?

@claude
```

...becomes (a few seconds later):

```markdown
So the transport layer is point-to-point, and the network layer is end-to-end
because it's only read by the sender and receiver, not by the routers in
between. Sound right?

**Brygge:**

> [!warning] Correction
> **You wrote:** transport is point-to-point, network is end-to-end
> **Correct:** it's the other way around — transport is end-to-end (only endpoints see it), network is hop-by-hop (every router reads the IP header).

---

```

No context switching. No copy-paste. Your notes stay yours; Claude just answers where you're already thinking.

---

## Why

I take a lot of notes in Obsidian and often want a quick fact-check or sanity-check without leaving the note. Copying into a chat app breaks flow. `brygge` gives Claude a seat at the table without owning the table.

The name is Norwegian for *pier* / *bridge* — a bridge between your notes and Claude.

## How it works

1. `fswatch` monitors your vault for changes in `.md` files
2. When a save contains `@claude` on its own line, `brygge` spawns Claude Code (`claude -p`)
3. Claude reads the file, finds the trigger, edits the note in place with its answer
4. The trigger disappears; the reply takes its spot

It uses your existing Claude Code / Claude Max subscription — no separate API key.

## Requirements

- macOS or Linux
- [Claude Code CLI](https://docs.anthropic.com/claude-code) authenticated
- [`fswatch`](https://github.com/emcrisostomo/fswatch) (`brew install fswatch`)
- Bash 4+
- An Obsidian vault (or any folder of markdown files, honestly)

## Install

```bash
git clone https://github.com/YOUR_USERNAME/brygge.git
cd brygge
./install.sh
```

The installer:
- Symlinks `bin/brygge` into `~/bin/`
- Copies `examples/preferences.md` into your vault at `Claude Memory/brygge-preferences.md` (skipped if it exists)
- Adds an autostart line to your `~/.zshrc` or `~/.bashrc`

Then either restart your shell or run:

```bash
brygge &
```

## Configure

`brygge` reads config from environment variables or `~/.config/brygge/config`:

| Variable | Default | Purpose |
|---|---|---|
| `BRYGGE_VAULT` | `~/Documents/Obsidian Vault` | Path to your vault |
| `BRYGGE_TRIGGER` | `@claude` | Word that triggers a response |
| `BRYGGE_PREFERENCES` | `Claude Memory/brygge-preferences.md` | Path to the preferences file (relative to vault) |
| `BRYGGE_ASSISTANT_NAME` | `Brygge` | What the assistant calls itself |
| `BRYGGE_TIMEOUT` | `300` | Kill Claude after this many seconds |
| `BRYGGE_STATE_DIR` | `~/.local/state/brygge` | Log, lock, and pid files live here |

Example config file:

```bash
# ~/.config/brygge/config
BRYGGE_VAULT="$HOME/notes"
BRYGGE_TRIGGER="@ai"
BRYGGE_ASSISTANT_NAME="Kai"
```

## Customize responses

The preferences file (`Claude Memory/brygge-preferences.md` by default) is read on every response. Edit it to change tone, formatting, or role — no restart needed.

See [`examples/preferences.md`](examples/preferences.md) for a starting template. Mine tells Brygge to:

- Always use Obsidian callouts (`> [!warning]`, `> [!success]`, etc.) for visual structure
- Be a *fact-checker*, not a tutor (I have a separate agent for teaching)
- Ignore typos and small imprecisions; only react to real misunderstandings
- Keep answers short — max 2–4 sentences unless it's a correction

## Trigger rules

The trigger must be on **its own line** — no spaces, no other text. This avoids false positives.

Everything between the previous `---` (or the top of the file) and the trigger line is treated as your message.

If the trigger doesn't disappear from your note within ~10 seconds, check the log:

```bash
tail -f ~/.local/state/brygge/brygge.log
```

## What it doesn't do

- It doesn't keep conversation history across triggers — each `@claude` is a fresh session. Add a `## Context` heading with what you want remembered.
- It doesn't stream responses — the whole answer appears at once when Claude finishes.
- It doesn't work on locked/read-only files.

## Costs

`brygge` uses whatever plan your `claude` CLI is authenticated with. If you're on a Claude Max subscription, that's it — no extra cost. If you're on pay-per-token API keys, each `@claude` costs whatever a normal Claude Code turn costs.

## Uninstall

```bash
./uninstall.sh
```

Or manually: remove `~/bin/brygge`, remove the autostart line from your shell rc file, delete `~/.local/state/brygge/`.

## License

MIT. See [LICENSE](LICENSE).

## Not affiliated with

Anthropic, Obsidian, or anyone else. This is a personal side project.
