#!/usr/bin/env sh

MATTERMOST_URL="${MATTERMOST_URL}"
MATTERMOST_MESSAGE=$(cat << "EOF"
${MATTERMOST_MESSAGE}
EOF
)

usage() {
  echo "Usage: mattermostme <command>"
}

pretty_duration() {
  local ms=$1
  if [ $ms -lt 1000 ]; then echo "$${ms}ms"; return; fi
  local sec=$((ms / 1000))
  echo "$${sec}s"
}

if [ $# -eq 0 ]; then usage; exit 1; fi

START=$(date +%s%N)
"$@"
END=$(date +%s%N)
DURATION_MS=$(((END - START) / 1000000))
PRETTY_DURATION=$(pretty_duration $DURATION_MS)

COMMAND="$@"
# Swap placeholders for actual values
MSG=$(echo "$MATTERMOST_MESSAGE" | sed "s|\\$COMMAND|$COMMAND|g" | sed "s|\\$DURATION|$PRETTY_DURATION|g")

# Mattermost Webhook format is {"text": "your message"}
curl -s -H "Content-Type: application/json" \
     -d "{\"text\": \"$MSG\"}" \
     "$MATTERMOST_URL"