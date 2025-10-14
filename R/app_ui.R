app_ui <- function() {

  # CSS
  css_header <- system.file("app/www/header.css", package = "dpupsviz")
  css_footer <- system.file("app/www/footer.css", package = "dpupsviz")
  css_apresentacao <- system.file("app/www/apresentacao.css", package = "dpupsviz")

  #Page Navbar
  bslib::page_navbar(

    title = shiny::tags$div(
      shiny::tags$img(src = "www/logo_DPU_200h.png"),
      "Painel de Segregação Étnico-Racial"
    ),
    window_title = "Painel Segregação Étnico-Racial",

    # Tema
    theme = bslib::bs_theme(
      version = 5,
      bg = "#FFFFFF",
      fg = "#000000ff",
      base_font = bslib::font_collection(
        bslib::font_google("Lato"),
        "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol'"
      )
    ),

    # Inclui os CSS via includeCSS()
    shiny::includeCSS(css_header),
    shiny::includeCSS(css_footer),
    shiny::includeCSS(css_apresentacao),

    # Footer
    footer = shiny::tags$div(
      class = "footer",
      shiny::tags$img(src = "www/DPU_PNUD_200h.png")
    ),

    # Painéis
    bslib::nav_panel(
      "Apresentação",
      bslib::card(
        bslib::card_body(
          shiny::includeHTML(system.file("app/www/apresentacao.html", package = "dpupsviz"))
        )
      )
    ),
    bslib::nav_panel("Índices de Segregação", mod_tabela_ui("tabela")),
    bslib::nav_panel("Mapa", mod_mapa_ui("mapa"))
  )
}
