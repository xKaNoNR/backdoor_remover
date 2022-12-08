#!/bin/bash

# Autor: Robinson Rojas (xKaNoNR)


# Colores
endColor="\033[0m\e[0m"
greenColor="\e[0;32m\033[1m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"

Banner="▄▄▄▄·  ▄▄▄·  ▄▄· ▄ •▄ ·▄▄▄▄              ▄▄▄      ▄▄▄  ▄▄▄ .• ▌ ▄ ·.        ▌ ▐·▄▄▄ .▄▄▄  
▐█ ▀█▪▐█ ▀█ ▐█ ▌▪█▌▄▌▪██▪ ██ ▪     ▪     ▀▄ █·    ▀▄ █·▀▄.▀··██ ▐███▪▪     ▪█·█▌▀▄.▀·▀▄ █·
▐█▀▀█▄▄█▀▀█ ██ ▄▄▐▀▀▄·▐█· ▐█▌ ▄█▀▄  ▄█▀▄ ▐▀▀▄     ▐▀▀▄ ▐▀▀▪▄▐█ ▌▐▌▐█· ▄█▀▄ ▐█▐█•▐▀▀▪▄▐▀▀▄ 
██▄▪▐█▐█ ▪▐▌▐███▌▐█.█▌██. ██ ▐█▌.▐▌▐█▌.▐▌▐█•█▌    ▐█•█▌▐█▄▄▌██ ██▌▐█▌▐█▌.▐▌ ███ ▐█▄▄▌▐█•█▌
·▀▀▀▀  ▀  ▀ ·▀▀▀ ·▀  ▀▀▀▀▀▀•  ▀█▄▀▪ ▀█▄▀▪.▀  ▀    .▀  ▀ ▀▀▀ ▀▀  █▪▀▀▀ ▀█▄▀▪. ▀   ▀▀▀ .▀  ▀"



# Funcion para iterrumpir el Escaneo.
function ctrl_c(){
  echo -e "\n${redColor}[!]Saliendo del Escaneo....${endColor}\n"
  sleep 1
  tput cnorm # Volver el cursor a la normalidad.
  exit 1
}


# Control+C
  trap ctrl_c INT


# Panel de Ayuda
function help_panel(){
  tput civis
  echo -e "${purpleColor}$Banner${endColor}"
  echo -e "\n${yellowColor}[+] Modo de uso: ./backdoor_remover.sh [Parametro]${endColor}"
  echo -e "${purpleColor}Parametros: -c${endColor} ${grayColor}Se realizara un escaneo de las conexion inusuales y se guiara para su tratamiento.${endColor}"
  echo -e "\t${purpleColor}    -h${endColor} ${grayColor}Se mostrara este panel de Ayuda!${endColor}\n"
  tput cnorm # Volver el cursor a la normalidad.
  exit 1
  }


function variables(){
  netstat=$(netstat -anop)  
# Cabeceras de las conexion Para Mostrar de manera Ordenada
  head_connecctions=$(echo "$netstat" | head -n 2 | tail -n 1)
# Linea con el detalle de las conexiones Inusuales
  connections_malicius=$(echo "$netstat" | grep -E ':[0-9]{1,5}' | grep -E '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' | grep -vE "LISTEN|0.0.0.0|::|ESTABLISHED|TIME_WAIT")
# Obtencion del PDI de las conexiones para su tratamiento
  pdi=$(echo "$connections_malicius" | awk -F "    " '{print $8}' | awk 'match($0, /^[^\/]+/){print substr($0, RSTART, RLENGTH)}')
# Nombre de los archivos que intentar establecer una conexion
  file_name=$(echo "$connections_malicius" | awk -F "    " '{print $8}' | awk -F "/" '{print $2}')
}


function complete_scan(){
  tput civis
  echo -e "${purpleColor}$Banner${endColor}"
  echo -e "\n${blueColor}[*] Iniciando el escaneo...${endColor}"
  if [ "$connections_malicius" ]; then # Si se detecta contenido en la variable $connections_malicius se mostrara.
    echo -e "${redColor}[!] Se han detectado conexiones inusales en su equipo!${endColor}\n"
    echo -e "$head_connecctions"
    echo -e "${redColor}$connections_malicius${endColor}\n"
    echo -e "${yellowColor}Desea eliminar los procesos encontrados si/no: ${endColor}" && read si_no;
    if [ "$si_no" = si ]; then # Si se decide eliminar los procesos se procede hacer un kill de los mismos.
      echo -e "${blueColor}[*] Eliminando los procesos...${endColor}"
      kill $pdi && echo -e "${greenColor}[*] Las conexiones inusuales han sido eliminadas!${endColor}\n"   
    else
      if [ "$si_no" = no ]; then # Si no se decide elimar se sale del proceso con una alerta.
      echo -e "${redColor}[!] No se Eliminaron las conexiones por favor tomar Precauciones!${endColor}"
      fi
    fi
      if [ ! -z "$pdi" ]; then # Si el proceso de eliminacion fue exitoso la variable quedara vacia y se procede a mostrar los archivos maliciosos.
      echo -e "${yellowColor}[!] A continuacion se muestran las rutas de los archivos maliciosos:${endColor}"
        for file in $file_name; do
          find / -name "$file" 2>/dev/null
        done
      fi
  else # Si no se encuentran conexiones inusuales se la del programa con una slida exitosa.
    echo -e "${greenColor}[*] No se han detectado conexiones inusales en su equipo!${endColor}\n"
  fi
  }


# Indicadores para asignarle un valor a cada variable y asi poder crear las sentencias.
declare -i parameter_counter=0

# Aqui indicaremos todas las opciones que llevara nuestro programa.
while getopts "hrc" arg; do
  case $arg in
    h) ;;
    c) let parameter_counter+=1;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  variables; complete_scan
#elif [ $parameter_counter -eq 2 ]; then
#  Accion
else
  help_panel
fi

tput cnorm # Salida exitosa del escaneo.
exit 0

