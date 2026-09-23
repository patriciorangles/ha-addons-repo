ARG BUILD_FROM
FROM $BUILD_FROM

# util-linux trae un "mount" completo. El de BusyBox (el default de Alpine)
# no reconoce correctamente los bind-mounts de /proc/sys en este runtime,
# necesario para remontarlo en lectura-escritura.
RUN apk add --no-cache util-linux

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
