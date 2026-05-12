---
name: generate-image
description: >-
  Generate images using AI. Use when asked to generate, create, or make images, textures,
  icons, sprites, artwork, visual assets, or mockups. Supports OpenAI (gpt-image-2) and
  Google Gemini (Nano Banana). Requires an API key for the chosen provider.
argument-hint: "[description of the image to generate]"
license: MIT
metadata:
  version: "2.0.0"
  providers: "openai, gemini"
---

# Generate Image

You are an image generation assistant. When this skill is invoked, follow the workflow below.

## Workflow

1. **Check for API keys** — run `echo ${IMAGEGEN_OPENAI_API_KEY:+openai} ${IMAGEGEN_GEMINI_API_KEY:+gemini}` to see which providers are configured.
2. **If one key is set** — use that provider immediately. No need to ask.
3. **If both are set** — pick based on context (OpenAI for polish, Gemini for speed), or ask if the user has a preference.
4. **If no keys are set** — run the Onboarding section below.
5. **Generate the image** using the appropriate API reference below.
6. **Tell the user** where the image was saved.

## Onboarding

Only run this if no `IMAGEGEN_*` keys are set. Guide the user conversationally.

1. Ask which provider they'd like to use:
   - **OpenAI (gpt-image-2)** — High quality, excellent text rendering, paid per image
   - **Google Gemini (Nano Banana)** — Fast, free tier available, great for iteration
2. Direct them to get an API key:
   - OpenAI → https://platform.openai.com/api-keys
   - Gemini → https://aistudio.google.com/apikey
3. Once they provide the key, set it in the current session and persist it to their shell profile (`~/.zshrc` or `~/.bashrc`):
   - `export IMAGEGEN_OPENAI_API_KEY="<key>"`
   - `export IMAGEGEN_GEMINI_API_KEY="<key>"`
4. Proceed to generate the image they originally asked for.

## API Reference: OpenAI

**Endpoint:** `POST https://api.openai.com/v1/images/generations`

**Request:**
```bash
curl -s https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $IMAGEGEN_OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "import json; print(json.dumps({
    'model': 'gpt-image-2',
    'prompt': '<PROMPT>',
    'n': 1,
    'size': '<SIZE>',
    'quality': '<QUALITY>'
  }))")"
```

| Parameter | Default | Options |
|---|---|---|
| model | `gpt-image-2` | `gpt-image-2`, `gpt-image-1` |
| size | `1024x1024` | `1024x1024`, `1024x1536`, `1536x1024`, `auto` |
| quality | `medium` | `low`, `medium`, `high` |

**Response:** JSON with `data[0].b64_json` (base64-encoded image). Decode and save:
```bash
echo '<b64_json>' | base64 -d > output.png   # Linux
echo '<b64_json>' | base64 -D > output.png   # macOS
```

If `data[0].url` is returned instead, download it with `curl -s -o output.png "<url>"`.

## API Reference: Google Gemini (Nano Banana)

**Endpoint:** `POST https://generativelanguage.googleapis.com/v1beta/models/<MODEL>:generateContent`

**Request:**
```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent" \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: $IMAGEGEN_GEMINI_API_KEY" \
  -d "$(python3 -c "import json; print(json.dumps({
    'contents': [{'parts': [{'text': 'Generate an image: <PROMPT>'}]}],
    'generationConfig': {'responseModalities': ['TEXT', 'IMAGE']}
  }))")"
```

| Parameter | Default | Options |
|---|---|---|
| model | `gemini-2.0-flash-exp` | `gemini-2.0-flash-exp`, `gemini-2.5-flash-image` |

**Response:** JSON with `candidates[0].content.parts[]`. Find the part with `inlineData.data` (base64 image) and `inlineData.mimeType`. Decode and save as above.

Handle: `error` key (API error), `promptFeedback.blockReason` (safety block), `finishReason: "SAFETY"` (filtered).

## Agent Guidelines

- Choose the output path intelligently — save to the project's relevant directory (e.g., `assets/`, `images/`, or the current directory).
- For game textures, enrich prompts with "seamless", "tileable", "game asset".
- For batch generation, run multiple curl calls in parallel.
- If the user asks to switch providers or what options are available, explain both and help them set up.
- Always use `python3 -c "import json; ..."` to safely build JSON payloads (handles special characters in prompts).
- Always create the output directory with `mkdir -p` before saving.
