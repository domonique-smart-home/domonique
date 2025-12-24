#!/bin/bash
set -euo pipefail

ALEXA_SCRIPT="${ALEXA_SCRIPT:-/data/alexa_remote_control.sh}"
ALEXA_PROXY_HOST="${ALEXA_PROXY_HOST:-$(hostname -I | awk '{print $1}')}"
ALEXA_PROXY_PORT="${ALEXA_PROXY_PORT:-8080}"
LOG=/tmp/alexa-cookie-cli.log

update_token() {
  local token="$1"
  local tmp
  tmp=$(mktemp)
 
  awk -v val="$token" 'BEGIN{q="'\''"; found=0} {
    if ($0 ~ /^SET_REFRESH_TOKEN=/) {
      print "SET_REFRESH_TOKEN=" q val q
      found=1
    } else {
      print
    }
  } END {
    if (!found) print "SET_REFRESH_TOKEN=" q val q
  }' "$ALEXA_SCRIPT" > "$tmp"

  cat "$tmp" > "$ALEXA_SCRIPT"
  rm -f "$tmp"
  sync
}


# ===================================================================
#  Loop for Alexa Cookie CLI : Each loop start a new alexa-cookie-cli
# ===================================================================
while true; do
  echo
  echo "[INFO] =========================================================="
  echo "[INFO] Iniciando nuevo ciclo de captura de token"
  echo "[INFO] Abre en el navegador: http://${ALEXA_PROXY_HOST}:${ALEXA_PROXY_PORT}"
  echo "[INFO] =========================================================="
  echo "[INFO] Procediendo a la captura del token..."

  : > "$LOG"
  [[ -f "$ALEXA_SCRIPT" ]] || : > "$ALEXA_SCRIPT"

  node cli.js \
    --proxyOwnIp "${ALEXA_PROXY_HOST}" \
    --proxyPort "${ALEXA_PROXY_PORT}" \
    --proxyListenBind 0.0.0.0 \
    --amazonPage amazon.es \
    --baseAmazonPage amazon.com \
    --amazonPageProxyLanguage es_ES \
    --acceptLanguage es-ES \
    1>>"$LOG" &
  PID=$!
  trap "kill $PID 2>/dev/null || true" EXIT

  TOKEN=""
  while [[ -z "$TOKEN" ]]; do
    TOKEN=$(grep -o 'Atnr|[^" ]*' "$LOG" | head -n1 || true)

    if ! kill -0 "$PID" 2>/dev/null; then
      echo "[ERROR] El proxy se cerró antes de capturar token. Reiniciando..."
      break
    fi
    sleep 1
  done

  if [[ -n "$TOKEN" ]]; then
    echo "[OK] Token capturado. Guardando..."

    TOKEN_ESCAPED=$(printf '%s' "$TOKEN" | sed -e 's/[\/&]/\\&/g' -e "s/'/\\'/g")
    update_token "$TOKEN_ESCAPED"

    echo "[OK] SET_REFRESH_TOKEN actualizado en: $ALEXA_SCRIPT"
  fi

  echo "[INFO] Reiniciando alexa-cookie-cli en 3 segundos..."
  kill $PID 2>/dev/null || true
  wait $PID 2>/dev/null || true
  sleep 3
done