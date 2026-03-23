#!/bin/bash
# Universal Smart Gemini CLI Wrapper
# Key rotation and auto-retry logic for the official Gemini CLI.
# https://github.com/oravepo546-stack/Gemini-CLI-api-key-rotation

# 1. Configuration & Directories
KEYS_FILE="$HOME/.gemini/api_keys.txt"
INDEX_FILE="$HOME/.gemini/key_index.txt"
COOLDOWN_DIR="$HOME/.gemini/cooldowns"
COOLDOWN_TIME=3600 # 1 hour cooldown period (in seconds)

mkdir -p "$COOLDOWN_DIR"

if [ ! -f "$KEYS_FILE" ]; then
  echo -e "\033[1;31m[-] Error: API keys file not found at $KEYS_FILE\033[0m" >&2
  exit 1
fi

mapfile -t keys < "$KEYS_FILE"
num_keys=${#keys[@]}
current_time=$(date +%s)

if [ $num_keys -eq 0 ]; then
  echo -e "\033[1;31m[-] Error: No API keys found in $KEYS_FILE\033[0m" >&2
  exit 1
fi

# 2. Cleanup expired cooldowns
for f in "$COOLDOWN_DIR"/*; do
  if [ -f "$f" ]; then
    expire_timestamp=$(cat "$f" 2>/dev/null)
    if [[ "$expire_timestamp" =~ ^[0-9]+$ ]] && [ "$current_time" -gt "$expire_timestamp" ]; then
      rm -f "$f"
    fi
  fi
done

# 3. Rotate through keys, skipping those currently in cooldown
[ ! -f "$INDEX_FILE" ] && echo "0" > "$INDEX_FILE"
current_index=$(cat "$INDEX_FILE")
found_key=""
key_hash=""

for ((i=0; i<num_keys; i++)); do
  idx=$(( (current_index + i) % num_keys ))
  candidate_key="${keys[$idx]}"
  
  # Hash the key to use as a filename for the cooldown state (hides the raw key)
  candidate_hash=$(echo -n "$candidate_key" | md5sum | awk '{print $1}')
  
  if [ ! -f "$COOLDOWN_DIR/$candidate_hash" ]; then
    found_key="$candidate_key"
    key_hash="$candidate_hash"
    # Update index for the next call
    echo "$(( (idx + 1) % num_keys ))" > "$INDEX_FILE"
    break
  fi
done

if [ -z "$found_key" ]; then
  echo -e "\033[1;31m[-] CRITICAL: All $num_keys API keys are exhausted. Please wait for cooldowns to expire.\033[0m" >&2
  exit 1
fi

# 4. Prepare for execution
export GEMINI_API_KEY="$found_key"

# Locate the actual gemini binary, excluding any shell aliases
REAL_GEMINI=$(which gemini 2>/dev/null | grep -v "alias" | head -n 1)
if [ -z "$REAL_GEMINI" ]; then
  REAL_GEMINI="/usr/bin/env gemini"
fi

# 5. Execute and capture errors
ERR_LOG=$(mktemp)
# tee is used to duplicate stderr so the user can see errors live while we log them for analysis.
$REAL_GEMINI "$@" 2> >(tee "$ERR_LOG" >&2)
EXIT_CODE=$?

# Allow a split second for process substitution to finish writing
sleep 0.1

# 6. Analyze result for Resource Exhaustion (429)
if [ $EXIT_CODE -ne 0 ] && grep -q -i -E "429|exhausted|quota|rate limit|too many requests" "$ERR_LOG"; then
  echo -e "\n\033[1;33m[!] Current API key exhausted (429). Adding to cooldown list...\033[0m" >&2
  
  # Store expiration timestamp
  echo $((current_time + COOLDOWN_TIME)) > "$COOLDOWN_DIR/$key_hash"
  
  rm -f "$ERR_LOG"
  echo -e "\033[1;32m[*] Automatically retrying with a fresh key...\033[0m" >&2
  
  # Recursive retry with the next key
  exec "$0" "$@"
fi

# Final cleanup
rm -f "$ERR_LOG"
exit $EXIT_CODE
