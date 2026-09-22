# Remote Healthcheck

Add-on de Home Assistant que revisa periódicamente si tu instancia es
**accesible desde internet** (no solo en la red local) y, si detecta caídas
sostenidas, reinicia automáticamente el add-on responsable (por ejemplo, el
túnel de Cloudflare) y te avisa por notificación push.

## Por qué existe

Un túnel/proxy (Cloudflared, Nginx Proxy Manager, etc.) puede quedarse
"colgado" internamente sin que Supervisor lo detecte — el proceso sigue vivo,
pero deja de responder. En ese caso, un `watchdog` normal **no ayuda**, porque
solo reacciona si el proceso muere, no si simplemente deja de funcionar. Este
add-on hace la prueba real: pide la URL pública, tal como la vería cualquiera
desde afuera de la casa.

## Cómo decide si está "caído"

Cualquier respuesta HTTP `2xx`/`3xx`/`4xx` cuenta como **alcanzable** — incluso
un 401/403 prueba que la petición llegó completa (DNS + borde + túnel + HA).
Solo un `5xx` (error del túnel/proxy) o que la conexión no responda en absoluto
cuenta como **caído**.

## Configuración

```yaml
public_url: "https://tu-dominio.example.com/"
check_interval_seconds: 300
timeout_seconds: 15
fails_before_restart: 3
fails_before_escalate: 6
restart_addon_slug: "9074a9fa_cloudflared"
notify_targets:
  - "mobile_app_tu_telefono"
```

| Opción | Qué hace |
|---|---|
| `public_url` | URL completa a revisar. |
| `check_interval_seconds` | Cada cuánto revisa (segundos). |
| `timeout_seconds` | Cuánto espera una respuesta antes de contarla como fallo. |
| `fails_before_restart` | Fallos seguidos antes de reiniciar el add-on. |
| `fails_before_escalate` | Fallos seguidos (ya con el reinicio hecho) antes de avisar "sigue caído, revisar a mano" en vez de reintentar de nuevo. |
| `restart_addon_slug` | Slug del add-on a reiniciar (lo ves en la URL de su página de configuración, o en Herramientas de desarrollo → Acciones → `hassio.addon_restart`). |
| `notify_targets` | Lista de servicios `notify.*` a avisar (sin el prefijo `notify.`). |

## Requisitos

- Tener ya configurado al menos un servicio `notify.*` (la app móvil de Home
  Assistant en tu teléfono la crea sola al instalarla).
- Saber el *slug* exacto del add-on que quieres que reinicie (no el nombre
  visible — el slug técnico).

## Cómo funciona por dentro

No usa ningún token personal ni credencial guardada — llama a la API interna
del Supervisor (`hassio_api` + `homeassistant_api`, ya declarados en
`config.yaml`), que cada add-on recibe automáticamente y de forma aislada.
Por eso este add-on es seguro de compartir/versionar en un repositorio
público: no hay ningún secreto embebido en el código.

## Instalación

1. Settings → Add-ons → Add-on Store → menú (⋮) → Repositories.
2. Pega la URL de este repositorio de GitHub.
3. Busca "Remote Healthcheck" en la tienda, instálalo, configúralo y arráncalo.

## Limitaciones conocidas

- Si toda tu red/internet de casa se cae, este add-on tampoco puede avisar
  (corre en el mismo lugar que intenta revisar). Para ese escenario hace falta
  un chequeo desde un punto realmente externo (ej. UptimeRobot).
- El reinicio automático es de un solo add-on a la vez — pensado para el caso
  típico de un túnel/proxy colgado, no como solución general de monitoreo.
