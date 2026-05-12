# 🎨 AI Image Generation Skill

> Generate images on-the-fly from your coding workflow — powered by OpenAI or Google Gemini.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-supported-6f42c1)](https://www.anthropic.com/claude-code)
[![GitHub Copilot CLI](https://img.shields.io/badge/GitHub%20Copilot%20CLI-supported-24292f?logo=github)](https://github.com/github/copilot-cli)

An AI agent skill that gives your coding assistant the ability to generate images. Just ask — the skill handles provider selection, API key setup, and image generation conversationally.

## ✨ Features

- **Two providers:** OpenAI (`gpt-image-2`) and Google Gemini (Nano Banana)
- **Zero config up front** — the skill onboards you the first time you use it
- **No wrapper scripts** — the AI agent reads the skill and handles everything directly
- **Works with** Claude Code CLI and GitHub Copilot CLI

## 🚀 Install

```bash
git clone https://github.com/your-username/skill-image-gen.git
cd skill-image-gen
./install.sh
```

<details>
<summary>Manual install</summary>

```bash
# Claude Code
mkdir -p ~/.claude/skills/generate-image
cp generate-image/SKILL.md ~/.claude/skills/generate-image/

# GitHub Copilot CLI
mkdir -p ~/.copilot/skills/generate-image
cp generate-image/SKILL.md ~/.copilot/skills/generate-image/
```

</details>

<details>
<summary>Installer flags</summary>

| Flag | Description |
|---|---|
| `--claude-only` | Install for Claude Code only |
| `--copilot-only` | Install for Copilot CLI only |
| `--link` | Symlink instead of copy (for development) |
| `--uninstall` | Remove installed skill |
| `--dry-run` | Preview what would happen |

</details>

## 💬 Usage

Just ask your AI assistant to generate an image:

- *"Generate a hero image for my landing page"*
- *"Create a seamless grass texture for my game"*
- *"Make an app icon for a weather app"*

The skill takes care of the rest — including walking you through API key setup if it's your first time.

## 📁 Structure

```
skill-image-gen/
├── generate-image/
│   └── SKILL.md        # The skill — all logic lives here
├── install.sh
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

MIT — see [LICENSE](LICENSE).
