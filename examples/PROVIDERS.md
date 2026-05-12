# Provider comparison

## Quick comparison

| Feature | OpenAI (gpt-image-1) | Gemini (Nano Banana) |
|---|---|---|
| API Key | OPENAI_API_KEY | GEMINI_API_KEY |
| Key URL | platform.openai.com/api-keys | aistudio.google.com/apikey |
| Strengths | High-quality, great text rendering | Fast, conversational, free tier |
| Sizes | 1024x1024, 1024x1536, 1536x1024, auto | Handled automatically |
| Quality levels | low, medium, high | Handled via prompt |
| Output format | PNG (base64) | PNG (base64) |
| Pricing | Pay per image | Free tier available |

## OpenAI setup

1. Sign in at [platform.openai.com](https://platform.openai.com/).
2. Open the API keys page: [platform.openai.com/api-keys](https://platform.openai.com/api-keys).
3. Create a new secret key.
4. Copy the key immediately and store it securely.
5. Export it in your shell:
   ```bash
   export OPENAI_API_KEY="your-key-here"
   ```
6. Run the project command or script using the OpenAI provider.

### When to choose OpenAI

Use OpenAI when you want higher-fidelity images, more detailed outputs, or better text rendering inside generated images.

## Gemini setup

1. Sign in at [Google AI Studio](https://aistudio.google.com/).
2. Open the API key page: [aistudio.google.com/apikey](https://aistudio.google.com/apikey).
3. Create a new API key.
4. Copy the key and store it securely.
5. Export it in your shell:
   ```bash
   export GEMINI_API_KEY="your-key-here"
   ```
6. Run the project command or script using the Gemini provider.

### When to choose Gemini

Use Gemini when you want quick iteration, conversational prompt refinement, or a lower-cost path for experimentation.

## Practical recommendation

- Start with Gemini when exploring ideas quickly.
- Switch to OpenAI for photorealistic, highly detailed, or more polished final outputs.
- If prompt wording is still evolving, Gemini is often faster to iterate with.
- If image quality is the top priority, OpenAI is usually the stronger default.
