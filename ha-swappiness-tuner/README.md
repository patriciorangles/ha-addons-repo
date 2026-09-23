# Swappiness Tuner

Add-on de Home Assistant que ajusta `vm.swappiness` (qué tan agresivo es el
kernel moviendo memoria a swap) cada vez que arranca. Existe porque **Home
Assistant OS trae este valor fijo en `1`** y no lo expone en ninguna parte de
su configuración — ni en la UI, ni en un archivo persistente de usuario.

## Por qué existe

Con `swappiness=1` el kernel evita usar swap hasta el último momento posible.
En un equipo con poca RAM (ej. Raspberry Pi con 1GB), eso significa que un
pico de memoria repentino (instalar un add-on, una integración cargando datos,
etc.) fuerza al sistema a swapear todo de golpe y de forma síncrona en vez de
haber ido moviendo páginas inactivas a swap con anticipación — el resultado es
que el sistema completo se cuelga varios minutos aunque el host siga vivo.

Hay un [pedido abierto en el repositorio oficial de Home Assistant](https://github.com/orgs/home-assistant/discussions/4129)
pidiendo que esto sea configurable, sin respuesta de los mantenedores al
momento de escribir esto. Este add-on es el workaround mientras tanto.

## Configuración

```yaml
swappiness: 60
```

| Opción | Qué hace |
|---|---|
| `swappiness` | Valor de 0 a 100 para `vm.swappiness`. `60` es el default estándar de Linux. Valores más altos = el kernel mueve memoria a swap antes (más RAM libre disponible, algo más de I/O a disco). Valores más bajos = prefiere mantener todo en RAM el mayor tiempo posible. |

## Requisitos

- Que el disco donde vive el swapfile sea un SSD/USB, no una tarjeta SD pura —
  con swappiness alto se escribe más seguido a ese disco. En una SD de baja
  calidad esto puede acortar su vida útil; en un SSD no es un problema real.

## Cómo funciona por dentro

Escribe directamente en `/proc/sys/vm/swappiness` al arrancar. Necesita dos
cosas para lograrlo, ambas confirmadas por prueba directa, no por suposición:

- `privileged: SYS_ADMIN` — sin esto, ni siquiera se puede remontar
  `/proc/sys` en lectura-escritura (falla con "read-only file system").
- `apparmor: false` — el perfil `docker-default` que Docker aplica a todo
  contenedor por defecto tiene una regla explícita que bloquea escrituras a
  `/proc/sys/**`, sin importar que el proceso sea root o tenga `SYS_ADMIN`
  (falla con "Permission denied" en vez de "read-only", esa es la pista de
  que el bloqueo viene de AppArmor y no del propio mount).

No toca nada más del sistema, no descarga nada, no corre en bucle: aplica el
valor y termina.

## Instalación

1. Settings → Add-ons → Add-on Store → menú (⋮) → Repositories.
2. Pega `https://github.com/patriciorangles/ha-addons-repo`.
3. Busca "Swappiness Tuner" en la tienda, instálalo, configúralo y arráncalo.
4. Activa "Iniciar en el arranque" para que se vuelva a aplicar en cada
   reinicio del host (HAOS resetea este valor a `1` en cada boot).
