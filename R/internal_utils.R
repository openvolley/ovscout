`%eq%` <- function (x, y) x == y & !is.na(x) & !is.na(y)

is_nnn <- function(z) length(z) < 1 || (length(z) == 1 && (is.na(z) || (z %eq% "none")))
nn_or <- function(z, or = "") if (is.null(z)) or else z

## plotting
court_circle <- function(cxy, r = 0.45, cz = NULL, end = "lower", nseg = 31) {
    ## cxy must be data.frame with x and y centres
    if (!is.null(cz)) cxy <- datavolley::dv_xy(cz, end = end)
    th <- seq(0, 2*pi, length.out = nseg)
    crx <- r*cos(th)
    cry <- r*sin(th)
    bind_rows(lapply(seq_len(nrow(cxy)), function(z) data.frame(id = z, x = cxy$x[z] + crx, y = cxy$y[z]+cry)))
}

other_end <- function(end) setdiff(c("upper", "lower"), tolower(end))[1]

dojs <- function(jscmd) {
    ##cat("js: ", jscmd, "\n")
    shiny::getDefaultReactiveDomain()$sendCustomMessage("evaljs", jscmd)
}
js_show2 <- function(id) dojs(paste0("var el=$('#", id, "'); el.show();"))
js_hide2 <- function(id) dojs(paste0("var el=$('#", id, "'); el.hide();"))

names_first_to_capital <- function(x, fun) {
    setNames(x, var2fc(if (missing(fun)) names(x) else vapply(names(x), fun, FUN.VALUE = "", USE.NAMES = FALSE)))
}

var2fc <- function(x) {
    vapply(x, function(z) gsub("_", " ", paste0(toupper(substr(z, 1, 1)), substr(z, 2, nchar(z)))), FUN.VALUE = "", USE.NAMES = FALSE)
}

#' Variable width modal dialog
#'
#' @param width numeric: percentage of viewport width
#' @param ... : as for [shiny::modalDialog()]
#'
#' @return As for [shiny::modalDialog()]
#'
#' @examples
#' \dontrun{
#'   showModal(vwModalDialog(title = "Wide dialog", "blah", width = 90))
#' }
#'
#' @export
vwModalDialog <- function(..., width = 90) {
    rgs <- list(...)
    rgs$size <- "l"
    md <- do.call(shiny::modalDialog, rgs)
    ## recursive function to inject style
    rcc <- function(z) {
        if (is.list(z) && "class" %in% names(z)) {
            idx <- which(names(z) %eq% "class")
            if (any(z[idx] %eq% "modal-lg")) z <- c(list(style = paste0("width: ", width, "vw;")), z)
        }
        ## call recursively on list children
        list_child_idx <- vapply(z, is.list, FUN.VALUE = TRUE)
        if (any(list_child_idx)) z[list_child_idx] <- lapply(z[list_child_idx], rcc)
        z
    }
    rcc(md)
}


uuid <- function(n = 1L) uuid::UUIDgenerate(n = n)
is_uuid <- function(x) is.character(x) & nchar(x) == 36 & grepl("^[[:digit:]abcdef\\-]+$", x)
##all(is_uuid(uuid(n = 1000)))

is_url <- function(z) grepl("^https?://", z, ignore.case = TRUE)
is_youtube_url <- function(z) grepl("https?://[^/]*youtube\\.com", z, ignore.case = TRUE) || grepl("https?://youtu\\.be/", z, ignore.case = TRUE)
is_youtube_id <- function(z) {
    if (is.null(z)) {
        FALSE
    } else if (!is.character(z)) {
        rep(FALSE, length(z))
    } else {
        !is.na(z) & nchar(z) == 11 & grepl("^[[:alnum:]_\\-]+$", z)
    }
}
youtube_url_to_id <- function(z) {
    if (!is_youtube_id(z) && grepl("^https?://", z, ignore.case = TRUE)) {
        if (grepl("youtu\\.be", z, ignore.case = TRUE)) {
            ## assume https://youtu.be/xyz form
            tryCatch({
                temp <- httr::parse_url(z)
                if (!is.null(temp$path) && length(temp$path) == 1 && is_youtube_id(temp$path)) {
                    temp$path
                } else {
                    z
                }
            }, error = function(e) z)
        } else {
            tryCatch({
                temp <- httr::parse_url(z)
                if (!is.null(temp$query$v) && length(temp$query$v) == 1) {
                    temp$query$v
                } else {
                    z
                }
            }, error = function(e) z)
        }
    } else {
        z
    }
}
## probably misguided attempt to distinguish internal/public IP addresses/hostnames
is_remote_url <- function(x) {
    if (is.null(x) || is.na(x) || !nzchar(x) || !is_url(x)) return(FALSE)
    hst <- httr::parse_url(x)$hostname
    !(hst %in% c("localhost") || grepl("^(127|0|192|172\\.16)\\.", hst))
}

dojs <- function(jscmd) {
    ##cat("js: ", jscmd, "\n")
    shiny::getDefaultReactiveDomain()$sendCustomMessage("evaljs", jscmd)
}
js_show2 <- function(id) dojs(paste0("var el=$('#", id, "'); el.show();"))
js_hide2 <- function(id) dojs(paste0("var el=$('#", id, "'); el.hide();"))

plotOutputWithAttribs <- function(outputId, width = "100%", height = "400px", click = NULL, dblclick = NULL, hover = NULL, brush = NULL, inline = FALSE, ...) {
    out <- shiny::plotOutput(outputId = outputId, width = width, height = height, click = click, dblclick = dblclick, hover = hover, brush = brush, inline = inline)
    rgs <- list(...)
    ## add extra attributes
    for (i in seq_along(rgs)) out$attribs[[names(rgs)[i]]] <- rgs[[i]]
    out
}

