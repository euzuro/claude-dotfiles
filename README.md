# Claude Dotfiles

Personal configuration files for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Structure

```
.
├── CLAUDE.md       # Global behavior instructions
├── settings.json   # Settings and permissions
├── commands/       # Custom slash commands/skills
└── scripts/        # Helper scripts used by commands
```

## Installation

Clone the repository and symlink the files to `~/.claude/`:

```bash
# Clone the repo
git clone git@github.com:euzuro/claude-dotfiles.git ~/dd/claude-dotfiles

# Backup existing config (if any)
mv ~/.claude/settings.json ~/.claude/settings.json.bak
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak

# Create symlinks
ln -sf ~/dd/claude-dotfiles/settings.json ~/.claude/settings.json
ln -sf ~/dd/claude-dotfiles/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dd/claude-dotfiles/commands ~/.claude/commands
ln -sf ~/dd/claude-dotfiles/scripts ~/.claude/scripts
```

## Custom Commands

Add custom slash commands as markdown files in the `commands/` directory. Each file becomes available as `/<filename>` in Claude Code.

Example: `commands/pr.md` becomes available as `/pr`
