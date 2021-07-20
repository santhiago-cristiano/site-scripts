
# pacotes -----------------------------------------------------------------

library(readr)
library(dplyr)
library(purrr)


# importando os dados ---------------------------------------------------

arquivos_csv <- list.files(
  path = "2021/2021-07-20-innerjoin/dados",
  pattern = "*.csv",
  full.names = TRUE
)

mortes_infantis <- map(
  arquivos_csv,
  read_csv2,
  locale(encoding = "latin1"),
  col_names = TRUE,
  col_types = "ccccdi"
) %>%
  set_names(2010:2012)


# innerjoin ---------------------------------------------------------------

mortes_infantis_inner <- reduce(mortes_infantis,
                                inner_join, by = "cod_ibge",
                                suffix = c("_2010", "_2011"))

glimpse(mortes_infantis_inner)



mortes_infantis_inner <- mortes_infantis_inner %>%
  select(
    !(contains(c("regiao", "uf", "municipio", "ano")) &
      ends_with(c("2010", "2011"))),
    -ano
  ) %>%
  rename(total_2012 = total) %>%
  relocate(c(regiao, uf, municipio), .after = cod_ibge)

glimpse(mortes_infantis_inner)


# exportando os dados -----------------------------------------------------

write.csv2(
  mortes_infantis_inner,
  file = "./2021/2021-07-20-innerjoin/dados-inner/mortes_infantis_inner.csv",
  row.names = FALSE
)



