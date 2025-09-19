#' Application server
#'
#' @noRd
app_server <- function(input, output, session) {

  # carregar dados internos do pacote
  dados_tabela <- readRDS(system.file("app/data/dados_tabela.rds", package = "dpupsviz"))
  dados_mapa   <- readRDS(system.file("app/data/dados_mapa.rds", package = "dpupsviz"))

  # módulos do app
  mod_tabela_server("tabela", dados = dados_tabela)
  mod_mapa_server("mapa", dados = dados_mapa)
}
