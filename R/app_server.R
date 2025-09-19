#' Application server
#'
#' @noRd
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  dados_tabela <- dpupsviz::dados_tabela
  dados_mapa <- dpupsviz::dados_mapa
  # módulos do app
  mod_tabela_server("tabela", dados = dados_tabela)
  mod_mapa_server("mapa", dados = dados_mapa)
}
