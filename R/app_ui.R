#' Application UI
#'
#' @noRd
#' @import shiny
#' @import bslib
app_ui <- function() {
  bslib::page_navbar(
    title = "Painel de Segregação Socioespacial",
    footer = shiny::tags$div(
      style = "background-color: #5BB02F; display:flex; align-items:center; gap:10px;",
      shiny::tags$img(src = "www/logo_DPU.png", height = "100px"),
      shiny::tags$img(src = "https://shiny-server.dpu.def.br/catadores.html/DPU_PNUD.png", height = "100px")
    ),
    window_title = "Painel Segregação Socioespacial",
    theme = bslib::bs_theme(version = 5, bg = "#FFFFFF", fg = "#286b06ff"),
    bslib::nav_panel("Apresentação",
                     bslib::card(
                       shiny::h4("Sobre o Dashboard"),
                       bslib::card_body(
                         shiny::p("Texto...")
                       )
                     )
    ),
    bslib::nav_panel("Índices de Segregação", mod_tabela_ui("tabela")),
    bslib::nav_panel("Mapa", mod_mapa_ui("mapa"))
  )
}
