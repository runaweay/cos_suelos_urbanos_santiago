# Diccionario de datos

## Tablas

- `crudos/`: datos tal como salen de la simulación (en el futuro, de terreno y laboratorio). No se editan a mano; los crea `scripts/01_simular_datos.R`.
- `procesados/`: tablas unidas y con variables derivadas, listas para el informe; las crea `scripts/02_eda.R`.

Todas las tablas se unen por `sitio_id`. Fechas en ISO 8601 (AAAA-MM-DD). Datos ausentes = `NA`.

| Archivo | Una fila = | Variables |
|------------------------|------------------------|------------------------|
| `crudos/sitios.csv` | sitio (n = 120) | `fecha_muestreo`, `latitud`, `longitud`, `tipo_cobertura` (parque_cesped, borde_carretera, bosque_urbano), `manejo` (bueno, deficiente), `quintil_icu` (Q1–Q5), `lst_verano_c` (°C), `ndvi`, `ndmi` |
| `crudos/suelo_terreno.csv` | sitio | `cone_index_mpa` (penetrómetro), `humedad_vol_m3_m3`, `temp_suelo_c`, `ce_ds_m` (TEROS-12) |
| `crudos/suelo_fisica.csv` | sitio × profundidad | `profundidad_cm` (0-10, 10-20), `arena_pct`, `limo_pct`, `arcilla_pct`, `fragmentos_rocosos_pct`, `da_g_cm3`, `estabilidad_agregados_pct` |
| `crudos/suelo_carbono.csv` | sitio × profundidad | `cos_pct`, `cop_pct`, `coam_pct` |
| `crudos/suelo_respiracion.csv` | sitio × temperatura × humedad × réplica (0-10 cm) | `temp_incubacion_c` (20, 30, 40), `humedad_cra_pct` (30, 70), `replica` (1–3), `rm_ug_co2c_g_h` |
| `procesados/suelo_analisis.csv` | sitio × profundidad | todas las variables de las tablas crudas (excepto respiración) + `textura_grupo`, `stock_cos_kg_m2`, `frac_coam` |

## Valores esperados por variable

Rangos físicamente plausibles para suelos minerales de áreas verdes de Santiago. Sirven para validar tanto los datos simulados como los de terreno y laboratorio. La validación de `tipo_cobertura`, `cos_pct` y `cone_index_mpa` está implementada en `scripts/04_validacion_diccionario.qmd`.

| Variable | Tipo | Unidad | Valores esperados | NA |
|---------------|---------------|---------------|---------------|---------------|
| `sitio_id` | identificador | \- | S001–S120, único por sitio | no |
| `fecha_muestreo` | fecha | AAAA-MM-DD | primavera-verano 2026-2027 | no |
| `latitud`, `longitud` | numérica | grados decimales | dentro del área urbana de Santiago (≈ -33.7 a -33.3; -70.9 a -70.4) | no |
| `tipo_cobertura` | categórica | \- | parque_cesped, borde_carretera, bosque_urbano | no |
| `manejo` | categórica | \- | bueno, deficiente | no |
| `quintil_icu` | categórica ordinal | \- | Q1-Q5 | no |
| `lst_verano_c` | numérica | °C | 20 - 45 | no |
| `ndvi`, `ndmi` | numérica | \- | -1 - 1 | no |
| `cone_index_mpa` | numérica | MPa | 0 - 5 (límite del penetrómetro) | sí (MNAR) |
| `humedad_vol_m3_m3` | numérica | m³/m³ | 0 - 0.6 | no |
| `temp_suelo_c` | numérica | °C | -5 - 60 | no |
| `ce_ds_m` | numérica | dS/m | ≥ 0 | no |
| `profundidad_cm` | categórica | cm | 0-10, 10-20 | no |
| `arena_pct`, `limo_pct`, `arcilla_pct` | numérica | \% | 0 - 100; la suma de las tres = 100 | no |
| `fragmentos_rocosos_pct` | numérica | \% | 0 - 100 | no |
| `da_g_cm3` | numérica | g/cm³ | 0.8 - 2.0 | sí (MAR) |
| `estabilidad_agregados_pct` | numérica | \% | 0 - 100 | no |
| `cos_pct` | numérica | \% | 0 - 15 | sí (MCAR) |
| `cop_pct`, `coam_pct` | numérica | \% | ≥ 0 y `cop_pct` + `coam_pct` ≈ `cos_pct` | sí (MCAR) |
| `temp_incubacion_c` | numérica | °C | 20, 30, 40 | no |
| `humedad_cra_pct` | numérica | \% CRA | 30, 70 | no |
| `replica` | entera | \- | 1 - 3 | no |
| `rm_ug_co2c_g_h` | numérica | µg CO₂-C/g/h | ≥ 0 | sí (MCAR y MNAR) |


