# Influencia de las islas de calor en el carbono de los suelos urbanos de Santiago

> Proyecto final del curso *Visualización de datos medioambientales con R (*AGP3141-1), basado en la propuesta de tesis doctoral "Influencia del microclima térmico y las propiedades físicas en la dinámica del carbono en suelos urbanos de Santiago de Chile".
>
> Todos los datos de este repositorio son simulados y fueron generados con el script `scripts/01_simular_datos.R`, con efectos definidos a partir de la hipótesis de la tesis, solo con fines de práctica para el curso. El muestreo real se hará en primavera-verano 2026-2027.

## Cómo se generaron los datos

Los datos fueron generados con ayuda de Claude (Anthropic), en septiembre de 2026, a partir del siguiente pedido (traducido): "puedes ayudarme a crear los datos que necesito, basados en mi proyecto de doctorado? Como aún no hemos ido a terreno, no tengo ningún dato."

Para generar los datos se usaron los siguientes elementos del proyecto de tesis:

- **Diseño de muestreo**: 120 áreas verdes de Santiago, estratificadas por tipo de cobertura (parque de césped, borde de carretera y bosque urbano), calidad de manejo (bueno y deficiente) y quintil de temperatura superficial de verano (Q1 a Q5).
- **Variables y métodos previstos**: NDVI y NDMI; compactación con penetrómetro; humedad, temperatura y conductividad eléctrica con sensor TEROS-12; textura, densidad aparente, fragmentos rocosos y estabilidad de agregados; carbono orgánico del suelo y sus fracciones (COP y COAM) a 0-10 y 10-20 cm; y respiración microbiana con MicroResp a 20, 30 y 40 °C y 30 y 70% de la capacidad de retención de agua.
- **Hipótesis**: los suelos con mayor intensidad de la isla de calor, textura gruesa, menor NDVI/NDMI y manejo deficiente tendrían menos carbono orgánico y más respiración microbiana.

A partir de eso, Claude escribió el script `scripts/01_simular_datos.R`, que genera los datos con efectos definidos según la hipótesis e introduce datos ausentes a propósito (MCAR, MAR y MNAR), para la actividad sobre datos faltantes del curso. Los valores de los efectos y de la variabilidad fueron elegidos para ser plausibles y no provienen de mediciones. Después, los efectos se ajustaron para que las diferencias entre tratamientos fueran más claras.

## Preguntas exploratorias

1.  ¿El COS es menor en las áreas verdes ubicadas en las zonas más cálidas de la ciudad?
2.  ¿La calidad del manejo y el tipo de cobertura modifican esa relación?
3.  ¿La textura del suelo cambia la respuesta del COS al calor?
4.  ¿La respiración microbiana aumenta con la temperatura y depende de la humedad?

## Cómo reproducir

1.  Abrir `doctorado_cos_suelos_urbanos_santiago.Rproj` en RStudio.
2.  Instalar los paquetes con las mismas versiones usadas: `renv::restore()`.
3.  Ejecutar `scripts/01_simular_datos.R` desde la raíz del repositorio (genera los CSV en `datos/`, semilla fija `set.seed(2026)`).
4.  Ejecutar `scripts/02_eda.R` desde la raíz (genera las figuras exploratorias en `figuras/`).
5.  Renderizar los informes de `scripts/` con Quarto (leen los datos desde `../datos/`):
    - `03_informe_borrador.qmd`: borrador del proyecto final.
    - `04_group_by_nest.qmd`: Actividad 9, Q^10^ de la respiración por sitio con `nest()` + `map()` + `broom`.
    - `05_validacion_diccionario.qmd`: Actividad 10, mini diccionario y función de validación de 3 variables.

## Estructura

```         
cos_suelos_urbanos_santiago/
├── datos/      #tablas en formato ordenado (tidy), una por tipo de dato
├── scripts/
│   ├── 01_simular_datos.R       #genera los datos simulados
│   ├── 02_eda.R                 #análisis exploratorio y datos ausentes
│   ├── 03_informe_borrador.qmd  #borrador del proyecto final (storytelling)
│   ├── 03_informe_borrador.html #informe renderizado
│   ├── 04_group_by_nest.qmd     #actividad 9: un modelo por sitio (Q10)
│   ├── 04_group_by_nest.html    #actividad renderizada
│   ├── 05_validacion_diccionario.qmd   #actividad 10: diccionario y validación
│   └── 05_validacion_diccionario.html  #actividad renderizada
├── figuras/    #salidas exploratorias del EDA, numeradas 01_, 02_, ...
├── renv/ y renv.lock            #entorno reproducible de paquetes (renv)
├── doctorado_cos_suelos_urbanos_santiago.Rproj   #proyecto de RStudio
├── .gitignore
└── README.md
```

## Diccionario de datos

Todas las tablas se unen por `sitio_id`. Fechas en ISO 8601 (AAAA-MM-DD). Datos ausentes = `NA`.

| Archivo | Una fila = | Variables |
|------------------------|------------------------|------------------------|
| `sitios.csv` | sitio (n = 120) | `fecha_muestreo`, `latitud`, `longitud`, `tipo_cobertura` (parque_cesped, borde_carretera, bosque_urbano), `manejo` (bueno, deficiente), `quintil_icu` (Q1–Q5), `lst_verano_c` (°C), `ndvi`, `ndmi` |
| `suelo_terreno.csv` | sitio | `cone_index_mpa` (penetrómetro), `humedad_vol_m3_m3`, `temp_suelo_c`, `ce_ds_m` (TEROS-12) |
| `suelo_fisica.csv` | sitio × profundidad | `profundidad_cm` (0-10, 10-20), `arena_pct`, `limo_pct`, `arcilla_pct`, `fragmentos_rocosos_pct`, `da_g_cm3`, `estabilidad_agregados_pct` |
| `suelo_carbono.csv` | sitio × profundidad | `cos_pct`, `cop_pct`, `coam_pct` |
| `suelo_respiracion.csv` | sitio × temperatura × humedad × réplica (0-10 cm) | `temp_incubacion_c` (20, 30, 40), `humedad_cra_pct` (30, 70), `replica` (1–3), `rm_ug_co2c_g_h` |

### Valores esperados por variable

Rangos físicamente plausibles para suelos minerales de áreas verdes de Santiago. Sirven para validar tanto los datos simulados como los de terreno y laboratorio. La validación de `tipo_cobertura`, `cos_pct` y `cone_index_mpa` está implementada en `scripts/05_validacion_diccionario.qmd`.

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

## Datos ausentes incluidos a propósito

| Variable | Mecanismo | Causa simulada |
|------------------------|------------------------|------------------------|
| `cos_pct`, `cop_pct`, `coam_pct` | MCAR | \~3% de muestras extraviadas (etiqueta o bolsa perdida) |
| `rm_ug_co2c_g_h` | MCAR | \~2% de pocillos contaminados o con burbujas |
| `da_g_cm3` | MAR | con \> 20% de fragmentos rocosos el cilindro no entra |
| `cone_index_mpa` | MNAR | el penetrómetro no mide sobre 5 MPa |
| `rm_ug_co2c_g_h` | MNAR | la placa MicroResp se satura con respiración muy alta |
