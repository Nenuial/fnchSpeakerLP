#' results UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_results_ui <- function(id){
  ns <- NS(id)
  tagList(
    tags$head(
      HTML(
        "
          <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          "
      )
    ),

    bs4Card(
      title = "Paramètres",
      collapsible = TRUE,
      collapsed = FALSE,
      closable = FALSE,
      headerBorder = TRUE,
      status = "primary",
      width = 12,

      fluidRow(
        col_6(
          shiny::selectInput(
            inputId = ns("event_id"),
            label = "Concours",
            choices = rsvps::get_fnch_sp_events_dr() |>
              dplyr::select(titre, id) |>
              tibble::deframe()
          )
        ),
        col_6(
          shiny::uiOutput(
            outputId = ns("startlist_ui")
          )
        )
      ),

      fluidRow(
        col_6(
          shiny::numericInput(
            inputId = ns("nb_ranks"),
            label = "Rang max.",
            value = 5, min = 5, max = 10, step = 1
          )
        ),
        col_6(
          shiny::numericInput(
            inputId = ns("nb_years"),
            label = "Nombre d'années",
            value = 1, min = 1, max = 5, step = 1
          )
        )
      ),
      fluidRow(
        col_6(
          shiny::selectInput(
            inputId = ns("class_min"),
            label = "Catégorie min.",
            choices = rsvps::get_fnch_sp_class_cat_dr()
          )
        ),
        col_6(
          shiny::numericInput(
            inputId = ns("titles_min"),
            label = "Titres depuis",
            value = 2015, min = 2015, max = format(Sys.Date(), "%Y") |> as.numeric() - 1, step = 1
          )
        )
      ),
      fluidRow(
        col_12(
          shiny::actionButton(
            inputId = ns("load"),
            label = "Charger"
          )
        )
      )
    ),

    bs4Card(
      id = ns("startlist-box"),
      title = "Liste",
      collapsed = FALSE,
      closable = FALSE,
      headerBorder = TRUE,
      status = "primary",
      width = 12,

      fluidRow(
        col_12(
          uiOutput(ns("startlist_placeholder"))
        )
      ),

      textOutput("keepAlive")
    )
  )
}

#' results Server Functions
#'
#' @noRd
mod_results_server <- function(id){
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$keepAlive <- renderText({
      req(input$count)
      paste("keep alive ", input$count)
    })

    observe({
      req(input$event_id)

      output$startlist_ui <- shiny::renderUI({
        shiny::selectInput(
          inputId = ns("class_id"),
          label = "Épreuve",
          choices = rsvps::get_fnch_event_startlists(input$event_id) |>
            dplyr::mutate(name = glue::glue("{nummer} - {kategorie_text} - {name}"), id) |>
            dplyr::select(name, id) |>
            tibble::deframe()
        )
      })
    })

    observeEvent(input$load,{
      output$startlist_placeholder <- renderUI({
        reactable::reactableOutput(
          outputId = ns("startlist_table")
        ) |> shinycssloaders::withSpinner()
      })

      output$startlist_table <- reactable::renderReactable({
        rsvps::get_fnch_sp_startlist_dr(
          eventid = isolate(input$event_id),
          classid = isolate(input$class_id),
          nb_years = isolate(input$nb_years),
          nb_ranks = isolate(input$nb_ranks),
          class_min = isolate(input$class_min),
          titles_min = isolate(input$titles_min)
        )
      })
    })
  })
}

## To be copied in the UI
# mod_results_ui("results_1")

## To be copied in the server
# mod_results_server("results_1")
