#' Application UI
#'
#' @noRd
#' @import shiny
#' @import bslib
app_ui <- function() {
  bslib::page_navbar(
    title = "Painel de Segregação Étnico-Racial",
    fillable = FALSE,
    footer = shiny::tags$div(
      style = "background-color: #5BB02F; display:flex; align-items:center; gap:10px;",
      shiny::tags$img(src = "www/logo_DPU.png", height = "100px"),
      shiny::tags$img(src = "https://shiny-server.dpu.def.br/catadores.html/DPU_PNUD.png", height = "100px")
    ),
    window_title = "Painel Segregação Étnico-Racial",
    theme = bslib::bs_theme(version = 5, bg = "#FFFFFF", fg = "#000000ff"),
    bslib::nav_panel("Apresentação",
                     bslib::card(
                       shiny::h4("Sobre o Painel"),
                       bslib::card_body(
                         shiny::p("
                         Um mapa da segregação étnico-racial pode ser uma ferramenta estratégica muito poderosa para a Defensoria Pública da União (DPU), porque conecta evidências visuais e geográficas com a defesa de direitos.
                         "),
                         shiny::p("
                         A segregação étnico-racial é um dos fenômenos sociais mais persistentes e estruturantes da sociedade brasileira. Ela se manifesta na forma como os espaços urbanos, o acesso a direitos e as oportunidades de vida são distribuídos de maneira desigual entre grupos raciais.
                         "),
                         shiny::p("
                         Historicamente, o Brasil construiu uma ideia de “democracia racial” que, na prática, oculta as barreiras concretas que pessoas negras e indígenas enfrentam diariamente. Essa segregação não é apenas física — marcada pela concentração de populações negras em áreas periféricas, carentes de infraestrutura e serviços públicos — mas também simbólica, quando certos grupos são invisibilizados ou estigmatizados socialmente.
                         "),
                         shiny::p("
                         Discutir segregação étnico-racial é fundamental porque não se trata de um problema individual, mas sim estrutural. Ela é produzida por políticas públicas excludentes, pela lógica de mercado imobiliário, pela herança da escravidão e pela reprodução cotidiana do racismo em todas as suas dimensões.
                         "),
                         shiny::p("
                         No estudo é possível a Identificação de territórios prioritários, ter acesso sobre dados de segregação para produção de evidências através do painel de dados e observar a prova visual de desigualdade estrutural por meio do mapa. Essa investigação tem o potencial de apoio em ações estratégica defensoriais, em articulação com a Agenda 2030 e direitos humanos.
                         "),
                         shiny::p("
                         O mapa da segregação étnico-racial não é apenas um recurso técnico, mas uma prova concreta e estratégica que fortalece a DPU na defesa de direitos, dá visibilidade ao racismo estrutural e orienta a priorização territorial das ações.
                         "),
                         shiny::p("
                         O acesso aos painéis com as variáveis de análise e o mapeamento do estudo clique aqui:
                         ")
                       )
                     )
    ),
    bslib::nav_panel("Índices de Segregação", mod_tabela_ui("tabela")),
    bslib::nav_panel("Mapa", mod_mapa_ui("mapa"))
  )
}
