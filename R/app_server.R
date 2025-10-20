#' Application server
#'
#' @noRd
#' @import shiny
#' @import dplyr
#' @import sf
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  dados <- dados_tabela |> 
    dplyr::select(
      NV_GEO, CD_REGIAO, NM_REGIAO, CD_UF, NM_UF, NM_RM, CD_MUN, NM_MUN_1, D_indice_tipo, D_indice_value, D_indice_CAT
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
