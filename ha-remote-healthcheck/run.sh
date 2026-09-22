#!/usr/bin/with-contenv bashio
# ==============================================================================
# Remote Healthcheck - revisa acceso publico a HA y repara solo si se cae
# ==============================================================================
set -u

OPTIONS_FILE="/data/options.json"
STATE_DIR="/data/state"
FAIL_COUNT_FILE="${STATE_DIR}/fail_count"
RESTARTED_FILE="${STATE_DIR}/restart_attempted"

mkdir -p "$STATE_DIR"
[ -f "$FAIL_COUNT_FILE" ] || echo 0 > "$FAIL_COUNT_FILE"
[ -f "$RESTARTED_FILE" ] || echo 0 > "$RESTARTED_FILE"

PUBLIC_URL=$(bashio::config 'public_url')
CHECK_INTERVAL=$(bashio::config 'check_interval_seconds')
TIMEOUT=$(bashio::config 'timeout_seconds')
FAILS_BEFORE_RESTART=$(bashio::config 'fails_before_restart')
FAILS_BEFORE_ESCALATE=$(bashio::config 'fails_before_escalate')
RESTART_ADDON_SLUG=$(bashio::config 'restart_addon_slug')
mapfile -t NOTIFY_TARGETS < <(jq -r '.notify_targets[]' "$OPTIONS_FILE")

bashio::log.info "Remote Healthcheck iniciado."
bashio::log.info "URL publica a revisar: ${PUBLIC_URL}"
bashio::log.info "Intervalo: ${CHECK_INTERVAL}s | Timeout: ${TIMEOUT}s"
bashio::log.info "Reinicia '${RESTART_ADDON_SLUG}' tras ${FAILS_BEFORE_RESTART} fallos seguidos"
bashio::log.info "Escala (avisa sin reintentar) tras ${FAILS_BEFORE_ESCALATE} fallos seguidos"
bashio::log.info "Notifica a: ${NOTIFY_TARGETS[*]}"

# --- Helpers que usan la API interna de Supervisor (sin token personal) -----

notify_all() {
    local title="$1" message="$2"
    for target in "${NOTIFY_TARGETS[@]}"; do
        bashio::api.supervisor \
            POST "/core/api/services/notify/${target}" \
            "{\"title\": \"${title}\", \"message\": \"${message}\"}" \
            > /dev/null 2>&1 \
            || bashio::log.warning "No se pudo notificar a ${target}"
    done
}

restart_addon() {
    bashio::api.supervisor \
        POST "/addons/${RESTART_ADDON_SLUG}/restart" \
        > /dev/null 2>&1
}

# --- El chequeo real ---------------------------------------------------------
# Cualquier respuesta HTTP 2xx/3xx/4xx cuenta como "alcanzable" (el camino
# completo DNS + edge + tunel + HA funciona, aunque sea un 401/403 puntual).
# Solo 5xx (error del tunel/proxy) o timeout/sin conexion cuentan como caido.
check_ok() {
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$PUBLIC_URL")
    [[ "$code" =~ ^[234] ]]
}

# --- Bucle principal ----------------------------------------------------------
while true; do
    if check_ok; then
        fails=$(cat "$FAIL_COUNT_FILE")
        if [ "$fails" -ge "$FAILS_BEFORE_RESTART" ]; then
            bashio::log.info "Recuperado tras ${fails} fallos seguidos."
            notify_all "HA accesible de nuevo" \
                "El acceso remoto a Home Assistant volvió a funcionar."
        fi
        echo 0 > "$FAIL_COUNT_FILE"
        echo 0 > "$RESTARTED_FILE"
    else
        fails=$(( $(cat "$FAIL_COUNT_FILE") + 1 ))
        echo "$fails" > "$FAIL_COUNT_FILE"
        bashio::log.warning "Fallo #${fails} al acceder a ${PUBLIC_URL}"

        minutes=$(( fails * CHECK_INTERVAL / 60 ))

        if [ "$fails" -eq "$FAILS_BEFORE_RESTART" ] && [ "$(cat "$RESTARTED_FILE")" = "0" ]; then
            bashio::log.warning "${fails} fallos seguidos, reiniciando ${RESTART_ADDON_SLUG}"
            restart_addon
            echo 1 > "$RESTARTED_FILE"
            notify_all "Problema con acceso remoto a HA" \
                "No se pudo acceder a Home Assistant desde internet en los últimos ${minutes} min. Se reinició '${RESTART_ADDON_SLUG}' automáticamente."
        elif [ "$fails" -eq "$FAILS_BEFORE_ESCALATE" ]; then
            bashio::log.error "${fails} fallos seguidos tras el reinicio, escalando"
            notify_all "Acceso remoto a HA sigue caído" \
                "Ya se reinició '${RESTART_ADDON_SLUG}' pero el acceso remoto sigue sin funcionar tras ${minutes} min. Revisar manualmente."
        fi
    fi
    sleep "$CHECK_INTERVAL"
done
