#' UI da tabela principal
#'
#' @param id módulo ID
#' @noRd
#' @import shiny
#' @import DT
mod_tabela_ui <- function(id) {
  
  # Definindo link de download dos dados brutos
  url_csv_drive <- "https://drive.google.com/uc?export=download&id=1J8eM6CJXBeEh22Jsq8E1wCuSVaNnxxq7"
  url_xlsx_drive <- "https://drive.google.com/uc?export=download&id=1M82O6mHGb7Naywlyc6ZCazAJ_9Of7dMV"

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
        choices = c("Município" = "MN", "Reg. Metropolitana" = "RM", "UF", "Região" = "RG", "Brasil"),
        selected = "MN"
      )
    ),
    # parte principal
    div(
    style = "display: flex; justify-content: flex-end; gap: 10px;",
    
    # Botão CSV via tags$a (agora ele encontra a variável url_csv_drive)
    tags$a(
      "Baixar CSV",
      href = url_csv_drive,
      class = "btn btn-default btn-sm shiny-download-link",
      target = "_blank"
    ),
    
    # Botão XLSX via tags$a (agora ele encontra a variável url_xlsx_drive)
    tags$a(
      "Baixar XLSX",
      href = url_xlsx_drive,
      class = "btn btn-default btn-sm shiny-download-link",
      target = "_blank"
    )
  ),
    shinycssloaders::withSpinner(DTOutput(ns("tabela")), type = 1)
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
          fixedHeader = TRUE,
          language = list(
            search = "Pesquisar:",
            lengthMenu = "Mostrar _MENU_ linhas",
            info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
            paginate = list(previous = "Anterior", `next` = "Próximo"),
            zeroRecords = "Nenhum registro encontrado"
          )
        )
      )
    })

  })
}
