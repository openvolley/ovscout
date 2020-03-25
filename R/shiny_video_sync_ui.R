ov_shiny_video_sync_ui <- function(app_data) {
    ## some startup stuff
    running_locally <- !nzchar(Sys.getenv("SHINY_PORT"))
    video_src <- app_data$dvw$meta$video$file[1]
    if (!fs::file_exists(video_src)) {
        ## can't find the file, go looking for it
        chk <- ovideo::ov_find_video_file(dvw_filename = app_data$dvw_filename, video_filename = video_src)
        if (!is.na(chk)) video_src <- chk
    }

    have_lighttpd <- FALSE
    video_server_port <- sample.int(4000, 1) + 8000 ## random port from 8001
    if (.Platform$OS.type == "unix") {
        tryCatch({
            chk <- sys::exec_internal("lighttpd", "-version")
            have_lighttpd <- TRUE
        }, error = function(e) warning("could not find the lighttpd executable, install it with e.g. 'apt install lighttpd'. Using \"servr\" video option"))
    }
    video_serve_method <- if (have_lighttpd) "lighttpd" else "servr"
    if (video_serve_method == "lighttpd") {
        ## build config file to pass to lighttpd
        lighttpd_conf_file <- tempfile(fileext = ".conf")
        cat("server.document-root = \"", dirname(video_src), "\"\nserver.port = \"", video_server_port, "\"\n", sep = "", file = lighttpd_conf_file, append = FALSE)
        lighttpd_pid <- sys::exec_background("lighttpd", c("-D", "-f", lighttpd_conf_file), std_out = FALSE) ## start lighttpd not in background mode
        lighttpd_cleanup <- function() {
            message("cleaning up lighttpd")
            try(tools::pskill(lighttpd_pid), silent = TRUE)
        }
        onStop(function() try({ lighttpd_cleanup() }, silent = TRUE))
    } else {
        ## start servr instance serving from the video source directory
        servr::httd(dir = dirname(video_src), port = video_server_port)
        onStop(function() {
            message("cleaning up servr")
            servr::daemon_stop()
        })
    }
    video_server_base_url <- paste0("http://localhost:", video_server_port)
    message(paste0("video server ", video_serve_method, " on port: ", video_server_port))
    fluidPage(theme=if (running_locally) "spacelab.css" else "https://cdnjs.cloudflare.com/ajax/libs/bootswatch/3.3.7/spacelab/bootstrap.min.css",
              if (!running_locally) htmltools::htmlDependency("bootstrap", "3.3.7",
                                                              src = c(href = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/"),
                                                              script = "js/bootstrap.min.js", stylesheet = "css/bootstrap.min.css"),
              shinyjs::useShinyjs(),
              tags$head(tags$style("body{font-size:15px} .well{padding:15px;} .myhidden {display:none;} table {font-size: small;} h2, h3, h4 {font-weight: bold;} .shiny-notification { height: 100px; width: 400px; position:fixed; top: calc(50% - 50px); left: calc(50% - 200px); } .code_entry_guide {color:#31708f; background-color:#d9edf7;border-color:#bce8f1;padding:4px;font-size:70%;} .clet {color: red;} .iconbut { font-size: 150%; }"),
                        tags$style("#headerblock {border-radius:14px; padding:10px; margin-bottom:5px; min-height:120px; color:black; border: 1px solid #000766; background:#000766; background: linear-gradient(90deg, rgba(0,7,102,1) 0%, rgba(255,255,255,1) 65%, rgba(255,255,255,1) 100%);} #headerblock h1, #headerblock h2, #headerblock h3, #headerblock h4 {color:#fff;}"),
                        tags$style("#hroster {padding-left: 0px; padding-right: 0px; background-color: #bfefff; padding: 12px;} #vroster {padding-left: 0px; padding-right: 0px; background-color: #bcee68; padding: 12px;}"),
                        if (!is.null(app_data$css)) tags$style(app_data$css),
                        ##key press handling
                        tags$script("$(document).on('keypress', function (e) { var el = document.activeElement; var len = -1; if (typeof el.value != 'undefined') { len = el.value.length; }; Shiny.onInputChange('cmd', e.which + '@' + el.className + '@' + el.id + '@' + el.selectionStart + '@' + len + '@' + new Date().getTime()); });"),
                        tags$script("$(document).on('keydown', function (e) { var el = document.activeElement; var len = -1; if (typeof el.value != 'undefined') { len = el.value.length; }; Shiny.onInputChange('controlkey', e.ctrlKey + '|' + e.altKey + '|' + e.shiftKey + '|' + e.metaKey + '|' + e.which + '@' + el.className + '@' + el.id + '@' + el.selectionStart + '@' + len + '@' + new Date().getTime()); });"),
                        tags$script("$(document).on('shiny:sessioninitialized',function() { Shiny.onInputChange('window_height', $(window).innerHeight()); Shiny.onInputChange('window_width', $(window).innerWidth()); });"),
                        tags$script("var rsztmr; $(window).resize(function() { clearTimeout(rsztmr); rsztmr = setTimeout(doneResizing, 500); }); function doneResizing() { Shiny.onInputChange('window_height', $(window).innerHeight()); Shiny.onInputChange('window_width', $(window).innerWidth()); }"),
                        tags$title("Volleyball scout and video sync")
                        ),
              if (!is.null(app_data$ui_header)) {
                  app_data$ui_header
              } else {
                  fluidRow(id = "headerblock", column(6, tags$h2("Volleyball scout and video sync")),
                           column(3, offset = 3, tags$div(style = "text-align: center;", "Part of the", tags$br(), tags$img(src = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMTAiIGhlaWdodD0iMjEwIj48cGF0aCBkPSJNOTcuODMzIDE4Ny45OTdjLTQuNTUtLjM5Ni0xMi44MTItMS44ODYtMTMuNTgxLTIuNDQ5LS4yNDItLjE3Ny0xLjY5Mi0uNzUzLTMuMjIyLTEuMjgxLTI4LjY5Ni05Ljg5NS0zNS4xNy00NS45ODctMTMuODY4LTc3LjMyMyAyLjY3Mi0zLjkzIDIuNTc5LTQuMTktMS4zOTQtMy45MDYtMTIuNjQxLjktMjcuMiA2Ljk1Mi0zMy4wNjYgMTMuNzQ1LTUuOTg0IDYuOTI3LTcuMzI3IDE0LjUwNy00LjA1MiAyMi44NjIuNzE2IDEuODI2LS45MTgtLjE3LTEuODktMi4zMS03LjM1Mi0xNi4xNzQtOS4xODEtMzguNTYtNC4zMzctNTMuMDc0LjY5MS0yLjA3IDEuNDE1LTMuODY2IDEuNjEtMy45ODkuMTk0LS4xMjMuNzgyLTEuMDUzIDEuMzA3LTIuMDY2IDMuOTQ1LTcuNjE3IDkuNDU4LTEyLjg2MiAxNy44MzktMTYuOTcgMTIuMTcyLTUuOTY4IDI1LjU3NS01LjgyNCA0MS40My40NDUgNi4zMSAyLjQ5NSA4LjgwMiAzLjgwMSAxNi4wNDcgOC40MTMgNC4zNCAyLjc2MiA0LjIxMiAyLjg3NCAzLjU5NC0zLjE3My0yLjgyNi0yNy42ODEtMTYuOTA3LTQyLjE4NS0zNi4wNjgtMzcuMTUxLTQuMjU0IDEuMTE3IDUuMjQtMy4zMzggMTEuNjYtNS40NzMgMTMuMTgtNC4zOCAzOC45MzctNS43NzIgNDYuMDc0LTEuNDg4IDEuMjQ3LjU0NyAyLjIyOCAxLjA5NSAzLjI3NSAxLjYzIDQuMjkgMi4xMDcgMTEuNzMzIDcuNjk4IDE0LjI2NSAxMS40MjcuNDA3LjYgMS4yNyAxLjg2NiAxLjkxNyAyLjgxNCAxMS4zMDggMTYuNTY1IDguNjIzIDQxLjkxLTYuODM4IDY0LjU1Mi0zLjI0OSA0Ljc1OC0zLjI1OCA0Ljc0MiAyLjQ1IDQuMDE4IDMyLjQ4Mi00LjEyMiA0OC41MTUtMjEuOTM1IDM5LjU3OC00My45NzQtMS4xNC0yLjgwOSAxLjU2NiAxLjA2IDMuNTE4IDUuMDMyIDI5LjY5MyA2MC40MTctMjIuNTggMTA3Ljg1My03OS40OTggNzIuMTQzLTUuMDg0LTMuMTktNS4xMjMtMy4xNTItMy45MDIgMy44ODMgNC43MjEgMjcuMjIgMjUuNzgzIDQzLjU2MiA0NC4wODkgMzQuMjEgMS4zNjItLjY5NiAyLjIxLS43NSAyLjIxLS4xNDMtNi43NiAzLjg1Ny0xNi4wMTggNi41NTMtMjMuMTI2IDguMDkxLTcuNTU1IDEuNTQ3LTE4LjM2NiAyLjE3Mi0yNi4wMiAxLjUwNnoiIGZpbGw9IiMwMDA3NjYiLz48ZWxsaXBzZSBjeD0iMTA1Ljk3NSIgY3k9IjEwNC40NDEiIHJ4PSI5NC44NCIgcnk9IjkyLjU0MiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwNzY2IiBzdHJva2Utd2lkdGg9IjEwLjc0Ii8+PC9zdmc+", style = "max-height:3em;"), tags$br(), tags$a(href = "https://github.com/openvolley", "openvolley", target = "_blank"), "project")))
              },
              fluidRow(column(7, tags$video(id = "main_video", style = "border: 1px solid black; width: 90%;", src = file.path(video_server_base_url, basename(video_src)), controls = "controls", autoplay = "false"),
                              fluidRow(column(8, actionButton("all_video_from_clock", label = "Open video/clock time operations menu"),
                                              actionButton("edit_match_data_button", "Edit match data"),
                                              actionButton("edit_teams_button", "Edit teams"),
                                              uiOutput("save_file_ui", inline = TRUE)),
                                       column(4, uiOutput("current_event"))),
                              tags$div(style = "height: 14px;"),
                              fluidRow(column(6,
                                              tags$p(tags$strong("Video controls")), sliderInput("playback_rate", "Playback rate:", min = 0.1, max = 2.0, value = 1.0, step = 0.1), tags$ul(tags$li("[l or 6] forward 2s, [; or ^] forward 10s, [m or 3] forwards 0.1s"), tags$li("[j or 4] backward 2s, [h or $] backward 10s, [n or 1] backwards 0.1s"), tags$li("[q or 0] pause video"), tags$li("[g or #] go to currently-selected event")),
                                              tags$p(tags$strong("Keyboard controls")), tags$ul(tags$li("[r or 5] sync selected event video time"),
                                                                                                tags$li("[i or 8] move to previous skill row"),
                                                                                                tags$li("[k or 2] move to next skill row"),
                                                                                                tags$li("[e or E] edit current code"),
                                                                                                tags$li("[del] delete current code"),
                                                                                                tags$li("[ins] insert new code above current"),
                                                                                                if (isTRUE(app_data$config$insert_sets)) tags$li("[F2] insert setting codes before every attack"),
                                                                                                if (isTRUE(app_data$config$insert_sets)) tags$li("[F4] delete all setting codes (except errors)"),
                                                                                                if (isTRUE(app_data$config$insert_digs)) tags$li("[F6] insert digging codes after every attack"),
                                                                                                if (isTRUE(app_data$config$insert_digs)) tags$li("[F8] delete all digging codes")
                                                                                                ),
                                              tags$p(tags$strong("Other options")),
                                              tags$span("Decimal places on video time:"),
                                              numericInput("video_time_decimal_places", label = NULL, value = 0, min = 0, max = 2, step = 1, width = "6em"),
                                              uiOutput("vtdp_ui")),
                                       column(6, wellPanel(mod_courtrot_ui(id = "courtrot"))) ## court rotation plot and team rosters
                                       )
                              ),
                       column(5, DT::dataTableOutput("playslist", width = "98%"),
                              uiOutput("error_message"))
                       )
              )
}