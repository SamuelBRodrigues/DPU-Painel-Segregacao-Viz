#--------------------------------------------
# utils_filtros.R
#--------------------------------------------

#' @import dplyr
#' @import tibble
#' @import tidyr
#' @import stats
#' @import sf
#' @import leaflet
#' @import DT
#' @importFrom magrittr %>%
NULL

#' Filter table data
#'
#' @param dados dataset for table
#' @param input shiny input list
#' @return filtered tibble
#' @noRd
filter_dados <- function(dados, input) {
  df <- dados %>%
    dplyr::filter(
      NV_GEO %in% input$nivel_geo,
      D_indice_tipo == input$indicie_tipo
    )

  if (length(input$regiao) > 0) df <- df %>% dplyr::filter(NM_REGIAO %in% input$regiao)
  if (length(input$uf) > 0) df <- df %>% dplyr::filter(NM_UF %in% input$uf)
  if (length(input$rm) > 0) df <- df %>% dplyr::filter(NM_RM %in% input$rm)
  if (length(input$categorias) > 0) df <- df %>% dplyr::filter(D_indice_CAT %in% input$categorias)

  df
}

#' Filter map data (sf safe)
#'
#' @param dados_mapa dataset with sf geometry
#' @param input shiny input list
#' @return filtered sf object
#' @noRd
filter_dados_mapa <- function(dados_mapa, input) {
  df <- dados_mapa %>%
    dplyr::filter(
      NV_GEO == input$agg_geo,
      D_indice_tipo == input$indicie_tipo
    )

  if (!is.null(input$categorias) && length(input$categorias) > 0) {
    df <- df %>% dplyr::filter(D_indice_CAT %in% input$categorias)
  }

  df
}

#' Plot leaflet map
#'
#' @param df sf object filtered for map
#' @return leaflet map
#' @noRd
plot_mapa <- function(df) {
  if (nrow(df) == 0) return(leaflet::leaflet() %>% leaflet::addTiles())

  pal <- leaflet::colorNumeric("YlOrRd", domain = df$D_indice_value)

  leaflet::leaflet(df) %>%
    leaflet::addTiles() %>%
    leaflet::addPolygons(
      fillColor = ~pal(D_indice_value),
      fillOpacity = 0.8,
      color = "white",
      weight = 1,
      popup = ~paste0(
        "<b>Municipality: </b>", NM_MUN_1, "<br>",
        "Region: ", NM_REGIAO, "<br>",
        "State: ", NM_UF, "<br>",
        "Metro Area: ", NM_RM, "<br>",
        "Index: ", D_indice_tipo, "<br>",
        "Value: ", round(D_indice_value, 4)
      ),
      highlightOptions = leaflet::highlightOptions(
        weight = 3,
        color = "#666",
        fillOpacity = 0.9,
        bringToFront = TRUE
      )
    ) %>%
    leaflet::addLegend(
      position = "bottomright",
      pal = pal,
      values = ~D_indice_value,
      title = "Duncan Index"
    )
}

#' Summarize regions for table below the map
#'
#' @param dados dataset for table
#' @param indice_tipo selected index type
#' @return tibble with averages per region and Brazil
#' @noRd
sumariza_regioes <- function(dados, indice_tipo) {
  capitais <- c(
    "1200401", "2704302", "1600303", "1302603", "2927408", "2304400",
    "5300108", "3205309", "5208707", "2111300", "5103403", "3106200",
    "5002704", "1501402", "2507507", "3304557", "3550308", "2611606",
    "2211001", "4106902", "2408102", "4314902", "1100205", "1400100",
    "4205407", "2800308", "1721000"
  )

  df_filtrado <- dados %>% tibble::tibble() %>% dplyr::filter(D_indice_tipo == indice_tipo)

  # Brazil summary
  brasil_geral <- df_filtrado %>%
    dplyr::group_by(NV_GEO = "MN") %>%
    dplyr::summarise(
      media_geral = mean(D_indice_value, na.rm = TRUE),
      mediana_geral = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_geral = stats::sd(D_indice_value, na.rm = TRUE)
    ) %>% dplyr::ungroup()

  brasil_regioes_metropolitanas <- df_filtrado %>%
    dplyr::filter(!is.na(NM_RM)) %>%
    dplyr::group_by(NV_GEO = "MN") %>%
    dplyr::summarise(
      media_regiao_metropolitana = mean(D_indice_value, na.rm = TRUE),
      mediana_regiao_metropolitana = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_regiao_metropolitana = stats::sd(D_indice_value, na.rm = TRUE)
    )

  brasil_capitais <- df_filtrado %>%
    dplyr::filter(CD_MUN %in% capitais) %>%
    dplyr::group_by(NV_GEO = "MN") %>%
    dplyr::summarise(
      media_capital = mean(D_indice_value, na.rm = TRUE),
      mediana_capital = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_capital = stats::sd(D_indice_value, na.rm = TRUE)
    ) %>% dplyr::ungroup()

  brasil <- dplyr::left_join(brasil_geral, brasil_regioes_metropolitanas, by = "NV_GEO") %>%
    dplyr::left_join(brasil_capitais, by = "NV_GEO") %>%
    dplyr::mutate(NM_REGIAO = "Brasil") %>%
    dplyr::select(-NV_GEO)

  # Region summary
  regioes_geral <- df_filtrado %>%
    dplyr::group_by(NV_GEO = "MN", NM_REGIAO) %>%
    dplyr::summarise(
      media_geral = mean(D_indice_value, na.rm = TRUE),
      mediana_geral = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_geral = stats::sd(D_indice_value, na.rm = TRUE)
    ) %>% dplyr::ungroup() %>% tidyr::drop_na()

  regioes_regioes_metropolitanas <- df_filtrado %>%
    dplyr::filter(!is.na(NM_RM)) %>%
    dplyr::group_by(NV_GEO = "MN", NM_REGIAO) %>%
    dplyr::summarise(
      media_regiao_metropolitana = mean(D_indice_value, na.rm = TRUE),
      mediana_regiao_metropolitana = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_regiao_metropolitana = stats::sd(D_indice_value, na.rm = TRUE)
    ) %>% dplyr::ungroup() %>% tidyr::drop_na()

  regioes_capitais <- df_filtrado %>%
    dplyr::filter(CD_MUN %in% capitais) %>%
    dplyr::group_by(NV_GEO = "MN", NM_REGIAO) %>%
    dplyr::summarise(
      media_capital = mean(D_indice_value, na.rm = TRUE),
      mediana_capital = stats::median(D_indice_value, na.rm = TRUE),
      desvio_padrao_capital = stats::sd(D_indice_value, na.rm = TRUE)
    ) %>% dplyr::ungroup() %>% tidyr::drop_na()

  regioes <- dplyr::left_join(regioes_geral, regioes_regioes_metropolitanas, by = c("NV_GEO", "NM_REGIAO")) %>%
    dplyr::left_join(regioes_capitais, by = c("NV_GEO", "NM_REGIAO")) %>%
    dplyr::select(-NV_GEO)

  dplyr::bind_rows(brasil, regioes) %>%
    dplyr::mutate(dplyr::across(dplyr::where(is.double), ~ round(.x, 3))) %>%
    dplyr::relocate(NM_REGIAO)
}
