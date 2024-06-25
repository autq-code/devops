#!/bin/bash

# Definir variables
ruta_actual=$(pwd)
nombre_archivo="reporte.txt"

# Abrir archivo en modo escritura
archivo="$ruta_actual/$nombre_archivo"
touch "$archivo"

# Función para obtener fecha de modificación en formato mmyyyy
function obtener_fecha_modificacion() {
  fecha=$(stat "$1" | awk '{print $13, $14}')
  fecha_formato=$(date -d "$fecha" +%m%Y)
  echo "$fecha_formato"
}

# Función para obtener peso de archivo en megas
function obtener_peso_mega() {
  peso=$(stat "$1" | awk '{print $10}')
  peso_mega=$(echo "scale=2; $peso / 1048576" | bc)
  echo "$peso_mega"
}

# Recorrer directorios recursivamente
find "$ruta_actual" -type f -exec bash -c '
  ruta_archivo="$0"
  fecha_modificacion=$(obtener_fecha_modificacion "$ruta_archivo")
  peso_mega=$(obtener_peso_mega "$ruta_archivo")

  # Escribir información en el archivo
  echo "$ruta_archivo;$fecha_modificacion;$peso_mega" >> "$archivo"
' {} \;

# Mensaje final
echo "Reporte generado en: $archivo"

