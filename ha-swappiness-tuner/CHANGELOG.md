# Changelog

## 1.0.4

- Fix definitivo: el perfil AppArmor `docker-default` (activo por defecto en
  todo add-on) bloquea explícitamente la escritura a `/proc/sys/**`
  (`deny /proc/sys/** wklx`) sin importar que el proceso sea root o tenga
  `SYS_ADMIN` — confirmado inspeccionando `/proc/self/attr/current` dentro
  del contenedor. Se agrega `apparmor: false` al `config.yaml`. Verificado en
  un contenedor de prueba con el mismo perfil de seguridad antes de publicar:
  la escritura funciona correctamente con este cambio.

## 1.0.3

- Fix real: el `mount` de BusyBox (default de Alpine) no reconocía los
  bind-mounts de `/proc/sys` en este runtime ("can't find ... in
  /proc/mounts"). Se agrega el paquete `util-linux` para tener un `mount`
  completo, capaz de remontar `/proc/sys` (y `/proc` como respaldo) en
  lectura-escritura correctamente.

## 1.0.2

- Fix: el `mount` de BusyBox no reconocía `/proc/sys` como bind-mount propio
  ("can't find /proc/sys in /proc/mounts"). Ahora se intenta la escritura
  directa primero, y solo si falla se remonta `/proc` (el mount padre) en
  rw antes de reintentar. También se loguea el error real del sistema en vez
  de un mensaje genérico, para diagnosticar mejor si vuelve a fallar.

## 1.0.1

- Fix: `privileged: SYS_ADMIN` por sí solo no alcanza porque Docker monta
  `/proc/sys` de solo-lectura por defecto. Ahora se remonta explícitamente en
  lectura-escritura antes de escribir el valor.

## 1.0.0

- Primera versión: aplica `vm.swappiness` (configurable) en cada arranque del
  add-on, ya que Home Assistant OS lo trae fijo en 1 sin forma de cambiarlo
  desde la configuración estándar.
