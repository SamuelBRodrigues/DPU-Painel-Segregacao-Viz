#' Application server
#'
#' @noRd
#' @import shiny
#' @import dplyr
#' @import sf
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  dados_tabela <- dados_tabela
  dados_mapa <- dados_tabela %>%
    dplyr::filter(NV_GEO == "MN") %>%
    dplyr::left_join(
      mapa_municipios %>%
        dplyr::select(code_muni, geom) %>%
        dplyr::mutate(code_muni = as.character(code_muni)) %>%
        sf::st_transform(crs = "+proj=longlat +datum=WGS84"),
      by = dplyr::join_by(CD_MUN == code_muni)
    ) %>%
    dplyr::select(NV_GEO, NM_REGIAO, NM_UF, NM_RM, CD_MUN, NM_MUN_1,
                  D_indice_tipo, D_indice_value, D_indice_CAT, "geometry" = geom) %>%
    sf::st_as_sf()

  # módulos do app
  mod_tabela_server("tabela", dados = dados_tabela)
  mod_mapa_server("mapa", dados = dados_mapa)
}
