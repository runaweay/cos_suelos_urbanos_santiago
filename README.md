# Influence of urban heat islands on urban soil carbon in Santiago

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24607816.svg)](https://doi.org/10.5281/zenodo.24607816)

**Author:** Mariana dos Santos Moreno (@runaweay) · **Course teacher:** Prof. Sara Acevedo (@saryace) · **License:** MIT (code), CC BY 4.0 (data and figures)

Final project for the course *Visualización de datos medioambientales con R* (AGP3141-1, PUC Chile), taught by Prof. Sara Acevedo. It is based on my PhD proposal, "Influence of thermal microclimate and physical properties on carbon dynamics in urban soils of Santiago, Chile", and explores whether green areas in the warmest parts of the city store less organic carbon in their soils.

**The data are simulated** and include the patterns expected from the thesis hypothesis, because field sampling has not been carried out yet (it will take place in spring-summer 2026-2027). They were generated with `scripts/01_simular_datos.R`, for practice in the course only.

> To see the results, go to the report (<https://runaweay.github.io/cos_suelos_urbanos_santiago/>).
> This report (in Spanish) contains the context, the methods, the figures, the conclusions and the references.

## 📂 Contents

- [Exploratory questions](#exploratory-questions)
- [How the data were generated](#how-the-data-were-generated)
- [Repository structure](#repository-structure)
- [Data dictionary](#data-dictionary)
- [Data validation](#data-validation)
- [Reproducibility](#reproducibility)
- [Use of artificial intelligence](#use-of-artificial-intelligence)
- [Credits](#credits)
- [How to cite](#how-to-cite)
- [License](#license)

## ❓ Exploratory questions

1. Is soil organic carbon (SOC) lower in green areas located in the warmest parts of the city?
2. Do management quality and vegetation cover modify that relationship?
3. Does soil texture change the response of SOC to heat?
4. Does microbial respiration increase with temperature, and does it depend on moisture?

## 🧪 How the data were generated

The data were generated with the help of Claude (Anthropic) in September 2026, from the following request (translated from Portuguese): "can you help me create the data I need, based on my PhD project? Since we have not gone to the field yet, I don't have any data."

The following elements of the thesis project were used:

- **Sampling design**: 120 green areas in Santiago, stratified by vegetation cover (lawn park, roadside and urban forest), management quality (good and poor) and quintile of summer land surface temperature (Q1 to Q5).
- **Planned variables and methods**: NDVI and NDMI; compaction with a penetrometer; soil moisture, temperature and electrical conductivity with a TEROS-12 sensor; texture, bulk density, rock fragments and aggregate stability; SOC and its fractions (particulate, POC, and mineral-associated, MAOC) at 0-10 and 10-20 cm; and microbial respiration with MicroResp at 20, 30 and 40 °C and at 30 and 70% of water holding capacity (WHC).
- **Hypothesis**: soils with a stronger heat island, coarser texture, lower NDVI/NDMI and poor management would have less organic carbon and higher microbial respiration.

From this, Claude wrote `scripts/01_simular_datos.R`, which generates the data with effects defined by the hypothesis (see [simulation parameters](#simulation-parameters)) and deliberately introduces missing data (MCAR, MAR and MNAR) for the course activity on missing data. Effect sizes and variability were chosen to be plausible and do not come from measurements. The effects were later adjusted so that differences between treatments were clearer.

## 📁 Repository structure

```
cos_suelos_urbanos_santiago/
├── index.qmd           #final report (home page of the website)
├── _quarto.yml         #website configuration
├── datos/
│   ├── crudos/         #raw tables, as produced by the simulation (never edited by hand)
│   └── procesados/     #joined tables with derived variables, ready for analysis
├── scripts/
│   ├── 01_simular_datos.R            #generates the raw data
│   ├── 02_eda.R                      #exploration, missing data and processed table
│   ├── 03_group_by_nest.qmd          #activity 9: one model per site (Q10)
│   ├── 04_validacion_diccionario.qmd #activity 10: data dictionary and validation
│   ├── funciones.R                   #validar_suelos() function
│   └── referencias.bib               #report bibliography
├── figuras/            #exploratory figures from 02_eda.R
├── imagenes/           #photos used in the report
├── docs/               #rendered website (GitHub Pages)
├── renv/, renv.lock    #package versions
└── LICENSE             #MIT (code); data and figures under CC BY 4.0
```

## 📖 Data dictionary

All tables are joined by `sitio_id`. Dates follow ISO 8601 (YYYY-MM-DD). Missing values = `NA`.

### ✏️ Tables

| File | One row = | Variables |
|------------------------|------------------------|------------------------|
| `crudos/sitios.csv` | site (n = 120) | `fecha_muestreo`, `latitud`, `longitud`, `tipo_cobertura` (parque_cesped, borde_carretera, bosque_urbano), `manejo` (bueno, deficiente), `quintil_icu` (Q1–Q5), `lst_verano_c` (°C), `ndvi`, `ndmi` |
| `crudos/suelo_terreno.csv` | site | `cone_index_mpa` (penetrometer), `humedad_vol_m3_m3`, `temp_suelo_c`, `ce_ds_m` (TEROS-12) |
| `crudos/suelo_fisica.csv` | site × depth | `profundidad_cm` (0-10, 10-20), `arena_pct`, `limo_pct`, `arcilla_pct`, `fragmentos_rocosos_pct`, `da_g_cm3`, `estabilidad_agregados_pct` |
| `crudos/suelo_carbono.csv` | site × depth | `cos_pct`, `cop_pct`, `coam_pct` |
| `crudos/suelo_respiracion.csv` | site × temperature × moisture × replicate (0-10 cm) | `temp_incubacion_c` (20, 30, 40), `humedad_cra_pct` (30, 70), `replica` (1–3), `rm_ug_co2c_g_h` |
| `procesados/suelo_analisis.csv` | site × depth | all variables from the raw tables (except respiration) + `textura_grupo`, `stock_cos_kg_m2`, `frac_coam` |

### 🔢 Expected values per variable

Physically plausible ranges for mineral soils of green areas in Santiago. They are used to validate both the simulated data and the future field and laboratory data.

| Variable | Type | Unit | Expected values | NA |
|---------------|---------------|---------------|---------------|---------------|
| `sitio_id` | identifier | \- | S001–S120, unique per site | no |
| `fecha_muestreo` | date | YYYY-MM-DD | spring-summer 2026-2027 | no |
| `latitud`, `longitud` | numeric | decimal degrees | within urban Santiago (≈ -33.7 to -33.3; -70.9 to -70.4) | no |
| `tipo_cobertura` | categorical | \- | parque_cesped, borde_carretera, bosque_urbano | no |
| `manejo` | categorical | \- | bueno, deficiente | no |
| `quintil_icu` | ordinal categorical | \- | Q1-Q5 | no |
| `lst_verano_c` | numeric | °C | 20 - 45 | no |
| `ndvi`, `ndmi` | numeric | \- | -1 - 1 | no |
| `cone_index_mpa` | numeric | MPa | 0 - 5 (penetrometer limit) | yes (MNAR) |
| `humedad_vol_m3_m3` | numeric | m³/m³ | 0 - 0.6 | no |
| `temp_suelo_c` | numeric | °C | -5 - 60 | no |
| `ce_ds_m` | numeric | dS/m | ≥ 0 | no |
| `profundidad_cm` | categorical | cm | 0-10, 10-20 | no |
| `arena_pct`, `limo_pct`, `arcilla_pct` | numeric | \% | 0 - 100; the three add up to 100 | no |
| `fragmentos_rocosos_pct` | numeric | \% | 0 - 100 | no |
| `da_g_cm3` | numeric | g/cm³ | 0.8 - 2.0 | yes (MAR) |
| `estabilidad_agregados_pct` | numeric | \% | 0 - 100 | no |
| `cos_pct` | numeric | \% | 0 - 15 | yes (MCAR) |
| `cop_pct`, `coam_pct` | numeric | \% | ≥ 0 and `cop_pct` + `coam_pct` ≈ `cos_pct` | yes (MCAR) |
| `temp_incubacion_c` | numeric | °C | 20, 30, 40 | no |
| `humedad_cra_pct` | numeric | \% WHC | 30, 70 | no |
| `replica` | integer | \- | 1 - 3 | no |
| `rm_ug_co2c_g_h` | numeric | µg CO₂-C/g/h | ≥ 0 | yes (MCAR and MNAR) |

### 🖇️ Derived variables (calculated in the scripts)

| Variable | Where | Rule |
|------------------------|------------------------|------------------------|
| `textura_grupo` | `02_eda.R` | gruesa (coarse) if `arena_pct` ≥ 55; otherwise fina (fine) if `arcilla_pct` ≥ 30; otherwise media (medium) |
| `stock_cos_kg_m2` | `02_eda.R` | `cos_pct` × `da_g_cm3` × 10 cm × (1 − `fragmentos_rocosos_pct`/100) / 10 |
| `frac_coam` | `02_eda.R` | `coam_pct` / (`cop_pct` + `coam_pct`) |
| `q10` | `03_group_by_nest.qmd` | exp(10 × slope) of the model log(respiration) ~ temperature, per site |

### ℹ️ Simulation parameters

Values defined in `scripts/01_simular_datos.R` (SD = standard deviation).

| Variable | How it was simulated |
|------------------------|------------------------|
| Design | 120 sites = 3 covers × 2 management levels × 5 quintiles × 4 replicates; `set.seed(2026)` |
| `fecha_muestreo` | random between 2026-11-02 and 2027-02-27 (spring, summer) |
| `latitud`, `longitud` | random between -33.60 and -33.35 and between -70.78 and -70.50 (no spatial pattern) |
| `lst_verano_c` | 28.9 °C in Q1 + 1.1 °C per quintile (Q5 ≈ 33.3 °C), SD 0.4 |
| `ndvi` | forest 0.62, lawn 0.52, roadside 0.32; +0.08 good management, -0.04 poor; -0.025 per quintile; limits 0.05-0.90 |
| `ndmi` | 0.7 × NDVI - 0.25, SD 0.04; limits -0.4 to 0.5 |
| `cone_index_mpa` | roadside 3.4, lawn 2.0, forest 1.4 MPa; +0.5 with poor management; +0.1 per quintile; SD 1.0 |
| `humedad_vol_m3_m3` | 0.24; +0.04 good management, -0.03 poor; -0.015 per quintile; limits 0.05-0.45 |
| `temp_suelo_c` | 24 °C + 1.6 °C per quintile, lower with higher NDVI; SD 1.2 |
| `ce_ds_m` | median 0.5 dS/m (log-normal); +0.3 on roadsides |
| `arcilla_pct`, `arena_pct` | clay mean 22% (SD 8, 5-45%); sand mean 45% (SD 12); silt = 100 - sand - clay |
| `fragmentos_rocosos_pct` | median 12% on roadsides and 5% in the other covers; +2% at 10-20 cm; maximum 45% |
| `da_g_cm3` | 1.25 g/cm³ + 0.12 per MPa of compaction; +0.08 at 10-20 cm; limits 0.9-1.8 |
| `cos_pct` | 2.3% baseline (0-10 cm, lawn, Q3); 10-20 cm ×0.65; good management +22%, poor -10%; forest +16%, roadside -22%; about -8% per quintile; +1.2% per clay point and -0.6% per sand point |
| `coam_pct`, `cop_pct` | MAOC ≈ 55% of SOC (more with clay, less with heat, +6 points at 10-20 cm); POC = SOC - MAOC |
| `estabilidad_agregados_pct` | 35% + 9 per SOC point, more with clay, less with compaction; limits 10-95% |
| `rm_ug_co2c_g_h` | basal = 0.35 × SOC^0.9, increasing with quintile; Q10 = 2 (×1, ×2 and ×4 at 20, 30 and 40 °C); at 30% WHC ×0.55 (×0.40 at 40 °C) |

### 💭 Missing data introduced on purpose

| Variable | Mechanism | Simulated cause |
|------------------------|------------------------|------------------------|
| `cos_pct`, `cop_pct`, `coam_pct` | MCAR | \~3% of samples lost (label or bag misplaced) |
| `rm_ug_co2c_g_h` | MCAR | \~2% of wells contaminated or with bubbles |
| `da_g_cm3` | MAR | with \> 20% rock fragments the core sampler cannot be inserted |
| `cone_index_mpa` | MNAR | the penetrometer does not measure above 5 MPa |
| `rm_ug_co2c_g_h` | MNAR | the MicroResp plate saturates with very high respiration |

## ✅ Data validation

Before each analysis, `validar_suelos()` (`scripts/funciones.R`) checks the data against this dictionary with an unique `sitio_id` per depth, valid `tipo_cobertura` categories and the expected ranges of `cos_pct` (0-15%) and `cone_index_mpa` (0-5 MPa). It runs at the start of the report and is tested with deliberately introduced errors in [activity 10](https://runaweay.github.io/cos_suelos_urbanos_santiago/scripts/04_validacion_diccionario.html).

## 🔁 Reproducibility

Developed and tested with R 4.6.2 and Quarto. Package versions are recorded in `renv.lock`; the main ones are tidyverse, naniar, plotly, broom and knitr.

1. Clone the repository and open `doctorado_cos_suelos_urbanos_santiago.Rproj` in RStudio:
   ```bash
   git clone https://github.com/runaweay/cos_suelos_urbanos_santiago.git
   ```
2. Install the packages with the same versions: `renv::restore()`.
3. Run `scripts/01_simular_datos.R`: creates the five raw tables in `datos/crudos/` (fixed seed `set.seed(2026)`, so the data are always the same).
4. Run `scripts/02_eda.R`: joins the tables, creates the processed table in `datos/procesados/` and saves the exploratory figures in `figuras/`.
5. In the Terminal, run `quarto render`: validates the data and builds the report and the activities in `docs/`, published with GitHub Pages.

## 👾 Use of artificial intelligence

I used Claude (Anthropic) to write the data simulation script, based on the design, variables and hypothesis of my thesis, and as support to review the code, organize the repository and draft texts. I reviewed and adjusted all the content, and the analysis decisions are my own.

## 🙌 Credits

- Prof. Sara Acevedo, for the course, its materials and examples.
- Elena Lazo, whose repository [pm25_rm](https://github.com/elenalazo20/pm25_rm) served as a model for the structure.
- Okabe-Ito colour palette, colourblind-friendly.
- R packages: tidyverse, naniar, plotly, broom and renv; report built with Quarto.

## 📝 How to cite

This repository is archived in Zenodo: [10.5281/zenodo.24607816](https://doi.org/10.5281/zenodo.24607816).

Moreno, M. S. (2026). *Influence of urban heat islands on urban soil carbon in Santiago* (Version v1.0.0) [Software and simulated data]. Zenodo. https://doi.org/10.5281/zenodo.24607816

## ⚖️ License

The code is released under the [MIT License](LICENSE). The simulated data in `datos/` and the figures are released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/): they can be reused with credit to Mariana dos Santos Moreno (@runaweay).
