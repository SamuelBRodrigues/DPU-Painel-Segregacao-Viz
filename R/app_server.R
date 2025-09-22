#' Application server
#'
#' @noRd
#' @import shiny
#' @import dplyr
#' @import sf
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  dados_tabela <- dados_tabela
      dados_mapa_municipio <- dados_tabela |> 
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
      
    dados_mapa_regiao_metropolitana <- dados_tabela |> 
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
      
    dados_mapa_uf <- dados_tabela |> 
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
      
    dados_mapa <- dplyr::bind_rows(
      dados_mapa_municipio,
      dados_mapa_regiao_metropolitana,
      dados_mapa_uf
    )
    

  # módulos do app
  mod_tabela_server("tabela", dados = dados_tabela)
  mod_mapa_server("mapa", dados = dados_mapa)
}
