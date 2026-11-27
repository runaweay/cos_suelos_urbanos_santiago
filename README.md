# Influence of urban heat islands on urban soil carbon in Santiago

Final project for the course *Visualización de datos medioambientales con R* (AGP3141-1, PUC Chile), taught by Prof. Sara Acevedo. It explores whether green areas in the warmest parts of Santiago store less organic carbon in their soils, based on my PhD project.
**The data are simulated** and include the patterns expected from the thesis hypothesis, because field sampling has not been carried out yet.

> To see the results, go to the report (<https://runaweay.github.io/cos_suelos_urbanos_santiago/>).
> This report (in Spanish) contains the context, the methods (including the criteria and the prompt used to simulate the data), the figures, the conclusions and the references.

## Contents

- [Repository structure](#repository-structure)
- [Data](#data)
- [Reproducibility](#reproducibility)
- [Use of artificial intelligence](#use-of-artificial-intelligence)
- [Credits](#credits)

## Repository structure

```
cos_suelos_urbanos_santiago/
├── index.qmd           #final report (home page of the website)
├── _quarto.yml         #website configuration
├── datos/
│   ├── crudos/         #raw tables, as produced by the simulation
│   ├── procesados/     #joined tables, ready for analysis
│   └── README.md       #data dictionary (in Spanish)
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
└── renv/, renv.lock    #package versions
```

## Data

The data are composed of five raw tables (sites, field measurements, soil physics, carbon and respiration) and one processed table, all joined by `sitio_id`. Variables, units, expected ranges, simulation parameters and missing data are described in the [data dictionary](datos/README.md).

**Validation:** before each analysis, `validar_suelos()` (`scripts/funciones.R`) checks that the data follow the dictionary (design categories and ranges of soil organic carbon and compaction). It is tested with deliberately introduced errors in [activity 10](https://runaweay.github.io/cos_suelos_urbanos_santiago/scripts/04_validacion_diccionario.html).

## Reproducibility

1. Open `doctorado_cos_suelos_urbanos_santiago.Rproj` in RStudio.
2. Install the packages with the same versions: `renv::restore()`.
3. Run `scripts/01_simular_datos.R` and then `scripts/02_eda.R` (fixed seed, `set.seed(2026)`, so the data are always the same).
4. In the Terminal: `quarto render` (builds the website in `docs/`).

## Use of artificial intelligence

I used Claude (Anthropic) to write the data simulation script, based on the design, variables and hypothesis of my thesis, and as support to review the code, organize the repository and draft texts. I reviewed and adjusted all the content, and the analysis decisions are my own.

## Credits

- Prof. Sara Acevedo, for the course, its materials and examples.
- Elena Lazo, whose repository [pm25_rm](https://github.com/elenalazo20/pm25_rm) served as a model for the structure.
- Okabe-Ito colour palette, colourblind-friendly.
- R packages: tidyverse, naniar, plotly, broom and renv; report built with Quarto.
