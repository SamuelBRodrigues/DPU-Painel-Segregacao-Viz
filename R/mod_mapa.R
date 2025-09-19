#' UI do mapa
#'
#' @param id módulo ID
#' @noRd
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

    # Atualizar selectInput dinamicamente com base nos dados
    observe({
      updateSelectInput(session, "indicie_tipo", choices = unique(dados$D_indice_tipo))
      updateSelectInput(session, "categorias", choices = unique(dados$D_indice_CAT))
    })

    # Reactive: filtra os dados para o mapa
    dados_mapa_filtrados <- reactive({
      filter_dados_mapa(dados, input)  # helper em utils_filtros.R
    })

    # Renderizar o mapa
    output$mapa <- renderLeaflet({
      plot_mapa(dados_mapa_filtrados())  # helper em utils_filtros.R
    })

    # Renderizar a tabela de médias por região
    output$tabela_regioes <- renderDT({
      datatable(sumariza_regioes(dados, input$indicie_tipo))  # helper em utils_filtros.R
    })
  })
}
