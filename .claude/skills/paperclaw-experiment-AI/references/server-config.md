# Server Configuration Format (server.md)

`./experiment/server.md` is entirely **user-owned**. The skill never writes to it. It contains only `## Connection <name>` blocks — one per server.

## Connection Block Fields

| Field | Required | Description |
|-------|----------|-------------|
| `Host` | Yes | `user@hostname` or `user@IP` |
| `Port` | Yes | SSH port (default: 22) |
| `Working Directory` | Yes | Remote working directory for experiments |
| `Activation` | Optional | venv activation command. Default: `source <Working Directory>/.venv/bin/activate`. Override if venv is elsewhere. |
| `Password` | Optional | SSH password. Omit if using key-based auth. When present, used as `sshpass -p '<Password>' ssh ...` |
| `Note` | Optional | Free-form user note about this server. Never overwritten by the skill. |

All hardware, scheduling, and status data is stored exclusively in `state.md`.

## Full server.md Format

```markdown
# Experiment Server Configuration

<!--
  ADD A SERVER: Copy a ## Connection <name> block, fill in Host/Port/Working Directory.
  REMOVE A SERVER: Delete the ## Connection <name> block entirely.
  The skill detects changes automatically on next startup.
-->

## Connection main
- Host: alice@gpu1.example.com
- Port: 22
- Working Directory: /home/alice/paperclaw-experiments

## Connection gpu2
- Host: bob@192.168.1.42
- Port: 2222
- Working Directory: /data/bob/experiments
- Password: mypassword123
- Note: Personal server, usually idle. Slow SSD — avoid large dataset downloads.

## Connection local
- Host: alice@localhost
- Port: 22
- Working Directory: /home/alice/PaperClaw/experiment/codebase
- Activation: source /home/alice/PaperClaw/experiment/codebase/.venv/bin/activate
- Note: Local machine — apply nice/taskset/ulimit on all jobs.
```

## Rules for Adding/Removing Servers

**To add a server**: Append a new `## Connection <name>` block with `Host`, `Port`, `Working Directory` filled in. Tell the skill "I've updated server.md" — it will probe the new server and populate its hardware data in state.md.

**To remove a server**: Delete its `## Connection <name>` block. The skill detects the removal at the next startup or when told "I've updated server.md" — it immediately removes that server from the Servers table, GPU Slots, and Server Details in state.md and stops scheduling jobs to it.
