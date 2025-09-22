#' UI do mapa
#'
#' @param id módulo ID
#' @noRd
#' @import shiny
#' @import leaflet
#' @import DT
mod_mapa_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      selectInput(ns("indicie_tipo"), "Índices:", choices = NULL),
      selectInput(ns("categorias"), "Categorias:", choices = NULL, multiple = TRUE)
    ),
    leafletOutput(ns("mapa"), height = "650px", width = "100%"),
    DTOutput(ns("tabela_regioes"))
  )
}

#' Server do mapa
#'
#' @param id módulo ID
#' @param dados dataset do mapa
#' @noRd
mod_mapa_server <- function(id, dados) {
  moduleServer(id, function(input, output, session) {

    observe({
      updateSelectInput(session, "indicie_tipo", choices = unique(dados$D_indice_tipo))
      updateSelectInput(session, "categorias", choices = unique(dados$D_indice_CAT))
    })

    dados_mapa_filtrados <- reactive({
      filter_dados_mapa(dados, input)
    })

    output$mapa <- renderLeaflet({
      plot_mapa(dados_mapa_filtrados())
    })

    output$tabela_regioes <- renderDT({
      datatable(sumariza_regioes(dados, input$indicie_tipo))
    })
  })
}
