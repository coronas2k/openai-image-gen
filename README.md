# 🎨 AI Image Generation Skill

> Generate images on-the-fly from your coding workflow — powered by OpenAI or Google Gemini.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Bash-shell%20scripts-121011?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-supported-6f42c1)](https://www.anthropic.com/claude-code)
[![GitHub Copilot CLI](https://img.shields.io/badge/GitHub%20Copilot%20CLI-supported-24292f?logo=github)](https://github.com/github/copilot-cli)
[![OpenAI](https://img.shields.io/badge/OpenAI-gpt--image--1-412991?logo=openai)](https://platform.openai.com/)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-Nano%20Banana-4285F4?logo=google)](https://aistudio.google.com/)

`skill-image-gen` is a lightweight AI agent skill for generating images from the same chat you already use for coding. It targets **Claude Code CLI**, **GitHub Copilot CLI**, and future packaging for the **VS Code Marketplace**, while staying easy to inspect and customize with plain shell scripts.

## ✨ Features

- Two AI providers: **OpenAI** (`gpt-image-1`) and **Google Gemini** (Nano Banana-style workflows)
- Works with **Claude Code** and **GitHub Copilot CLI**
- Zero dependencies beyond **curl**, **python3**, and **base64**
- Guided onboarding — the skill walks you through API key setup
- Batch generation support for multiple images in parallel
- Configurable model, size, quality, and output format
- Minimal, curl-based shell scripts that are easy to inspect and extend
- MIT licensed and friendly to forks, custom setups, and local tweaks

## 🚀 Quick Start

### One-Line Install

```bash
git clone https://github.com/your-username/skill-image-gen.git
cd skill-image-gen
./install.sh
```

The installer auto-detects supported CLIs on your machine and installs the skill into the right location.

<details>
<summary><strong>Optional installer flags</strong></summary>

```bash
./install.sh --claude-only
./install.sh --copilot-only
./install.sh --link       # symlink for local development
./install.sh --uninstall  # remove installed skill
./install.sh --dry-run    # preview actions
```

</details>

### Manual Install

<details>
<summary><strong>Claude Code CLI</strong></summary>

```bash
# Copy skill to Claude's skill directory
mkdir -p ~/.claude/skills/generate-image
cp SKILL.md ~/.claude/skills/generate-image/
cp -R scripts ~/.claude/skills/generate-image/
```

Then restart Claude Code. The skill auto-activates when you ask to generate images.
</details>

<details>
<summary><strong>GitHub Copilot CLI</strong></summary>

```bash
# Copy skill to Copilot's skill directory
mkdir -p ~/.copilot/skills/generate-image
cp SKILL.md ~/.copilot/skills/generate-image/
cp -R scripts ~/.copilot/skills/generate-image/
```

Then restart Copilot CLI. The skill auto-activates when you ask to generate images.
</details>

## ⚙️ Configuration

### API Keys

| Provider | Environment Variable | Get Your Key |
|---|---|---|
| OpenAI | `OPENAI_API_KEY` | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| Google Gemini | `GEMINI_API_KEY` | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) |

Add the provider key you want to use to your shell profile:

```bash
# Add to ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="your-key-here"
export GEMINI_API_KEY="your-key-here"
```

> [!NOTE]
> You only need the key for the provider you want to use. If a key is missing, the skill surfaces setup guidance instead of failing silently.

<details>
<summary><strong>Reload your shell</strong></summary>

```bash
source ~/.zshrc
# or
source ~/.bashrc
```

</details>

The only runtime dependencies are `curl`, `python3`, and `base64`.

## 💬 Usage

Once the skill is installed, ask your AI assistant naturally:

- `Generate a hero image for my landing page`
- `Create a seamless grass texture for my game project`
- `Make an app icon for a weather app, flat design`
- `Generate a diagram showing microservice architecture`

You can also be more specific:

- `Use OpenAI and make it 1536x1024, high quality`
- `Use Gemini for a quick concept pass`
- `Generate three icon variations for a budgeting app`
- `Create a transparent-looking sticker style mascot illustration`

### Direct Script Usage

You can call the provider scripts directly for automation, testing, or CI-friendly workflows.

**OpenAI**

```bash
./scripts/generate-openai.sh \
  --prompt "A polished SaaS landing page hero illustration" \
  --output output/hero.png \
  --size 1536x1024 \
  --quality high \
  --format png
```

**Gemini**

```bash
./scripts/generate-gemini.sh \
  --prompt "A flat microservice architecture diagram" \
  --output output/diagram.png \
  --model gemini-2.0-flash-exp \
  --size wide \
  --quality clean
```

For more examples, see:

- [`examples/examples.md`](examples/examples.md) — prompt ideas by use case
- [`examples/PROVIDERS.md`](examples/PROVIDERS.md) — provider comparison and setup notes

### Parameters

<details>
<summary><strong>OpenAI Parameters</strong></summary>

| Flag | Required | Description | Default |
|---|---|---|---|
| `--prompt <text>` | Yes | Image description | — |
| `--output <path>` | Yes | Output file path | — |
| `--size <value>` | No | Image dimensions such as `1024x1024`, `1024x1536`, or `1536x1024` | `1024x1024` |
| `--quality <value>` | No | Quality level | `medium` |
| `--model <value>` | No | OpenAI image model | `gpt-image-1` |
| `--format <value>` | No | Output format: `png`, `jpeg`, or `webp` | `png` |
| `--help` | No | Show usage help | — |

**Example**

```bash
./scripts/generate-openai.sh \
  --prompt "Minimal app icon with blue gradient and cloud motif" \
  --output output/icon.webp \
  --size 1024x1024 \
  --quality high \
  --format webp
```

</details>

<details>
<summary><strong>Gemini Parameters</strong></summary>

| Flag | Required | Description | Default |
|---|---|---|---|
| `--prompt <text>` | Yes | Image description | — |
| `--output <path>` | Yes | Output file path | — |
| `--model <name>` | No | Gemini model name | `gemini-2.0-flash-exp` |
| `--size <value>` | No | Size or aspect hint appended to the prompt | — |
| `--quality <value>` | No | Quality or style hint appended to the prompt | — |
| `--help` | No | Show usage help | — |

**Environment fallback**

The Gemini script prefers `GEMINI_API_KEY` and falls back to `GOOGLE_API_KEY` if needed.

**Example**

```bash
./scripts/generate-gemini.sh \
  --prompt "Friendly onboarding illustration with pastel colors" \
  --output output/onboarding.png \
  --size portrait \
  --quality polished
```

</details>

## 🔄 Switching Providers

Switching is simple:

- Ask your AI assistant to use **OpenAI** or **Gemini** for the next image
- Export the matching API key for the provider you want
- Keep both keys configured if you want to switch back and forth quickly

A common pattern is to use **Gemini** for fast ideation and **OpenAI** for polished final assets.

## 📁 Project Structure

```text
skill-image-gen/
├── SKILL.md                 # Skill definition (the brain)
├── scripts/
│   ├── generate-openai.sh   # OpenAI image generation
│   └── generate-gemini.sh   # Gemini image generation
├── install.sh               # One-line installer
├── examples/                # Example prompts & provider comparison
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## 🧩 Compatibility

| Environment | Status |
|---|---|
| Claude Code CLI | Supported |
| GitHub Copilot CLI | Supported |
| VS Code Marketplace packaging | Planned |

## 🤝 Contributing

Contributions are welcome — from provider improvements to better prompts, docs, and installation flows.

- Read [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Keep changes focused and easy to review
- Test script help output and provider flows when relevant

## 📄 License

MIT — see the [LICENSE](LICENSE) file.
