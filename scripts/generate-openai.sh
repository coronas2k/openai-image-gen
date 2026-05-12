#!/usr/bin/env bash
set -euo pipefail

# Generate an image with the OpenAI Images API and save it to a local file.

SIZE="1024x1024"
QUALITY="medium"
MODEL="gpt-image-2"
FORMAT="png"
PROMPT=""
OUTPUT=""

usage() {
    cat <<'EOF'
Usage: generate-openai.sh --prompt <text> --output <path> [options]

Generate an image with the OpenAI Images API.

Required:
  --prompt <text>    Image description
  --output <path>   Output file path

Options:
  --size <value>    Image dimensions (default: 1024x1024)
  --quality <value> Quality level (default: medium)
  --model <value>   Model name (default: gpt-image-2)
  --format <value>  Output format: png, jpeg, webp (default: png)
  --help            Print this usage message
EOF
}

die() {
    echo "$1" >&2
    exit 1
}

require_value() {
    local flag="$1"
    local next_value="${2:-}"
    if [[ -z "$next_value" || "$next_value" == --* ]]; then
        die "Error: ${flag} requires a value"
    fi
}

decode_base64() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        base64 -D
    else
        base64 -d
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prompt)
            require_value "$1" "${2:-}"
            PROMPT="$2"
            shift 2
            ;;
        --output)
            require_value "$1" "${2:-}"
            OUTPUT="$2"
            shift 2
            ;;
        --size)
            require_value "$1" "${2:-}"
            SIZE="$2"
            shift 2
            ;;
        --quality)
            require_value "$1" "${2:-}"
            QUALITY="$2"
            shift 2
            ;;
        --model)
            require_value "$1" "${2:-}"
            MODEL="$2"
            shift 2
            ;;
        --format)
            require_value "$1" "${2:-}"
            FORMAT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
done

if [[ -z "$PROMPT" ]]; then
    die "Error: --prompt is required"
fi

if [[ -z "$OUTPUT" ]]; then
    die "Error: --output is required"
fi

case "$FORMAT" in
    png|jpeg|webp) ;;
    *) die "Error: --format must be one of: png, jpeg, webp" ;;
esac

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    echo "Error: OPENAI_API_KEY environment variable is not set." >&2
    echo "Get your API key at: https://platform.openai.com/api-keys" >&2
    echo 'Set it: export OPENAI_API_KEY="sk-proj-your-key-here"' >&2
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

REQUEST_BODY=$(python3 - "$MODEL" "$PROMPT" "$SIZE" "$QUALITY" "$FORMAT" <<'PY'
import json
import sys

model, prompt, size, quality, image_format = sys.argv[1:6]
print(json.dumps({
    "model": model,
    "prompt": prompt,
    "n": 1,
    "size": size,
    "quality": quality,
    "output_format": image_format,
}))
PY
)

RESPONSE=$(curl -sS -w "\n%{http_code}" \
    "https://api.openai.com/v1/images/generations" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY")

HTTP_CODE=$(printf '%s\n' "$RESPONSE" | tail -n1)
BODY=$(printf '%s\n' "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "Error: API returned HTTP $HTTP_CODE" >&2
    echo "$BODY" >&2
    exit 1
fi

B64_DATA=$(printf '%s' "$BODY" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
if "data" in data and data["data"]:
    item = data["data"][0]
    if "b64_json" in item:
        print(item["b64_json"])
    elif "url" in item:
        print("URL:" + item["url"])
    else:
        print("ERROR:No image data in response", file=sys.stderr)
        sys.exit(1)
else:
    print("ERROR:" + json.dumps(data), file=sys.stderr)
    sys.exit(1)
')

if [[ "$B64_DATA" == URL:* ]]; then
    IMAGE_URL="${B64_DATA#URL:}"
    curl -sS -o "$OUTPUT" "$IMAGE_URL"
else
    printf '%s' "$B64_DATA" | decode_base64 > "$OUTPUT"
fi

echo "Image saved to: $OUTPUT"
