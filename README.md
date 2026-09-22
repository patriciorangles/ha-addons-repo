# HA Remote Healthcheck Add-ons

Repositorio de add-ons de Home Assistant, pensado para reutilizarse en
cualquier instalación (no depende de nada específico de una casa/red en
particular — toda la configuración va por opciones del add-on).

## Add-ons incluidos

- **[Remote Healthcheck](./ha-remote-healthcheck/README.md)** — revisa si tu
  Home Assistant es accesible desde internet y repara/notifica solo si detecta
  una caída sostenida del túnel/proxy que uses (Cloudflared, Nginx Proxy
  Manager, etc.).

## Cómo agregar este repositorio a tu Home Assistant

1. **Ajustes → Add-ons → Tienda de add-ons** → menú de tres puntos (⋮) →
   **Repositorios**.
2. Pega la URL de este repositorio.
3. Busca el add-on en la tienda e instálalo normalmente.

## Origen

Nació de un incidente real: el túnel de Cloudflare de una instalación se quedó
colgado internamente durante horas sin que nadie se enterara, porque
Supervisor seguía marcándolo como "iniciado" (el watchdog normal no ayuda
contra un proceso que sigue vivo pero dejó de responder). Este add-on hace la
prueba real — pide la URL pública, tal como la vería cualquiera desde afuera.
