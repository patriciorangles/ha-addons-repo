#!/usr/bin/with-contenv bashio
# ==============================================================================
# Swappiness Tuner - aplica vm.swappiness en cada arranque
# ==============================================================================
set -u

SWAPPINESS_FILE="/proc/sys/vm/swappiness"
SWAPPINESS=$(bashio::config 'swappiness')

write_swappiness() {
    echo "${SWAPPINESS}" > "$SWAPPINESS_FILE" 2>/tmp/swappiness_err
}

if write_swappiness; then
    bashio::log.info "vm.swappiness establecido en ${SWAPPINESS} (valor actual: $(cat "$SWAPPINESS_FILE"))"
    exit 0
fi

bashio::log.warning "Escritura directa fallo: $(cat /tmp/swappiness_err)"
bashio::log.info "Intentando remontar /proc en modo lectura-escritura..."

# Docker suele montar partes de /proc de solo-lectura por defecto aunque el
# contenedor tenga SYS_ADMIN. Se intenta remontar /proc (el mount padre, que
# si aparece como entrada propia) en vez de /proc/sys directamente, ya que
# el mount de BusyBox no siempre reconoce bind-mounts internos de /proc/sys.
# Esto solo afecta la vista de ESTE contenedor, no al host ni a otros add-ons.
mount -o remount,rw /proc 2>&1 | while read -r line; do bashio::log.info "mount: $line"; done

if write_swappiness; then
    bashio::log.info "vm.swappiness establecido en ${SWAPPINESS} tras remontar /proc (valor actual: $(cat "$SWAPPINESS_FILE"))"
    exit 0
fi

bashio::log.error "Sigue sin poder escribirse en ${SWAPPINESS_FILE}."
bashio::log.error "Error real: $(cat /tmp/swappiness_err)"
bashio::log.error "Verifica que el add-on tenga 'privileged: SYS_ADMIN' en config.yaml y que el modo protegido este desactivado si Home Assistant lo pide para este add-on."
exit 1
