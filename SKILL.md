---
name: generate-image
description: >-
  Generate images using AI. Use when asked to generate, create, or make images, textures,
  icons, sprites, artwork, visual assets, or mockups. Supports OpenAI (gpt-image-1) and
  Google Gemini (Nano Banana). Requires an API key for the chosen provider.
argument-hint: "[description of the image to generate]"
license: MIT
compatibility: "Cross-platform. Requires curl, python3, and base64."
metadata:
  version: "1.0.0"
  providers: "openai, gemini"
---

# Generate Image

## 1. Quick Reference
Determine `<SKILL_DIR>` at runtime as the directory containing this `SKILL.md` file.

- OpenAI: `bash <SKILL_DIR>/scripts/generate-openai.sh --prompt "..." --output ./image.png`
- Gemini: `bash <SKILL_DIR>/scripts/generate-gemini.sh --prompt "..." --output ./image.png`

## 2. First-Time Setup / Onboarding
If the user hasn't used this skill before, or if the required API key is not set, guide them through setup.

### Provider Selection
Ask which provider they want to use.

- **OpenAI (gpt-image-1)** — High quality, excellent text rendering, paid per image. Best for production assets.
- **Google Gemini (Nano Banana)** — Fast, free tier available, conversational. Best for quick iterations.

If the user asks what options are available, or wants to try the other service, explain both providers and help them switch.

### API Key Setup
Check the relevant environment variable before generating. If it is not set, walk the user through setup.

**OpenAI**
1. Go to https://platform.openai.com/api-keys
2. Create a new API key
3. Set: `export OPENAI_API_KEY="sk-proj-your-key-here"`
4. Add it to `~/.zshrc` or `~/.bashrc` for persistence

**Gemini**
1. Go to https://aistudio.google.com/apikey
2. Create a new API key
3. Set: `export GEMINI_API_KEY="your-key-here"`
4. Add it to the shell profile for persistence
5. `GOOGLE_API_KEY` also works as a fallback

## 3. Usage
### OpenAI Generation
```bash
bash <SKILL_DIR>/scripts/generate-openai.sh \
  --prompt "A seamless grass texture, top-down view, game asset" \
  --output ./grass.png \
  --size 1024x1024 \
  --quality medium \
  --model gpt-image-1
```

| Flag | Required | Default | Description |
|---|---|---|---|
| --prompt | Yes | — | Text description |
| --output | Yes | — | Output file path |
| --size | No | 1024x1024 | Dimensions: 1024x1024, 1024x1536, 1536x1024, auto |
| --quality | No | medium | low, medium, high |
| --model | No | gpt-image-1 | Model name |
| --format | No | png | png, jpeg, webp |

### Gemini Generation
```bash
bash <SKILL_DIR>/scripts/generate-gemini.sh \
  --prompt "A colorful abstract pattern for a website hero" \
  --output ./hero.png \
  --model gemini-2.0-flash-exp
```

| Flag | Required | Default | Description |
|---|---|---|---|
| --prompt | Yes | — | Text description |
| --output | Yes | — | Output file path |
| --model | No | gemini-2.0-flash-exp | Model name |
| --size | No | — | Size hint (appended to prompt) |
| --quality | No | — | Quality hint (appended to prompt) |

## 4. Tips for the Agent
- When generating game textures, include `seamless`, `tileable`, and `game asset` in prompts.
- For batch generation, call the script multiple times in parallel.
- Save images directly to the project's appropriate directory.
- If the user doesn't specify a provider, check which API keys are available and use that provider.
- If both keys are available, prefer OpenAI for quality or Gemini for speed based on context.
- Always tell the user where the image was saved after generation.

## 5. Error Handling
- If the API key is not set, guide the user through setup instead of just failing.
- If the API returns an error, show the error and suggest fixes.
- Common issues: invalid API key, rate limits, content policy violations.

## 6. Switching Providers
If the user asks to try the other provider, or asks what options are available, explain both providers with their tradeoffs and help them switch. Setting up a new provider just requires getting an API key and setting the environment variable.
