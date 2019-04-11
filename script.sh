#Ejercicio 5. Crear una apalicación que escriba directamente sobre /etc/ne$
#! /bin/bash



verificacion_permisos(){	
		yo=$(whoami)
		if [ "$yo" = "root" ]
		then
			#copia
			menu
			cambios
		else
			echo "Usted no tiene permisos sobre el fichero interfaces. Vuelva a intentarlo como root"
		fi
}

copia(){
	fecha=$(date +%d-%m-%Y\ %H:%M:%S)
	cp /etc/network/interfaces /etc/network/interfaces"$fecha"
}

menu(){
		echo "Menú"
		echo "	1. Crear interfaz dinámica con DHCP"
		echo "	2. Crear interfaz estática"
		echo "	3. Ver contenido del fichero interfaces"
		echo " "
		read -p "Introduzca una opción: " opcion
		while [ "$opcion" -ne 1 -a "$opcion" -ne 2 -a "$opcion" -ne 3 ]
		do
			echo "Error. Debe ser un número comprendido entre el 1 y el 2"
			echo "Menú"
			echo "	1. Crear interfaz dinámica con DHCP"
			echo "	2. Crear interfaz estática"
			echo "	3. Ver contenido del fichero interfaces"
			echo " "
			read -p "Introduzca una opción: " opcion		
		done
}

f_sobreescribir(){
		read -p "¿Quiere sobreescribir lo que hay en el fichero interfaces? [s/n]" sobreescribir
		while [ "$sobreescribir" != "s" -a "$sobreescribir" != "n" ]
		do
			echo "Error. Debe elegir si sobreescribir o no"
			read -p "¿Quiere sobreescribir lo que hay en el fichero interfaces? [s/n]" sobreescribir
		done
}

dinamica(){
	#interfaz=$(ip a | egrep '^2' | cut -d " " -f 2 | tr -d :) 
	if [ "$sobreescribir" = "s" ]
	then
		echo 'auto ' $interfaz > /etc/network/interfaces
	else
		echo 'auto ' $interfaz >> /etc/network/interfaces
	fi
	echo 'allow-hotplug ' $interfaz >> /etc/network/interfaces
	echo 'iface ' $interfaz 'inet dhcp' >> /etc/network/interfaces
	echo ' ' >> /etc/network/interfaces
}

f_mascara(){
	echo $ip_escribir | egrep -q '/32$'
	respuesta=$?
	if [ "$respuesta" -eq 0 ]
	then
		mascara=255.255.255.255
	fi
	echo $ip_escribir | egrep -q '/24$'
	respuesta=$?
	if [ "$respuesta" -eq 0 ]
	then
		mascara=255.255.255.0
	fi
	echo $ip_escribir | egrep -q '/16$'
	respuesta=$?
	if [ "$respuesta" -eq 0 ]
	then
		mascara=255.255.0.0	
	fi
	echo $ip_escribir | egrep -q '/8$'
	respuesta=$?
	if [ "$respuesta" -eq 0 ]
	then
		mascara=255.0.0.0		
	fi
}

estatica(){
	#interfaz=$(ip a | egrep '^2' | cut -d " " -f 2 | tr -d :)
	f_mascara
	
	
	if [ "$sobreescribir" = "s" ]
	then
		echo 'auto ' $interfaz > /etc/network/interfaces
	else
		echo 'auto ' $interfaz >> /etc/network/interfaces
	fi
	echo 'iface ' $interfaz ' inet static' >> /etc/network/interfaces
	echo 'address ' $ip_escribir | cut -d "/" -f 1 >> /etc/network/interfaces
	echo 'netmask ' $mascara >> /etc/network/interfaces
	echo ' ' >> /etc/network/interfaces
}

datos(){
	read -p "Introduce la IP: " ip_escribir
	echo $ip_escribir | egrep -q '([0-9]{1,3}\.){3}[0-9]{1,3}\/(32)|(24)|(16)|(8))'
	ip_correcta=$?
	while [ "$ip_correcta" -ne 0 ]
	do
		echo "Error. Debe introducir la IP en formato CIDR"
		read -p "Introduce la IP: " ip_escribir
		echo $ip_escribir | egrep -q '([0-9]{1,3}\.){3}[0-9]{1,3}\/(32)|(24)|(16)|(8))'
		ip_correcta=$?		
	done
}

interfaces_repetidas(){
	inter_info=$(cat /etc/network/interfaces | egrep '^a' | cut -d " " -f 3)
	for i in $inter_info
	do
		if [ $interfaz = $i ]
		then
			echo " "
			echo 'Error. La interfaz' $i 'ya está siendo usada '
			echo " "
			#
			#
			#
			#
			#
			#
			#
			#####VOY POR AQUI PERO TENGO QUE ORDENARLO TODO
		fi
	done
}

elegir_interfaz(){
    echo "Estas son las interfaces disponibles: "
    interfaces=$(ip a | egrep '^[a-zA-Z0-9]' | cut -d " " -f 2 | tr -d :)
	contador=$(ip a | egrep '^[a-zA-Z0-9]' | cut -d " " -f 2 | tr -d : | wc -l)
	sumador=0
	while [ $contador -ne 0 ]
	do
		sumador=$(($sumador+1))
		echo -n $sumador '- ' 
		echo $interfaces | cut -d " " -f $sumador
		contador=$(($contador-1))
	done
	echo " "
	read -p "Introduce la opción (en número): " eleccion
	interfaz=$(echo $interfaces | cut -d " " -f $eleccion)
	if [ $sobreescribir = 'n' ]
	then
		interfaces_repetidas
	fi
	while [ $eleccion \> $sumador ]
	do
		echo "ERROR. Debe ser un número indicado anteriormente"
		read -p "Introduce la opción (en número): " eleccion
		interfaz=$(echo $interfaces | cut -d " " -f $eleccion)
		if [ $sobreescribir = 'n' ]
		then
			interfaces_repetidas
		fi
	done
}

cambios(){
		if [ "$opcion" -eq 1 ]
		then
			f_sobreescribir
            elegir_interfaz
			dinamica	
		elif [ "$opcion" -eq 2 ]
		then
			f_sobreescribir
			elegir_interfaz
			datos
			estatica
		else
			echo " "
			echo "------------------------------------------------------------------"
			echo " "
			cat /etc/network/interfaces
			echo " "
			echo "------------------------------------------------------------------"			
		fi
		#anadir ip
		#read -p "Introduce la IP: " ip_escribir
		#echo $ip_escribir >> /etc/network/interfaces
}

verificacion_permisos
