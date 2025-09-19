#' Run the geosegR Shiny application
#'
#' @export
run_app <- function() {
  shiny::addResourcePath("www", system.file("app/www", package = "dpupsviz"))
  shiny::shinyApp(ui = app_ui(), server = app_server)
}
