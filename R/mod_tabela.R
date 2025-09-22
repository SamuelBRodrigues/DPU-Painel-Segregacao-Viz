#' UI da tabela principal
#'
#' @param id módulo ID
#' @noRd
#' @import shiny
#' @import DT
mod_tabela_ui <- function(id) {
  ns <- NS(id)

  # tagList para agrupar a seção da tabela e a seção dos gráficos
  tagList(
    # --- SEÇÃO 1: TABELA COM FILTROS LATERAIS ---
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        # Inputs que afetam APENAS a tabela
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
      
      # Conteúdo principal: Apenas a tabela e seus botões
      h3("Tabela de Dados"),
      div(
        style = "display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 10px;",
        downloadButton(ns("baixar_csv"), "Baixar CSV", class = "btn-sm"),
        downloadButton(ns("baixar_xlsx"), "Baixar XLSX", class = "btn-sm")
      ),
      DTOutput(ns("tabela"))
    ), # Fim do layout_sidebar

    # --- SEÇÃO 2: GRÁFICOS INDEPENDENTES ---
    hr(), # Linha para separar visualmente as seções
    h3("Gráficos de Análise"),
    
    # layout_columns para criar 3 colunas lado a lado
    # col_widths = 4 significa que cada gráfico ocupará 4 de 12 colunas do grid, resultando em 3 colunas iguais.
    layout_columns(
      col_widths = 4,
      
      # Gráfico 1
      card(
        card_header("Gráfico 1: Análise por Grupo"),
        plotOutput(ns("meuGrafico"))
      ),
      
      # Gráfico 2
      card(
        card_header("Gráfico 2: Análise por Região"),
        plotOutput(ns("meuGrafico"))
      ),
      
      # Gráfico 3
      card(
        card_header("Gráfico 3: Análise por UF"),
        plotOutput(ns("meuGrafico"))
      )
    )
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
          #scrollY = "70vh",
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

    output$meuGrafico <- renderPlot(
      {
        dados_tabela |> 
          dplyr::filter(
            NV_GEO == "Brasil",
            D_indice_tipo %in% c("D_indice_pessoas_15_a_29_anos_cor_ou_raca_e_preta", "D_indice_pessoas_30_a_59_anos_cor_ou_raca_e_preta", "D_indice_pessoas_60_anos_ou_mais_cor_ou_raca_e_preta")
          ) |> 
          dplyr::mutate(
            grupo = dplyr::case_when(
              stringr::str_detect(D_indice_tipo, "15_a_29") ~ "Grupo 1",
              stringr::str_detect(D_indice_tipo, "30_a_59") ~ "Grupo 2",
              stringr::str_detect(D_indice_tipo, "60_anos") ~ "Grupo 3"
            )
          ) |>
          dplyr::group_by(
            grupo, D_indice_tipo
          ) |> 
          dplyr::summarise(
            D_indice_value = mean(D_indice_value)
          ) |> 
          dplyr::ungroup() |> 
          ggplot2::ggplot(
            mapping = aes(y = D_indice_value, x = grupo, fill = D_indice_tipo)
          ) + geom_col()
              }
      )

    # download CSV
    output$baixar_csv <- downloadHandler(
      filename = function() {
        paste0("dados_filtrados_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(dados_filtrados(), file, row.names = FALSE)
      }
    )

    # download XLSX
    output$baixar_xlsx <- downloadHandler(
      filename = function() {
        paste0("dados_filtrados_", Sys.Date(), ".xlsx")
      },
      content = function(file) {
        openxlsx::write.xlsx(dados_filtrados(), file)
      }
    )

    
  })
}
