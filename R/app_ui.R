#' Application UI
#'
#' @noRd
app_ui <- function() {
  page_navbar(
    title = "Painel de Segregação Socioespacial",
    footer = tags$div(
      style = "background-color: #5BB02F; display:flex; align-items:center; gap:10px;",
      tags$img(src = "www/logo_DPU.png", height = "100px"),
      tags$img(src = "https://shiny-server.dpu.def.br/catadores.html/DPU_PNUD.png", height = "100px")
    ),
    window_title = "Painel Segregação Socioespacial",
    theme = bs_theme(version = 5, bg = "#FFFFFF", fg = "#286b06ff"),
    nav_panel("Apresentação", card(h4("Sobre o Dashboard"), card_body(p("Texto...")))),
    nav_panel("Índices de Segregação", mod_tabela_ui("tabela")),
    nav_panel("Mapa", mod_mapa_ui("mapa"))
  )
}
