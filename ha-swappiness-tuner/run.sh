#!/usr/bin/with-contenv bashio
# ==============================================================================
# Swappiness Tuner - aplica vm.swappiness en cada arranque
# ==============================================================================
set -e

SWAPPINESS_FILE="/proc/sys/vm/swappiness"
SWAPPINESS=$(bashio::config 'swappiness')

if [ ! -w "$SWAPPINESS_FILE" ]; then
    # Docker monta /proc/sys de solo-lectura por defecto aunque el contenedor
    # tenga SYS_ADMIN. La capacidad sola no alcanza: hay que remontarlo en
    # lectura-escritura explicitamente (esto solo afecta la vista de ESTE
    # contenedor, no al host ni a otros add-ons).
    bashio::log.info "Remontando /proc/sys en modo lectura-escritura..."
    mount -o remount,rw /proc/sys || {
        bashio::log.error "No se pudo remontar /proc/sys en rw."
        bashio::log.error "Verifica que el add-on tenga 'privileged: SYS_ADMIN' en config.yaml y que el modo protegido este desactivado si Home Assistant lo pide para este add-on."
        exit 1
    }
fi

if [ ! -w "$SWAPPINESS_FILE" ]; then
    bashio::log.error "Sigue sin poder escribirse en ${SWAPPINESS_FILE} incluso despues de remontar."
    exit 1
fi

echo "${SWAPPINESS}" > "$SWAPPINESS_FILE"
bashio::log.info "vm.swappiness establecido en ${SWAPPINESS} (valor actual: $(cat "$SWAPPINESS_FILE"))"
