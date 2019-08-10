
# Script de Respaldos SQL

----
## Descripción

Este script realiza el respaldo de una base de datos utilizando la herramienta mysqldump. Una vez creado el respaldo, lo copia en una carpeta en la cual se debió haber montado previamente la unidad de Samba, para que de esta manera se guarde el respaldo de manera directa en el servidor samba.

----
## Uso
1. Primero debe montar la unidad samba en el servidor cliente:
 - sudo mount -t cifs //IP_SERVIDOR_SAMBA/RECURSO CARPETA_MONTAJE/ -o user=testuser
3. Ejecutar el script.
 - ./respaldo.sh

###Nota: debe instalar cifs-utils

----
## Links
* [Unidades Samba en Linux](https://blog.desdelinux.net/montar-unidades-smb-desde-consola/)
