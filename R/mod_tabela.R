#' UI da tabela principal
#'
#' @param id módulo ID
#' @noRd
#' @import shiny
#' @import DT
mod_tabela_ui <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      selectInput(ns("indicie_tipo"), "Índices:", choices = NULL),
      selectInput(ns("categorias"), "Categorias:", choices = NULL, multiple = TRUE),
      selectInput(ns("regiao"), "Região:", choices = NULL, multiple = TRUE),
      selectInput(ns("uf"), "UF:", choices = NULL, multiple = TRUE),
      selectInput(ns("rm"), "Região Metropolitana:", choices = NULL, multiple = TRUE),
      checkboxGroupInput(
        ns("nivel_geo"),
        "Selecione os níveis geográficos:",
        choices = c("MN", "RM", "UF", "RG", "Brasil"),
        selected = "MN"
      )
    ),
    DTOutput(ns("tabela"))
  )
}

#' Server da tabela principal
#'
#' @param id módulo ID
#' @param dados dataset utilizado no módulo
#' @noRd
mod_tabela_server <- function(id, dados) {
  moduleServer(id, function(input, output, session) {

    observe({
      updateSelectInput(session, "indicie_tipo", choices = unique(dados$D_indice_tipo))
      updateSelectInput(session, "categorias", choices = unique(dados$D_indice_CAT))
      updateSelectInput(session, "regiao", choices = unique(dados$NM_REGIAO))
      updateSelectInput(session, "uf", choices = unique(dados$NM_UF))
      updateSelectInput(session, "rm", choices = unique(dados$NM_RM))
    })

    dados_filtrados <- reactive({
      filter_dados(dados, input)
    })

    output$tabela <- renderDT({
      datatable(
        dados_filtrados(),
        options = list(
          pageLength = 50,
          scrollY = "70vh",
          scrollX = TRUE,
          scrollCollapse = TRUE,
          fixedHeader = TRUE
        )
      )
    })
  })
}
