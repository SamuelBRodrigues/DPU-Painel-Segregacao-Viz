#' Application server
#'
#' @noRd
#' @import shiny
#' @import dplyr
#' @import sf
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  faixas_trabalho_regex <- c(
  "Pessoas 15 A 29 Anos",
  "Pessoas 30 A 59 Anos"
)
# se quiser adicionar uma terceira:
# "Pessoas 10 Anos Ou Mais"

# CARREGAR DADOS E APLICAR FILTROS CORRETOS
dados <- dados_tabela |>
  dplyr::select(
    NV_GEO, CD_REGIAO, NM_REGIAO, CD_UF, NM_UF, NM_RM, CD_MUN, NM_MUN_1,
    D_indice_tipo, D_indice_value, D_indice_CAT
  ) |>
  
  # remover AMARELO
  dplyr::filter(
    !grepl("Amarela", D_indice_tipo, ignore.case = TRUE)
  ) |>
  
  # remover RENDA (se aparecer)
  dplyr::filter(
    !grepl("Renda", D_indice_tipo, ignore.case = TRUE)
  ) |>
  
  # remover IDADE que NÃO FAZ PARTE das 3 faixas desejadas
  dplyr::filter(
    # manter tudo que não é faixa etária ("Pessoas" + número)
    !grepl("^Pessoas", D_indice_tipo) |
      grepl(paste(faixas_trabalho_regex, collapse = "|"), D_indice_tipo)
  ) |>
  
  # remover 0–9
  dplyr::filter(
    !grepl("0 A 9", D_indice_tipo)
  ) |>
  
  # remover 0–14
  dplyr::filter(
    !grepl("0 A 14", D_indice_tipo)
  ) |>
  
  # remover 60+
  dplyr::filter(
    !grepl("60 Anos Ou Mais", D_indice_tipo, ignore.case = TRUE)
  )
  dados_mapa_municipio <- dados |> 
    dplyr::filter(
    NV_GEO == "MN"
    ) |> 
    dplyr::left_join(
      mapa_municipios |> 
        dplyr::select(code_muni, geom) %>% 
        dplyr::mutate(code_muni = as.character(code_muni)) |> 
        sf::st_transform(crs = "+proj=longlat +datum=WGS84"),
      by = dplyr::join_by(CD_MUN == code_muni)
    ) |> 
    dplyr::select(NV_GEO, NM_REGIAO, NM_UF, NM_RM, CD_MUN, NM_MUN_1, D_indice_tipo, D_indice_value, D_indice_CAT, "geometry" = geom) |> 
    sf::st_as_sf()
      
  dados_mapa_regiao_metropolitana <- dados |> 
    dplyr::filter(
    NV_GEO == "RM"
    ) |> 
    dplyr::left_join(
      mapa_regioes_metropolitanas |> 
        dplyr::select(name_metro, geom) %>% 
        dplyr::mutate(name_metro = as.character(name_metro)) |> 
        sf::st_transform(crs = "+proj=longlat +datum=WGS84"),
      by = dplyr::join_by(NM_RM == name_metro)
    ) |> 
    dplyr::select(NV_GEO, NM_REGIAO, NM_UF, NM_RM, CD_MUN, NM_MUN_1, D_indice_tipo, D_indice_value, D_indice_CAT, "geometry" = geom) |> 
    sf::st_as_sf()
      
  dados_mapa_uf <- dados |> 
    dplyr::filter(
    NV_GEO == "UF"
    ) |> 
    dplyr::left_join(
      mapa_uf |> 
        dplyr::select(code_state, geom) %>% 
        dplyr::mutate(code_state = as.character(code_state)) |> 
        sf::st_transform(crs = "+proj=longlat +datum=WGS84"),
      by = dplyr::join_by(CD_UF == code_state)
    ) |> 
    dplyr::select(NV_GEO, NM_REGIAO, NM_UF, NM_RM, CD_MUN, NM_MUN_1, D_indice_tipo, D_indice_value, D_indice_CAT, "geometry" = geom) |> 
    sf::st_as_sf()

  dados_mapa_regiao <- dados |> 
    dplyr::filter(
    NV_GEO == "RG"
    ) |> 
    dplyr::left_join(
      mapa_regioes |> 
        dplyr::select(code_region, geom) %>% 
        dplyr::mutate(code_region = as.character(code_region)) |> 
        sf::st_transform(crs = "+proj=longlat +datum=WGS84"),
      by = dplyr::join_by(CD_REGIAO == code_region)
    ) |> 
    dplyr::select(NV_GEO, NM_REGIAO, NM_UF, NM_RM, CD_MUN, NM_MUN_1, D_indice_tipo, D_indice_value, D_indice_CAT, "geometry" = geom) |> 
    sf::st_as_sf()
      
  dados_mapa <- dplyr::bind_rows(
    dados_mapa_municipio,
    dados_mapa_regiao_metropolitana,
    dados_mapa_uf,
    dados_mapa_regiao
  ) |> 
    dplyr::mutate(
      NV_GEO = dplyr::case_when(
        NV_GEO == "MN" ~ "Município",
        NV_GEO == "RM" ~ "Região Metropolitana",
        NV_GEO == "RG" ~ "Região",
        .default = NV_GEO
      )
    )
    
  # módulos do app
  mod_tabela_server("tabela", dados = dados)
  mod_mapa_server("mapa", dados = dados_mapa)
}
