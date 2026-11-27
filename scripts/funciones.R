#funciones.R -----------------------------------------------------------------
#Funciones propias del proyecto. Se usan en index.qmd y en
#scripts/04_validacion_diccionario.qmd (un solo lugar para no duplicar código).

#validar_suelos() --------------------------------------------------------------
#Revisa 3 variables según el diccionario de datos (datos/README.md):
# - tipo_cobertura: solo parque_cesped, borde_carretera o bosque_urbano, sin NA
#   (es parte del diseño del muestreo, todos los sitios deben tenerla)
# - cos_pct: entre 0 y 15 %, NA permitido (~3 % de muestras perdidas, MCAR)
# - cone_index_mpa: entre 0 y 5 MPa, NA permitido (límite del penetrómetro, MNAR)
#Entrada: una tabla con esas 3 columnas.
#Salida: imprime OK o FALLA para cada revisión y devuelve (de forma invisible)
# TRUE si todo está bien y FALSE si algo falla.
validar_suelos <- function(datos) {
  #estructural: %in% da FALSE para un NA o una categoría que no está en el diseño
  cobertura_ok <- all(datos$tipo_cobertura %in%
                        c("parque_cesped", "borde_carretera", "bosque_urbano"))

  #contenido: COS entre 0 y 15 % (na.rm = TRUE ignora los NA, que están permitidos)
  cos_ok <- all(datos$cos_pct >= 0 & datos$cos_pct <= 15, na.rm = TRUE)

  #contenido: resistencia a la penetración entre 0 y 5 MPa (NA permitido)
  cone_ok <- all(datos$cone_index_mpa >= 0 & datos$cone_index_mpa <= 5,
                 na.rm = TRUE)

  #ifelse(): si la revisión dio TRUE escribe "OK"; si dio FALSE (o NA), "FALLA".
  #isTRUE() evita un error cuando la columna no existe y la revisión queda vacía.
  marca <- function(x) ifelse(isTRUE(x), "OK", "FALLA")

  cat("Cobertura válida (estructural):  ", marca(cobertura_ok), "\n")
  cat("COS 0-15% (contenido):          ", marca(cos_ok),       "\n")
  cat("Penetrómetro 0-5 MPa (contenido):", marca(cone_ok),      "\n")

  invisible(isTRUE(cobertura_ok) & isTRUE(cos_ok) & isTRUE(cone_ok))
}
