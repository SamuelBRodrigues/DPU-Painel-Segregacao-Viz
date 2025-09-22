#' Application UI
#'
#' @noRd
#' @import shiny
#' @import bslib
app_ui <- function() {
  bslib::page_navbar(
    title = "Painel de Segregação Étnico-Racial",
    footer = shiny::tags$div(
      style = "background-color: #5BB02F; display:flex; align-items:flex-start; gap:10px; width = 100vw; padding: 10px;",
      shiny::tags$img(src = "www/logo_DPU.png", height = "100px"),
      shiny::tags$img(src = "https://shiny-server.dpu.def.br/catadores.html/DPU_PNUD.png", height = "100px")
    ),
    window_title = "Painel Segregação Étnico-Racial",
    theme = bslib::bs_theme(version = 5, bg = "#FFFFFF", fg = "#000000ff"),
    bslib::nav_panel("Apresentação",
                     bslib::card(
                       shiny::h1("Sobre o Painel"),
                       bslib::card_body(
                         shiny::includeHTML(
                           system.file("app/www/apresentacao.html", package = "dpupsviz")
                         )
                       )
                     )
    ),
    bslib::nav_panel("Índices de Segregação", mod_tabela_ui("tabela")),
    bslib::nav_panel("Mapa", mod_mapa_ui("mapa"))
  )
}
