# 01_simular_datos.R ------------------------------------------------------
# Simula datos plausibles para el proyecto de tesis:
# "Influencia del microclima térmico y las propiedades físicas en la
#  dinámica del carbono en suelos urbanos de Santiago de Chile"
#
# Los datos NO son reales: se generan con efectos definidos a partir de la
# hipótesis (ICU, textura, manejo y cobertura afectan COS, COAM y RM), para
# que los tratamientos sí se diferencien y el EDA tenga algo que mostrar.
# También se introducen NA a propósito (MCAR, MAR y MNAR) para la actividad.

library(dplyr)
library(tidyr)
library(readr)

set.seed(2026)
dir.create("datos", showWarnings = FALSE)

acotar <- function(x, min, max) pmin(pmax(x, min), max)

# 1. Diseño estratificado: 3 coberturas x 2 manejos x 5 quintiles x 4 = 120
base <- expand_grid(
  tipo_cobertura = c("parque_cesped", "borde_carretera", "bosque_urbano"),
  manejo         = c("bueno", "deficiente"),
  q              = 1:5,
  rep            = 1:4
) |>
  slice_sample(prop = 1) |>
  mutate(sitio_id = sprintf("S%03d", row_number()))

n <- nrow(base)

# 2. Variables a nivel de sitio (incluye variables "verdaderas" latentes)
base <- base |>
  mutate(
    quintil_icu    = paste0("Q", q),
    fecha_muestreo = as.Date("2026-11-02") + sample(0:117, n, replace = TRUE),
    latitud        = round(runif(n, -33.60, -33.35), 5),
    longitud       = round(runif(n, -70.78, -70.50), 5),
    lst_verano_c   = round(28.9 + (q - 1) * 1.1 + rnorm(n, 0, 0.4), 1),
    ndvi = round(acotar(
      case_when(tipo_cobertura == "bosque_urbano" ~ 0.62,
                tipo_cobertura == "parque_cesped" ~ 0.52,
                TRUE ~ 0.32) +
        if_else(manejo == "bueno", 0.08, -0.04) -
        0.025 * (q - 3) + rnorm(n, 0, 0.06), 0.05, 0.90), 3),
    ndmi = round(acotar(0.7 * ndvi - 0.25 + rnorm(n, 0, 0.04), -0.4, 0.5), 3),
    # textura latente del sitio
    arcilla_sitio = acotar(rnorm(n, 22, 8), 5, 45),
    arena_sitio   = acotar(rnorm(n, 45, 12), 10, 90 - arcilla_sitio),
    # compactación verdadera (antes de censurar)
    cone_real = acotar(
      case_when(tipo_cobertura == "borde_carretera" ~ 3.4,
                tipo_cobertura == "parque_cesped" ~ 2.0,
                TRUE ~ 1.4) +
        if_else(manejo == "deficiente", 0.5, 0) +
        0.1 * (q - 3) + rnorm(n, 0, 1.0), 0.3, 8),
    humedad_vol_m3_m3 = round(acotar(
      0.24 + if_else(manejo == "bueno", 0.04, -0.03) - 0.015 * (q - 3) +
        case_when(tipo_cobertura == "bosque_urbano" ~ 0.02,
                  tipo_cobertura == "borde_carretera" ~ -0.04,
                  TRUE ~ 0) + rnorm(n, 0, 0.04), 0.05, 0.45), 3),
    temp_suelo_c = round(24 + 1.6 * (q - 3) - 8 * (ndvi - 0.5) +
                           rnorm(n, 0, 1.2), 1),
    ce_ds_m = round(acotar(rlnorm(n, log(0.5), 0.5) +
                             if_else(tipo_cobertura == "borde_carretera", 0.3, 0),
                           0.05, 4), 2)
  )

# 3. Datos por sitio x profundidad
perfil <- base |>
  crossing(profundidad_cm = c("0-10", "10-20")) |>
  mutate(
    prof2 = profundidad_cm == "10-20",
    m = n(),
    arcilla_pct = round(acotar(arcilla_sitio + if_else(prof2, 1.5, 0) +
                                 rnorm(m, 0, 1.5), 3, 50), 1),
    arena_pct = round(acotar(arena_sitio + rnorm(m, 0, 1.5), 5,
                             95 - arcilla_pct), 1),
    limo_pct = round(100 - arcilla_pct - arena_pct, 1),
    fragmentos_rocosos_pct = round(acotar(
      rlnorm(m, log(if_else(tipo_cobertura == "borde_carretera", 12, 5)), 0.7) +
        if_else(prof2, 2, 0), 0, 45), 1),
    da_g_cm3 = round(acotar(1.25 + 0.12 * (cone_real - 2) +
                              if_else(prof2, 0.08, 0) +
                              rnorm(m, 0, 0.07), 0.9, 1.8), 2),
    cos_pct = round(exp(
      log(2.3) + if_else(prof2, log(0.65), 0) +
        if_else(manejo == "bueno", 0.20, -0.10) +
        case_when(tipo_cobertura == "bosque_urbano" ~ 0.15,
                  tipo_cobertura == "borde_carretera" ~ -0.25,
                  TRUE ~ 0) -
        0.08 * (q - 3) +
        0.012 * (arcilla_pct - 22) - 0.006 * (arena_pct - 45) +
        rnorm(m, 0, 0.18)), 2),
    frac_coam = acotar(0.55 + 0.006 * (arcilla_pct - 22) - 0.025 * (q - 3) +
                         if_else(prof2, 0.06, 0) + rnorm(m, 0, 0.04),
                       0.30, 0.85),
    coam_pct = round(cos_pct * frac_coam, 2),
    cop_pct  = round(acotar(cos_pct - coam_pct + rnorm(m, 0, 0.03), 0.01, 10), 2),
    estabilidad_agregados_pct = round(acotar(
      35 + 9 * cos_pct + 0.3 * (arcilla_pct - 22) - 3 * (cone_real - 2) +
        rnorm(m, 0, 6), 10, 95), 1)
  )

