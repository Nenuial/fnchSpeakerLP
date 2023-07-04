#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bs4Dash
#' @noRd
app_server <- function(input, output, session) {
  # # Setup for SQLite DB
  # credentials <- data.frame(
  #   user = c("burkhardp"), # mandatory
  #   password = c("planeyse"), # secret initial password
  #   start = c("2022-01-01"), # optinal (all others)
  #   expire = c(NA),
  #   admin = c(TRUE),
  #   stringsAsFactors = FALSE
  # )
  #
  # keyring::key_set("fnchSpeaker", "dbAdmin") # Set password for SQLite DB
  # shinymanager::create_db(
  #   credentials_data = credentials,
  #   sqlite_path = "inst/users.sqlite",
  #   passphrase = keyring::key_get("fnchSpeaker", "dbAdmin")
  # )

  session$userData$auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(
      fs::path(rappdirs::user_data_dir(appname = "fnchSpeakerLP"), "users.sqlite"),
      passphrase = keyring::key_get("fnchSpeaker", "dbAdmin")
    )
  )

  # Your application server logic
  mod_results_server("results")
}