## Variables derivadas (calculadas en los scripts, no están en los CSV)

| Variable | Dónde | Regla |
|------------------------|------------------------|------------------------|
| `textura_grupo` | `02_eda.R` | gruesa si `arena_pct` ≥ 55; si no, fina si `arcilla_pct` ≥ 30; si no, media |
| `stock_cos_kg_m2` | `02_eda.R` | `cos_pct` × `da_g_cm3` × 10 cm × (1 − `fragmentos_rocosos_pct`/100) / 10 |
| `frac_coam` | `02_eda.R` | `coam_pct` / (`cop_pct` + `coam_pct`) |
| `q10` | `03_group_by_nest.qmd` | exp(10 × pendiente) del modelo log(RM) ~ temperatura, por sitio |

## Parámetros usados en la simulación

Valores definidos en `scripts/01_simular_datos.R`. Fueron elegidos para ser plausibles y reflejar la hipótesis de la tesis; no provienen de mediciones.

| Variable | Cómo se simuló |
|------------------------|------------------------|
| Diseño | 120 sitios = 3 coberturas × 2 manejos × 5 quintiles × 4 repeticiones; `set.seed(2026)` |
| `fecha_muestreo` | al azar entre el 2026-11-02 y el 2027-02-27 |
| `latitud`, `longitud` | al azar entre -33,60 y -33,35 y entre -70,78 y -70,50 (sin patrón espacial) |
| `lst_verano_c` | 28,9 °C en Q1 + 1,1 °C por quintil (Q5 ≈ 33,3 °C), desviación estándar (DE) 0,4 |
| `ndvi` | bosque 0,62, césped 0,52, borde 0,32; +0,08 buen manejo, -0,04 deficiente; -0,025 por quintil; límites 0,05-0,90 |
| `ndmi` | 0,7 × NDVI - 0,25, DE 0,04; límites -0,4 a 0,5 |
| `cone_index_mpa` | borde 3,4, césped 2,0, bosque 1,4 MPa; +0,5 con manejo deficiente; +0,1 por quintil; DE 1,0 |
| `humedad_vol_m3_m3` | 0,24; +0,04 buen manejo, -0,03 deficiente; -0,015 por quintil; límites 0,05-0,45 |
| `temp_suelo_c` | 24 °C + 1,6 °C por quintil, menos con más NDVI; DE 1,2 |
| `ce_ds_m` | mediana 0,5 dS/m (log-normal); +0,3 en borde de carretera |
| `arcilla_pct`, `arena_pct` | arcilla media 22 % (DE 8, 5-45 %); arena media 45 % (DE 12); limo = 100 - arena - arcilla |
| `fragmentos_rocosos_pct` | mediana 12 % en borde y 5 % en las otras coberturas; +2 % en 10-20 cm; máximo 45 % |
| `da_g_cm3` | 1,25 g/cm³ + 0,12 por MPa de compactación; +0,08 en 10-20 cm; límites 0,9-1,8 |
| `cos_pct` | 2,3 % de base (0-10 cm, césped, Q3); 10-20 cm x0,65; buen manejo +22 %, deficiente -10 %; bosque +16 %, borde -22 %; ~-8 % por quintil; +1,2 % por punto de arcilla y -0,6 % por punto de arena |
| `coam_pct`, `cop_pct` | COAM ≈ 55 % del COS (más con arcilla, menos con calor, +6 puntos en 10-20 cm); COP = COS - COAM |
| `estabilidad_agregados_pct` | 35 % + 9 por punto de COS, más con arcilla, menos con compactación; límites 10-95 % |
| `rm_ug_co2c_g_h` | basal = 0,35 × COS^0,9, sube con el quintil; Q10 = 2 (x1, x2 y x4 a 20, 30 y 40 °C); a 30 % CRA x0,55 (x0,40 a 40 °C) |

## Datos ausentes incluidos a propósito

| Variable | Mecanismo | Causa simulada |
|------------------------|------------------------|------------------------|
| `cos_pct`, `cop_pct`, `coam_pct` | MCAR | \~3% de muestras extraviadas (etiqueta o bolsa perdida) |
| `rm_ug_co2c_g_h` | MCAR | \~2% de pocillos contaminados o con burbujas |
| `da_g_cm3` | MAR | con \> 20% de fragmentos rocosos el cilindro no entra |
| `cone_index_mpa` | MNAR | el penetrómetro no mide sobre 5 MPa |
| `rm_ug_co2c_g_h` | MNAR | la placa MicroResp se satura con respiración muy alta |
