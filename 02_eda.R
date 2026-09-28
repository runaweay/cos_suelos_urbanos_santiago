# 02_eda.R ---------------------------------------------------------------
# Análisis exploratorio (EDA) de los datos simulados de suelos urbanos

library(tidyverse)
library(naniar)

dir.create("figuras", showWarnings = FALSE)

# 1. Leer datos ------------------------------------------------------------
sitios  <- read_csv("datos/sitios.csv")
terreno <- read_csv("datos/suelo_terreno.csv")
fisica  <- read_csv("datos/suelo_fisica.csv")
carbono <- read_csv("datos/suelo_carbono.csv")
resp    <- read_csv("datos/suelo_respiracion.csv")

glimpse(sitios)
summary(carbono)

# 2. Unir tablas (una fila = sitio x profundidad) ----------------------------
suelo <- fisica |>
  left_join(carbono, by = c("sitio_id", "profundidad_cm")) |>
  left_join(sitios,  by = "sitio_id") |>
  left_join(terreno, by = "sitio_id") |>
  mutate(
    quintil_icu   = factor(quintil_icu, levels = paste0("Q", 1:5)),
    textura_grupo = case_when(arena_pct >= 55   ~ "gruesa",
                              arcilla_pct >= 30 ~ "fina",
                              TRUE              ~ "media"),
    textura_grupo = factor(textura_grupo, levels = c("gruesa", "media", "fina")),
    # stock (kg m-2) = C (%) x DA (g cm-3) x H (cm) x (1 - RF) / 10
    stock_cos_kg_m2 = cos_pct * da_g_cm3 * 10 *
      (1 - fragmentos_rocosos_pct / 100) / 10,
    frac_coam = coam_pct / (cop_pct + coam_pct)
  )

# 3. Resúmenes numéricos -----------------------------------------------------
suelo |>
  group_by(profundidad_cm, manejo) |>
  summarise(n = n(),
            cos_media = mean(cos_pct, na.rm = TRUE),
            cos_de    = sd(cos_pct, na.rm = TRUE),
            coam_media = mean(coam_pct, na.rm = TRUE),
            .groups = "drop")

suelo |>
  group_by(quintil_icu) |>
  summarise(lst_media = mean(lst_verano_c),
            cos_media = mean(cos_pct, na.rm = TRUE),
            stock_medio = mean(stock_cos_kg_m2, na.rm = TRUE))

# 4. Gráficos ----------------------------------------------------------------
# 4.1 COS por cobertura y manejo (similar a la Figura 1 de la propuesta)
g01 <- ggplot(suelo, aes(x = tipo_cobertura, y = cos_pct, fill = manejo)) +
  geom_boxplot(na.rm = TRUE) +
  facet_wrap(~ profundidad_cm, labeller = label_both) +
  labs(x = "Tipo de cobertura", y = "COS (%)", fill = "Manejo") +
  theme_bw()
ggsave("figuras/01_cos_cobertura_manejo.png", g01, width = 8, height = 4.5)

# 4.2 COS vs temperatura superficial (ICU) según textura
g02 <- suelo |>
  filter(profundidad_cm == "0-10") |>
  ggplot(aes(x = lst_verano_c, y = cos_pct, colour = textura_grupo)) +
  geom_point(alpha = 0.7, na.rm = TRUE) +
  geom_smooth(method = "lm", se = FALSE, na.rm = TRUE) +
  labs(x = "Temperatura superficial en verano (°C)", y = "COS 0-10 cm (%)",
       colour = "Textura") +
  theme_bw()
ggsave("figuras/02_cos_temperatura_textura.png", g02, width = 6, height = 4.5)

# 4.3 Respiración microbiana vs temperatura de incubación y humedad
g03 <- resp |>
  left_join(sitios, by = "sitio_id") |>
  group_by(sitio_id, quintil_icu, temp_incubacion_c, humedad_cra_pct) |>
  summarise(rm = mean(rm_ug_co2c_g_h, na.rm = TRUE), .groups = "drop") |>
  ggplot(aes(x = factor(temp_incubacion_c), y = rm,
             fill = factor(humedad_cra_pct))) +
  geom_boxplot(na.rm = TRUE) +
  facet_wrap(~ quintil_icu, nrow = 1) +
  labs(x = "Temperatura de incubación (°C)",
       y = expression("RM (µg CO"[2]*"-C g"^-1*" h"^-1*")"),
       fill = "Humedad (% CRA)") +
  theme_bw()
ggsave("figuras/03_rm_temperatura_humedad.png", g03, width = 10, height = 4)

# 5. Datos ausentes (naniar) -------------------------------------------------
miss_var_summary(suelo)
miss_var_summary(resp)

g04 <- vis_miss(suelo |> select(cone_index_mpa, da_g_cm3, fragmentos_rocosos_pct,
                                cos_pct, cop_pct, coam_pct, humedad_vol_m3_m3))
ggsave("figuras/04_na_mapa_suelo.png", g04, width = 7, height = 5)

# ¿La DA falta al azar? Se ve que falta solo con muchos fragmentos rocosos (MAR)
g05 <- ggplot(suelo, aes(x = fragmentos_rocosos_pct, y = da_g_cm3)) +
  geom_miss_point() +
  labs(x = "Fragmentos rocosos (%)", y = expression("DA (g cm"^-3*")")) +
  theme_bw()
ggsave("figuras/05_na_da_fragmentos.png", g05, width = 6, height = 4.5)

# ¿Dónde falta la RM? Se concentra a 40 °C y 70 % CRA (saturación -> MNAR)
resp |>
  group_by(temp_incubacion_c, humedad_cra_pct) |>
  summarise(n_na = sum(is.na(rm_ug_co2c_g_h)),
            pct_na = round(100 * mean(is.na(rm_ug_co2c_g_h)), 1),
            .groups = "drop")
