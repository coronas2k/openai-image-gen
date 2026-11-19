---
name: generate-image
description: >-
  Generate images using AI. Use when asked to generate, create, or make images, textures,
  icons, sprites, artwork, visual assets, or mockups. Supports OpenAI (gpt-image-2 and
  gpt-image-2.5/2.6) and Google Gemini (Nano Banana 2.1 and Nano Banana Pro). Requires an
  API key for the chosen provider.
argument-hint: "[description of the image to generate]"
license: MIT
metadata:
  version: "3.0.0"
  providers: "openai, gemini"
---

# Generate Image

You are an image generation assistant. When invoked, follow the workflow below.

## Workflow

1. **Check for API keys** — check whether `SKILL_IMAGE_GEN_OPENAI_KEY` and/or `SKILL_IMAGE_GEN_GEMINI_KEY` are set in the environment.
2. **If one key is set** — use that provider. No need to ask.
3. **If both are set** — pick based on context: OpenAI for maximum polish and text rendering (`gpt-image-2.5`/`2.6` with `quality: "max"` when it matters), Gemini Nano Banana 2.1 for speed, cost efficiency, and free-tier iteration. Or ask if the user has a preference.
4. **If no keys are set** — run the Onboarding section.
5. **Generate the image** using the appropriate API reference.
6. **Tell the user** where the image was saved.

## Onboarding

Only run this if no keys are set. Guide the user conversationally.

1. Ask which provider they'd like to use:
   - **OpenAI (gpt-image-2)** — High quality, excellent text rendering, paid per image
   - **Google Gemini (Nano Banana 2.1)** — Fast, free tier available, great for iteration
2. Direct them to get an API key:
   - OpenAI → https://platform.openai.com/api-keys
   - Gemini → https://aistudio.google.com/apikey
3. Once they provide the key, set `SKILL_IMAGE_GEN_OPENAI_KEY` or `SKILL_IMAGE_GEN_GEMINI_KEY` in the current session and persist it to the appropriate shell profile.
4. Proceed to generate the image they originally asked for.

## API Reference: OpenAI

**Method:** `POST`
**URL:** `https://api.openai.com/v1/images/generations`

**Headers:**
- `Authorization: Bearer <SKILL_IMAGE_GEN_OPENAI_KEY>`
- `Content-Type: application/json`

**Body (JSON):**
```json
{
  "model": "gpt-image-2",
  "prompt": "<user prompt>",
  "n": 1,
  "size": "auto",
  "quality": "auto"
}
```

| Field | Default | Options / constraints |
|---|---|---|
| model | `gpt-image-2` | `gpt-image-2` (stable default), `gpt-image-2.5-sunburst`, `gpt-image-2.5-flare` (+ `2026-09-08` snapshots), `gpt-image-2.6-sunburst`, `gpt-image-2.6-flare`, `gpt-image-1.5`, `gpt-image-1-mini`, `chatgpt-image-latest`. **`gpt-image-1` was shut down on 2026-10-23 — never use it.** |
| size | `auto` | `1024x1024`, `1536x1024`, `1024x1536`, `auto`, or custom `WIDTHxHEIGHT`: edges must be multiples of 16, aspect ratio between 1:3 and 3:1, max edge 3840px, total pixels between 655,360 and 8,294,400 (4K). Custom resolutions above 2560x1440 are experimental. |
| quality | `auto` | `low`, `medium`, `high` (all models); `xhigh`, `max` only on `gpt-image-2.5-sunburst` / `gpt-image-2.5-flare` (incl. `2026-09-08` snapshots). Use `low` for quick drafts. |
| output_format | `png` | `png`, `webp`, `jpeg` (faster than png — prefer when latency matters), `gif`, `svg` |
| background | `auto` | `transparent`, `opaque`, `auto` — `transparent` requires `output_format` of `png` or `webp` |
| output_compression | (unset) | 0–100, only for `jpeg`/`webp`; not supported for `svg` |
| moderation | `auto` | `auto`, `low` |
| n | 1 | Number of images to generate; must be `1` for `svg` output |

**Response:** `data[0].b64_json` contains the base64-encoded image. Decode it and save to the output path. For `svg` output, base64-decode `data[0].b64_json` to UTF-8 XML bytes and save with a `.svg` extension. If a legacy `data[0].url` field appears instead of `b64_json`, download the image from that URL.

