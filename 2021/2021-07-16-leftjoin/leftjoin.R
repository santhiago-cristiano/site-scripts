
# pacotes -----------------------------------------------------------------

library(readr)
library(dplyr)
library(abjData)
library(purrr)
library(glue)


# carregando os dados -----------------------------------------------------

# lista todos os arquivos csv contidos na pasta

arquivos_csv <- list.files(
  path = "./2021/2021-07-16-leftjoin/dados/",
  pattern = "*.csv",
  full.names = TRUE
)

# lendo todos os arquivos e armazenando em uma lista

morte_infantil <- map(
  arquivos_csv,
  read_csv2,
  locale(encoding = "latin1"),
  col_names = TRUE,
  col_types = "ccdi"
)

# atribuindo o ano como "nome" para cada um dos elementos da lista

names(morte_infantil) <- 2010:2012

# carregando os dados auxiliares

auxiliar <- abjData::muni %>%
  select(muni_id, muni_id_6, uf_sigla, regiao_nm) %>%
  arrange(muni_id_6)


# left join ---------------------------------------------------------------

mesclar_dados <- function(x) {
  x %>%
    left_join(auxiliar, by = c("codigo" = "muni_id_6")) %>%
    select(-codigo) %>%
    rename(cod_ibge = muni_id, uf = uf_sigla, regiao = regiao_nm) %>%
    relocate(c(cod_ibge, regiao, uf), .before = municipio)
}

morte_infantil_mesclado <- map(morte_infantil, mesclar_dados)


# exportando os dados -----------------------------------------------------

# com o pipe

morte_infantil_mesclado %>%
  names(.) %>%
  walk( ~ write.csv2(
    morte_infantil_mesclado[[.]],
    file = glue("./2021/2021-07-16-leftjoin/dados-mesclados/{.}-mesclado.csv"),
    row.names = FALSE
  ))

# sem o pipe

walk(
  names(morte_infantil_mesclado),
  ~ write.csv2(
    morte_infantil_mesclado[[.]],
    file = glue("./2021/2021-07-16-leftjoin/dados-mesclados/{.}-mesclado.csv"),
    row.names = FALSE
  )
)

# todos os anos empilhados

map_dfr(morte_infantil, mesclar_dados) %>%
  write.csv2(file = "./2021/2021-07-16-leftjoin/dados-mesclados/mortes_infantis_mesclado.csv",
             row.names = FALSE)
