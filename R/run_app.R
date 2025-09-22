#' Run the geosegR Shiny application
#'
#' @export
#' @import shiny
run_app <- function(dados_mapa) {
  shiny::addResourcePath("www", system.file("app/www", package = "dpupsviz"))
  shiny::shinyApp(ui = app_ui(), server = app_server)
}
