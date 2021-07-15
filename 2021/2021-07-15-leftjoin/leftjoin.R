
# pacotes -----------------------------------------------------------------

# install.packages("readr")
# install.packages("dplyr")
# install.packages("abjData")
# install.packages("purrr")
# install.packages("glue")

library(readr)
library(dplyr)
library(abjData)
library(purrr)
library(glue)


# carregando os dados -----------------------------------------------------

# lista todos os arquivos csv na pasta

arquivos_csv <- list.files(
  path = "./2021/2021-07-15-leftjoin/dados/",
  pattern = "*.csv",
  full.names = TRUE
)

# lendo todos os arquivos e armazenando numa lista

morte_infantil <- map(
  arquivos_csv,
  read_csv2,
  locale(encoding = "latin1"),
  col_names = TRUE,
  col_types = "ccdi"
)

# atribuindo o ano como nome para cada um dos elementos da lista

names(morte_infantil) <- 2010:2012

# carregando os dados auxiliares

auxiliar <- abjData::muni %>%
  select(muni_id, muni_id_6, uf_sigla, regiao_nm) %>%
  arrange(muni_id_6)


# left join ---------------------------------------------------------------

acrescenta_cod_uf_reg <- function(df) {
  df %>%
    left_join(auxiliar, by = c("codigo" = "muni_id_6")) %>%
    select(-codigo) %>%
    rename(cod_ibge = muni_id, uf = uf_sigla, regiao = regiao_nm) %>%
    relocate(c(cod_ibge, regiao, uf), .before = municipio)
}

morte_infantil_final <- map(morte_infantil, acrescenta_cod_uf_reg)


# exportando os dados -----------------------------------------------------

morte_infantil_final %>%
  names(.) %>%
  walk( ~ write.csv2(
    morte_infantil_final[[.]],
    glue("./2021/2021-07-15-leftjoin/dados-modificados/{.}-modificado.csv"),
    row.names = FALSE
  ))

# ou

walk(
  names(morte_infantil_final),
  ~ write.csv2(
    morte_infantil_final[[.]],
    glue("./2021/2021-07-15-leftjoin/dados-modificados/{.}-modificado.csv"),
    row.names = FALSE
  )
)

