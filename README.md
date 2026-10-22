# cos_suelos_urbanos_santiago

> Todos los datos de este repositorio son simulados!y fueron generados con el script `scripts/01_simular_datos.R`, con efectos definidos a partir de la hipótesis de la tesis, solo con fines de práctica para el curso. El muestreo real se hará en primavera-verano 2026-2027.

Proyecto final del curso *Visualización de datos medioambientales con R*, basado en la propuesta de tesis doctoral "Influencia del microclima térmico y las propiedades físicas en la dinámica del carbono en suelos urbanos de Santiago de Chile".

## Preguntas exploratorias

1. El COS es menor en las áreas verdes ubicadas en las zonas más cálidas de la ciudad?
2. La calidad del manejo y el tipo de cobertura modifican esa relación?
3. La textura del suelo cambia la respuesta del COS al calor?
4. La respiración microbiana aumenta con la temperatura y depende de la humedad?

## Cómo reproducir

1. Ejecutar `scripts/01_simular_datos.R` desde la raíz del repositorio (genera los CSV en `datos/`).
2. Ejecutar `scripts/02_eda.R` desde la raíz (genera las figuras exploratorias en `figuras/`).
3. Renderizar `scripts/03_informe_borrador.qmd` con Quarto (lee los datos desde `../datos/`).

## Estructura

```
cos_suelos_urbanos_santiago/
├── datos/      # tablas en formato ordenado (tidy), una por tipo de dato
├── scripts/
│   ├── 01_simular_datos.R       # genera los datos simulados
│   ├── 02_eda.R                 # análisis exploratorio y datos ausentes
│   ├── 03_informe_borrador.qmd  # borrador del proyecto final (storytelling)
│   └── 03_informe_borrador.html # informe renderizado
├── figuras/    # salidas exploratorias del EDA, numeradas 01_, 02_, ...
├── doctorado_cos_suelos_urbanos_santiago.Rproj   # proyecto de RStudio
├── .gitignore
└── README.md
```

## Diccionario de datos

Todas las tablas se unen por `sitio_id`. Fechas en ISO 8601 (AAAA-MM-DD). Datos ausentes = `NA`.

| Archivo | Una fila = | Variables |
|---|---|---|
| `sitios.csv` | sitio (n = 120) | `fecha_muestreo`, `latitud`, `longitud`, `tipo_cobertura` (parque_cesped, borde_carretera, bosque_urbano), `manejo` (bueno, deficiente), `quintil_icu` (Q1–Q5), `lst_verano_c` (°C), `ndvi`, `ndmi` |
| `suelo_terreno.csv` | sitio | `cone_index_mpa` (penetrómetro), `humedad_vol_m3_m3`, `temp_suelo_c`, `ce_ds_m` (TEROS-12) |
| `suelo_fisica.csv` | sitio × profundidad | `profundidad_cm` (0-10, 10-20), `arena_pct`, `limo_pct`, `arcilla_pct`, `fragmentos_rocosos_pct`, `da_g_cm3`, `estabilidad_agregados_pct` |
| `suelo_carbono.csv` | sitio × profundidad | `cos_pct`, `cop_pct`, `coam_pct` |
| `suelo_respiracion.csv` | sitio × temperatura × humedad × réplica (0-10 cm) | `temp_incubacion_c` (20, 30, 40), `humedad_cra_pct` (30, 70), `replica` (1–3), `rm_ug_co2c_g_h` |

## Datos ausentes incluidos a propósito

| Variable | Mecanismo | Causa simulada |
|---|---|---|
| `cos_pct`, `cop_pct`, `coam_pct` | MCAR | ~3 % de muestras extraviadas (etiqueta o bolsa perdida) |
| `rm_ug_co2c_g_h` | MCAR | ~2 % de pocillos contaminados o con burbujas |
| `da_g_cm3` | MAR | con > 20 % de fragmentos rocosos el cilindro no entra |
| `cone_index_mpa` | MNAR | el penetrómetro no mide sobre 5 MPa |
| `rm_ug_co2c_g_h` | MNAR | la placa MicroResp se satura con respiración muy alta |
