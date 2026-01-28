# Claude Plugins Marketplace

A collection of Claude Code plugins by etcworld.

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [task-manager](./plugins/task-manager) | AI task lifecycle management with session continuity | 1.2.1 |

## Installation

### Add Marketplace

```bash
claude plugin marketplace add etcworld/claude-plugins
```

### Install Plugins

```bash
# Install task-manager
claude plugin install task-manager@etcworld-plugins
```

## Updating

### Update Plugins

```bash
# Update specific plugin
/plugins update task-manager

# Update all plugins from all marketplaces
/plugins update
```

### Cache Issues

If `/plugins update` doesn't fetch the latest version, the marketplace cache may be stale. Remove and re-add the marketplace:

```bash
claude plugin marketplace remove etcworld-plugins
claude plugin marketplace add etcworld/claude-plugins
```

Then reinstall plugins if needed:

```bash
claude plugin install task-manager@etcworld-plugins
```

## Plugin: task-manager

AI-powered task lifecycle management with session continuity.

### Commands
- `/task-manager:create` - Create a new task
- `/task-manager:continue` - Resume existing task
- `/task-manager:complete` - Complete and archive task
- `/task-manager:idea` - Quick capture to backlog
- `/task-manager:sync` - Sync index with folders

### Features
- Session continuity across Claude Code sessions
- Jira integration for task import
- Idea backlog management
- Automatic index synchronization

See [task-manager README](./plugins/task-manager/README.md) for detailed documentation.

## Repository Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace manifest
├── plugins/
│   └── task-manager/        # Task manager plugin
│       ├── .claude-plugin/
│       │   └── plugin.json  # Plugin manifest
│       ├── commands/        # Plugin commands
│       ├── skills/          # Auto-triggered skills
│       ├── templates/       # Task & idea templates
│       └── README.md
└── README.md
```

## Contributing

1. Fork the repository
2. Create your plugin in `plugins/your-plugin/`
3. Add to marketplace.json
4. Submit a pull request

## License

MIT

## Author

etcworld (etcworld@gmail.com)
