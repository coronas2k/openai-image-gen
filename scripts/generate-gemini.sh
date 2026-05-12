#!/usr/bin/env bash
set -euo pipefail

# Generate an image with the Google Gemini generateContent API and save it locally.

usage() {
  cat <<'EOF'
Usage: scripts/generate-gemini.sh --prompt "..." --output path [options]

Options:
  --prompt TEXT     Image description to generate (required)
  --output PATH     Output image path (required)
  --model NAME      Gemini model to use (default: gemini-2.0-flash-exp)
  --size VALUE      Optional size/aspect hint; added to the prompt text
  --quality VALUE   Optional quality/style hint; added to the prompt text
  --help            Show this help message

Environment:
  GEMINI_API_KEY    Preferred API key
  GOOGLE_API_KEY    Fallback API key

Get an API key: https://aistudio.google.com/apikey
EOF
}

error() {
  echo "Error: $*" >&2
  exit 1
}

prompt=""
output=""
model="gemini-2.0-flash-exp"
size=""
quality=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)
      [[ $# -ge 2 ]] || error "Missing value for --prompt"
      prompt="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || error "Missing value for --output"
      output="$2"
      shift 2
      ;;
    --model)
      [[ $# -ge 2 ]] || error "Missing value for --model"
      model="$2"
      shift 2
      ;;
    --size)
      [[ $# -ge 2 ]] || error "Missing value for --size"
      size="$2"
      shift 2
      ;;
    --quality)
      [[ $# -ge 2 ]] || error "Missing value for --quality"
      quality="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$prompt" ]] || error "--prompt is required"
[[ -n "$output" ]] || error "--output is required"

api_key="${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}"
[[ -n "$api_key" ]] || error "Set GEMINI_API_KEY (preferred) or GOOGLE_API_KEY. Create a key at https://aistudio.google.com/apikey"

request_prompt="Generate an image: $prompt"
if [[ -n "$size" ]]; then
  request_prompt+=$'\nRequested size/aspect: '
  request_prompt+="$size"
fi
if [[ -n "$quality" ]]; then
  request_prompt+=$'\nRequested quality/style: '
  request_prompt+="$quality"
fi

request_json="$({
  REQUEST_PROMPT="$request_prompt" python3 - <<'PY'
import json
import os

payload = {
    "contents": [{"parts": [{"text": os.environ["REQUEST_PROMPT"]}]}],
    "generationConfig": {
        "responseModalities": ["TEXT", "IMAGE"]
    },
}
print(json.dumps(payload, separators=(",", ":")))
PY
})"

http_response="$({
  curl --silent --show-error \
    -X POST \
    -H "Content-Type: application/json" \
    -H "x-goog-api-key: ${api_key}" \
    -d "$request_json" \
    -w $'\n%{http_code}' \
    "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent"
})"

http_status="${http_response##*$'\n'}"
response_body="${http_response%$'\n'*}"

parsed_output="$({
  HTTP_STATUS="$http_status" RESPONSE_BODY="$response_body" python3 - <<'PY'
import json
import os
import sys

http_status = int(os.environ["HTTP_STATUS"])
raw = os.environ["RESPONSE_BODY"]

try:
    data = json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Failed to parse Gemini response JSON: {exc}", file=sys.stderr)
    sys.exit(1)

if isinstance(data, dict) and "error" in data:
    error = data["error"] or {}
    message = error.get("message") or "Gemini API request failed"
    status = error.get("status")
    code = error.get("code")
    details = []
    if code is not None:
        details.append(f"code={code}")
    if status:
        details.append(f"status={status}")
    suffix = f" ({', '.join(details)})" if details else ""
    print(f"{message}{suffix}", file=sys.stderr)
    sys.exit(1)

prompt_feedback = data.get("promptFeedback") or {}
block_reason = prompt_feedback.get("blockReason")
if block_reason:
    message = prompt_feedback.get("blockReasonMessage") or f"Prompt blocked: {block_reason}"
    print(message, file=sys.stderr)
    sys.exit(1)

candidates = data.get("candidates") or []
if not candidates:
    print(f"Gemini returned no candidates (HTTP {http_status})", file=sys.stderr)
    sys.exit(1)

for candidate in candidates:
    finish_reason = candidate.get("finishReason")
    if finish_reason == "SAFETY":
        print("Image generation blocked by Gemini safety filters", file=sys.stderr)
        sys.exit(1)

    content = candidate.get("content") or {}
    parts = content.get("parts") or []
    for part in parts:
        inline = part.get("inlineData") or {}
        image_data = inline.get("data")
        mime_type = inline.get("mimeType")
        if image_data and mime_type:
            print(mime_type)
            print(image_data)
            sys.exit(0)

texts = []
for candidate in candidates:
    content = candidate.get("content") or {}
    for part in content.get("parts") or []:
        text = part.get("text")
        if text:
            texts.append(text.strip())

extra = f" Response text: {' | '.join(t for t in texts if t)}" if any(texts) else ""
print(f"Gemini response did not include image data.{extra}", file=sys.stderr)
sys.exit(1)
PY
})"

mime_type="${parsed_output%%$'\n'*}"
image_base64="${parsed_output#*$'\n'}"

case "$mime_type" in
  image/*) ;;
  *)
    error "Unexpected MIME type returned: $mime_type"
    ;;
esac

output_dir="$(dirname "$output")"
mkdir -p "$output_dir"

if base64 -D >/dev/null 2>&1 <<<""; then
  printf '%s' "$image_base64" | base64 -D > "$output"
else
  printf '%s' "$image_base64" | base64 -d > "$output"
fi

if [[ ! -s "$output" ]]; then
  error "Decoded image file is empty"
fi

echo "Image saved to: $output"