# 4. Respiración microbiana (MicroResp), solo 0-10 cm
resp <- perfil |>
  filter(profundidad_cm == "0-10") |>
  mutate(basal = 0.35 * cos_pct^0.9 * exp(0.10 * (q - 3)) *
           if_else(manejo == "bueno", 1.10, 0.95) *
           rlnorm(n(), 0, 0.15)) |>
  select(sitio_id, basal) |>
  crossing(temp_incubacion_c = c(20, 30, 40),
           humedad_cra_pct   = c(30, 70),
           replica           = 1:3) |>
  mutate(
    f_temp = 2^((temp_incubacion_c - 20) / 10),          # Q10 = 2
    f_hum  = case_when(humedad_cra_pct == 70 ~ 1,
                       temp_incubacion_c == 40 ~ 0.40,   # estrés hídrico
                       TRUE ~ 0.55),
    rm_ug_co2c_g_h = round(basal * f_temp * f_hum *
                             rlnorm(n(), 0, 0.08), 3)
  )

# 5. Introducir datos ausentes ------------------------------------------------
# MNAR: el penetrómetro no supera 5 MPa -> los suelos más compactados quedan NA
base <- base |>
  mutate(cone_index_mpa = if_else(cone_real > 5, NA_real_, round(cone_real, 2)))

# MAR: con muchos fragmentos rocosos (>20 %) el cilindro no entra -> DA faltante
# MCAR: ~3 % de las muestras de carbono se pierden (etiqueta/bolsa extraviada)
perfil <- perfil |>
  mutate(
    da_g_cm3 = if_else(fragmentos_rocosos_pct > 20 & runif(n()) < 0.8,
                       NA_real_, da_g_cm3),
    perdida  = runif(n()) < 0.03,
    cos_pct  = if_else(perdida, NA_real_, cos_pct),
    cop_pct  = if_else(perdida, NA_real_, cop_pct),
    coam_pct = if_else(perdida, NA_real_, coam_pct)
  )

# MNAR: la placa MicroResp se satura con respiración muy alta (> 4.5)
# MCAR: ~2 % de pocillos contaminados o con burbujas
resp <- resp |>
  mutate(rm_ug_co2c_g_h = if_else(rm_ug_co2c_g_h > 4.5 | runif(n()) < 0.02,
                                  NA_real_, rm_ug_co2c_g_h))

# 6. Guardar (fechas en ISO) --------------------------------
base |>
  select(sitio_id, fecha_muestreo, latitud, longitud, tipo_cobertura,
         manejo, quintil_icu, lst_verano_c, ndvi, ndmi) |>
  arrange(sitio_id) |>
  write_csv("datos/sitios.csv")

base |>
  select(sitio_id, cone_index_mpa, humedad_vol_m3_m3, temp_suelo_c, ce_ds_m) |>
  arrange(sitio_id) |>
  write_csv("datos/suelo_terreno.csv", na = "NA")

perfil |>
  select(sitio_id, profundidad_cm, arena_pct, limo_pct, arcilla_pct,
         fragmentos_rocosos_pct, da_g_cm3, estabilidad_agregados_pct) |>
  arrange(sitio_id, profundidad_cm) |>
  write_csv("datos/suelo_fisica.csv", na = "NA")

perfil |>
  select(sitio_id, profundidad_cm, cos_pct, cop_pct, coam_pct) |>
  arrange(sitio_id, profundidad_cm) |>
  write_csv("datos/suelo_carbono.csv", na = "NA")

resp |>
  select(sitio_id, temp_incubacion_c, humedad_cra_pct, replica, rm_ug_co2c_g_h) |>
  arrange(sitio_id, temp_incubacion_c, humedad_cra_pct, replica) |>
  write_csv("datos/suelo_respiracion.csv", na = "NA")
