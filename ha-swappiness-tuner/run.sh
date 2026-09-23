#!/usr/bin/with-contenv bashio
# ==============================================================================
# Swappiness Tuner - aplica vm.swappiness en cada arranque
# ==============================================================================
set -e

SWAPPINESS_FILE="/proc/sys/vm/swappiness"
SWAPPINESS=$(bashio::config 'swappiness')

if [ ! -w "$SWAPPINESS_FILE" ]; then
    bashio::log.error "No se puede escribir en ${SWAPPINESS_FILE}."
    bashio::log.error "Este add-on necesita 'privileged: SYS_ADMIN' en su config.yaml para tener permiso de tocar este parametro del kernel."
    exit 1
fi

echo "${SWAPPINESS}" > "$SWAPPINESS_FILE"
bashio::log.info "vm.swappiness establecido en ${SWAPPINESS} (valor actual: $(cat "$SWAPPINESS_FILE"))"
