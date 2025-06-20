#!/usr/bin/env bash
set -euo pipefail

echo "📄 Starting log capture process..."
LOG_DIR="logs"
SERVICE_NAME="frontend"
DRIVER="lightsail"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%s)
LOG_FILE="$LOG_DIR/${SERVICE_NAME}-${TIMESTAMP}.log"
ERROR_LOG_FILE="$LOG_DIR/preevy-error.log"

echo "🔍 Checking Preevy version..."
if ! npx preevy --version; then
  echo "❌ Preevy is not available. Exiting log capture early."
  exit 1
fi

echo "🔄 Attempting to capture logs for service: $SERVICE_NAME"
if npx preevy logs "$SERVICE_NAME" \
  --driver="$DRIVER" \
  --profile="${PREEVY_PROFILE_URL}" \
  --timestamps 2> "$ERROR_LOG_FILE" | tee "$LOG_FILE"; then

  if [ -s "$LOG_FILE" ]; then
    echo "✅ Logs captured and saved to: $LOG_FILE"
    exit 0
  else
    echo "⚠️ Log file was created but is empty: $LOG_FILE"
  fi
else
  echo "⚠️ Log capture failed for service: $SERVICE_NAME"
fi

echo "❌ Log capture failed or returned empty log. Writing fallback file."
echo "No logs captured" > "$LOG_DIR/no-logs-captured.log"

echo "🔚 Last error log (if any):"
if [ -s "$ERROR_LOG_FILE" ]; then
  cat "$ERROR_LOG_FILE"
else
  echo "No error log available"
fi

echo "📂 Final list of log files:"
ls -la "$LOG_DIR" || echo "⚠️ Could not list log directory"
