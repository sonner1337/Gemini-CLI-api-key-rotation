#!/bin/bash
# Universal Smart Gemini CLI Wrapper
# https://github.com/oravepo546-stack/Gemini-CLI-api-key-rotation

KEYS_FILE="$HOME/.gemini/api_keys.txt"
INDEX_FILE="$HOME/.gemini/key_index.txt"
COOLDOWN_DIR="$HOME/.gemini/cooldowns"
COOLDOWN_TIME=3600 # 1 hour

mkdir -p "$COOLDOWN_DIR"

if [ ! -f "$KEYS_FILE" ]; then
  echo -e "\033[1;31m[-] Error: Keys not found at $KEYS_FILE\033[0m" >&2
  exit 1
fi

mapfile -t keys < "$KEYS_FILE"
num_keys=${#keys[@]}
current_time=$(date +%s)

# Cleanup cooldowns
for f in "$COOLDOWN_DIR"/*; do
  if [ -f "$f" ]; then
    expire_time=$(cat "$f" 2>/dev/null)
    if [[ "$expire_time" =~ ^[0-9]+$ ]] && [ "$current_time" -gt "$expire_time" ]; then
      rm -f "$f"
    fi
  fi
done

# Find next active key
[ ! -f "$INDEX_FILE" ] && echo "0" > "$INDEX_FILE"
current_index=$(cat "$INDEX_FILE")
found_key=""
key_hash=""

for ((i=0; i<num_keys; i++)); do
  idx=$(( (current_index + i) % num_keys ))
  candidate="${keys[$idx]}"
  candidate_hash=$(echo -n "$candidate" | md5sum | awk '{print $1}')
  
  if [ ! -f "$COOLDOWN_DIR/$candidate_hash" ]; then
    found_key="$candidate"
    key_hash="$candidate_hash"
    echo "$(( (idx + 1) % num_keys ))" > "$INDEX_FILE"
    break
  fi
done

if [ -z "$found_key" ]; then
  echo -e "\033[1;31m[-] CRITICAL: All $num_keys keys are exhausted. Wait 1 hour.\033[0m" >&2
  exit 1
fi

export GEMINI_API_KEY="$found_key"
REAL_GEMINI=$(which gemini 2>/dev/null | grep -v "alias" | head -n 1)
[ -z "$REAL_GEMINI" ] && REAL_GEMINI="/usr/bin/env gemini"

ERR_LOG=$(mktemp)
$REAL_GEMINI "$@" 2> >(tee "$ERR_LOG" >&2)
EXIT_CODE=$?
sleep 0.1

if [ $EXIT_CODE -ne 0 ] && grep -q -i -E "429|exhausted|quota|rate limit|too many requests" "$ERR_LOG"; then
  echo -e "\n\033[1;33m[!] Key exhausted (Error 429). Cooling down...\033[0m" >&2
  echo $((current_time + COOLDOWN_TIME)) > "$COOLDOWN_DIR/$key_hash"
  rm -f "$ERR_LOG"
  echo -e "\033[1;32m[*] Retrying with next key...\033[0m" >&2
  exec "$0" "$@"
fi

rm -f "$ERR_LOG"
exit $EXIT_CODE
