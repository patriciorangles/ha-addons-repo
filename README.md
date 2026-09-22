# HA Add-ons Repo

Repositorio de add-ons de Home Assistant de Patricio Rangles. Cada add-on vive
en su propia carpeta y está pensado para reutilizarse en cualquier instalación
(no depende de nada específico de una casa/red en particular — toda la
configuración va por opciones del add-on). Con el tiempo se irán agregando más
add-ons aquí mismo, cada uno como una carpeta nueva con su propio
`config.yaml`.

## Add-ons incluidos

- **[Remote Healthcheck](./ha-remote-healthcheck/README.md)** — revisa si tu
  Home Assistant es accesible desde internet y repara/notifica solo si detecta
  una caída sostenida del túnel/proxy que uses (Cloudflared, Nginx Proxy
  Manager, etc.).

## Cómo agregar este repositorio a tu Home Assistant

1. **Ajustes → Add-ons → Tienda de add-ons** → menú de tres puntos (⋮) →
   **Repositorios**.
2. Pega la URL de este repositorio.
3. Busca el add-on que quieras en la tienda e instálalo normalmente — todos
   los add-ons de este repositorio aparecen listados por separado.

## Origen del Remote Healthcheck

Nació de un incidente real: el túnel de Cloudflare de una instalación se quedó
colgado internamente durante horas sin que nadie se enterara, porque
Supervisor seguía marcándolo como "iniciado" (el watchdog normal no ayuda
contra un proceso que sigue vivo pero dejó de responder). Ese add-on hace la
prueba real — pide la URL pública, tal como la vería cualquiera desde afuera.
