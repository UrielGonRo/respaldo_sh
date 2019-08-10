#!/bin/bash
# Title: Respaldo.sh
# Autor: Ivan Gonzalez
# Date: Ago 09 2019
# Last Modif: Ago 09 2019
# Description: Script Bash que almacena el respaldo de una base de datos en un servidor
# 	       remoto de tipo Samba. Para ello es necesario realizar el montaje de samba
#	       en una carpeta de nuestro cliente. ¿Cómo se realiza esto? con el siguiente
# 	       comando:
#	       sudo mount -t cifs //IP_SAMBA_SERVER/carpeta_samba carpeta_cliente_montaje_samba/ -o user=samba_user
#	       EJ:
#	       sudo mount -t cifs //192.168.1.157/proyecto /home/uriel/Documentos/samba_server/ -o user=ivan
# Consideraciones:
#   1.-	Para que el montaje del espacio en el cliente funcione primero debe instalar cifs-utils
#	    Debian: sudo apt-get install cifs-utils
#	    Centos: sudo yum install cifs-utils
#  2.- El script debe ser ejecutado por el usuario root para que al momento de copiar los archivos de respaldo
#      al espacio de Samba no exista errores de permisos.

# Definición de variables a utilizar
smb_server="/ruta/de/montaje/samba"
user_bd="usuario_bd"
passwd_bd="contraseña_usuario_bd"
bd="base_de_datos_a_respaldar"

date_log=$(date +"%b-%d-%Y %r")

echo "--------------------------------------------------------------------------------------" >> respaldo.log
echo "[ $date_log ] --> Iniciando tarea de respaldo" >> respaldo.log
# Validación de que solo el usuario root ejecute el Script
if [ $(whoami) != "root" ]; then
	echo "No inició como usuario root!"
	# Reporta error en archivo de logs
	echo "[ $date_log ] --> [[ERROR]] No inició como usuario root!" >> respaldo.log
	exit 0
fi

# Variable de fecha para concatenar en archivo sql
fecha=$(date +%d%m%y)


echo "Realizando el respaldo de la base de datos $bd!"
echo "[ $date_log ] --> ejecutando mysqldump -u $user_bd --password=$passwd_bd $bd > ${bd}_${fecha}.sql" >> respaldo.log

# Se obtiene la salida de error del comando mysqldump
resul=$(((mysqldump -u $user_bd --password=$passwd_bd $bd > ${bd}_${fecha}.sql) >&2) 2>&1)

# Se comprueba que se ejecutó con éxito el comando de respaldo
if [ $? -eq 0 ]; then 
	echo "Archivo de respaldo creado con el siguiente nombre: ${bd}_${fecha}.sql"
	echo "[ $date_log ] --> Creación del archivo ${bd}_${fecha}.sql " >> respaldo.log
	echo "Moviendo a servidor Samba..."
	echo "[ $date_log ] --> Copiando archivo ${bd}_${fecha}.sql al servidor Samba montado en $smb_server" >> respaldo.log
	cp ${bd}_${fecha}.sql $smb_server
	echo "[ $date_log ] --> Tarea completada!" >> respaldo.log
	echo "¡Listo! Se ha completado la tarea..."
	echo ""
	echo "NOTA:";
	echo "Se recomienda verificar si el archivo de respaldo se subió correctamente al servidor Samba."
	echo "En caso de que no aparezca, verifique que montó la unidad samba en el servidor cliente."
	echo "Para montar la unidad ejecute:"
	echo " -> sudo mount -t cifs //IP_SERVIDOR_SAMBA/RECURSO CARPETA_MONTAJE/ -o user=testuser"
	echo ""
	exit 0

else 
	echo "[[ERROR]] Hubo un error al procesar el comando de MySQL: Compruebe la definición de variables."
	echo "[[ERROR]] $resul"
	echo "[ $date_log ] --> [[ERROR]] $resul" >> respaldo.log
	# Se elimina el archivo creado, pues no contiene nada relevante.
	rm -fr ${bd}_${fecha}.sql
	exit 0
fi

