# Changelog

## 1.0.1

- Fix: `privileged: SYS_ADMIN` por sí solo no alcanza porque Docker monta
  `/proc/sys` de solo-lectura por defecto. Ahora se remonta explícitamente en
  lectura-escritura antes de escribir el valor.

## 1.0.0

- Primera versión: aplica `vm.swappiness` (configurable) en cada arranque del
  add-on, ya que Home Assistant OS lo trae fijo en 1 sin forma de cambiarlo
  desde la configuración estándar.