**Advanced (out of scope unless explicitly requested):** image edits/inpainting (`input_image_mask`), animated GIF control (`frame_count` 2–16, `frame_duration_ms` 20–2000), streaming partial images (`partial_images` 0–3), and input fidelity matching (`input_fidelity` — `gpt-image-1.5`/`gpt-image-1-mini` only) are available via the Responses API (`POST /v1/responses`) with the same model list.

## API Reference: Google Gemini (Nano Banana)

**Method:** `POST`
**URL:** `https://generativelanguage.googleapis.com/v1beta/models/<model>:generateContent`

**Headers:**
- `x-goog-api-key: <SKILL_IMAGE_GEN_GEMINI_KEY>`
- `Content-Type: application/json`

**Body (JSON):**
```json
{
  "contents": [{"parts": [{"text": "Generate an image: <user prompt>"}]}],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"],
    "imageConfig": {"aspectRatio": "16:9", "imageSize": "2K"}
  }
}
```

Omit `imageConfig` unless the user asks for a specific aspect ratio or resolution — the default then matches the input image size (for edits) or a 1:1 square.

| Field | Default | Options / constraints |
|---|---|---|
| model (in URL) | `gemini-nano-banana-2.1` | `gemini-nano-banana-2.1` (Nano Banana 2.1 — recommended workhorse), `gemini-3.1-flash-image` (Nano Banana 2 — previous gen), `gemini-3.1-flash-lite-image` (Nano Banana 2 Lite — fastest/cheapest; not optimized for multi-reference or multi-turn editing), `gemini-3-pro-image` (Nano Banana Pro — premium, studio-quality 4K, complex layouts, precise text rendering), `gemini-2.5-flash-image` (legacy, limited availability). **Do not use `gemini-2.0-flash-exp` — deprecated.** |
| responseModalities | — | `["TEXT", "IMAGE"]` — `IMAGE` must be present to receive generated images |
| imageConfig.aspectRatio | (input size or `1:1`) | `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9` (extremes `1:4`, `1:8`, `4:1`, `8:1` also accepted) |
| imageConfig.imageSize | `1K` | `1K`, `2K`, `4K` — supported on `gemini-nano-banana-2.1`, `gemini-3.1-flash-image`, and `gemini-3-pro-image` |

### Reference images and editing

To edit or composite from existing images, append `inlineData` parts (base64-encoded image + `mimeType`) after the text part of `contents`. Per-model reference-image limits:

| Model | Objects | Characters | Style refs |
|---|---|---|---|
| `gemini-3.1-flash-lite-image` | 14 | — | — |
| `gemini-nano-banana-2.1` / `gemini-3.1-flash-image` | 10 | 4 | — |
| `gemini-3-pro-image` | 6 | 5 | 3 |

**Response:** Find `candidates[0].content.parts[]` — look for a part with `inlineData.data` (base64 image) and `inlineData.mimeType`. Decode and save. All generated images include a SynthID watermark.

**Error cases:** `error` key (API error), `promptFeedback.blockReason` (safety block), `finishReason: "SAFETY"` (filtered).

## Agent Guidelines

- Choose the output path intelligently — save to the project's relevant directory (e.g., `assets/`, `images/`, or the current directory).
- For game textures, enrich prompts with "seamless", "tileable", "game asset".
- For batch generation, make multiple API calls in parallel.
- If the user asks to switch providers or what options are available, explain both and help them set up.
- Always create the output directory before saving.
- Ensure special characters in the user's prompt are properly escaped in the JSON body.
- If the user asks for a specific aspect ratio, map it to `size` (OpenAI, including custom `WIDTHxHEIGHT` dimensions) or `imageConfig.aspectRatio` (Gemini). For higher resolution, use `quality: "high"` (or `xhigh`/`max` on gpt-image-2.5) on OpenAI, or `imageConfig.imageSize: "2K"`/`"4K"` on Gemini.
- For transparent backgrounds (icons, sprites) on OpenAI, set `background: "transparent"` with `output_format: "png"` or `"webp"`.
- Use `output_format: "jpeg"` on OpenAI when latency matters more than format fidelity.
- If the user cares about image provenance, note that Gemini outputs carry an invisible SynthID watermark.
- If the user asks for image editing, inpainting, animated GIFs, or streaming partial results, point them at the OpenAI Responses API (`POST /v1/responses`) — see its docs for `input_image_mask`, `frame_count`, `frame_duration_ms`, and `partial_images`.
