# Changelog

## 1.0.1

- Fix: el conteo de fallos persistía en `/data/state` entre arranques del
  add-on, así que un reinicio del host (que resuelve la caída por sí solo)
  heredaba fallos viejos y podía disparar avisos/reinicios basados en
  información obsoleta. Ahora el estado se reinicia siempre al arrancar.
- Fix relacionado: los umbrales de reinicio/escalamiento comparaban con
  igualdad exacta (`-eq`); un conteo heredado que saltara justo ese valor
  podía saltarse el aviso por completo. Ahora usan `-ge` con su propia
  bandera de "ya avisado" para no repetir notificaciones de más.

## 1.0.0

- Primera versión: chequeo periódico de la URL pública, reinicio automático del
  add-on configurado tras N fallos seguidos, y notificaciones push de aviso/
  recuperación/escalamiento.
