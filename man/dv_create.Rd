% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scouting_utils.R
\name{dv_create}
\alias{dv_create}
\title{Create a new datavolley match object}
\usage{
dv_create(
  match,
  more,
  teams,
  players_h,
  players_v,
  video_file,
  attacks = ov_simplified_attack_table(),
  setter_calls = ov_default_setter_calls_table(),
  winning_symbols = ov_default_winning_symbols(),
  zones_or_cones = "Z",
  regulation = "indoor rally point",
  comments
)
}
\arguments{
\item{match}{list or single-row data.frame: (optional) with components \code{date} (defaults to current date), \code{time} (defaults to current time), \code{season}, \code{league}, \code{phase}, \code{home_away}, \code{day_number}, \code{match_number}, \code{regulation}, \code{zones_or_cones}. \code{zones_or_cones} can also be provided directly}

\item{more}{list or single-row data.frame: (optional) with components \code{referees}, \code{spectators}, \code{receipts}, \code{city}, \code{arena}, \code{scout}}

\item{teams}{data.frame: a 2-row data frame, with required columns \code{team_id}, \code{team} and optional columns \code{coach}, \code{assistant}, \code{shirt_colour}}

\item{players_h, players_v}{data.frame: with required columns \code{number}, \code{firstname}, \code{lastname}, and optional columns \code{player_id}, \code{role} (character vector with "outside", "opposite", "middle", "libero", "setter"), \code{nickname}, \code{special_role} (character vector with "L", "C", or NA), \code{foreign} (logical, defaults to \code{FALSE})}

\item{video_file}{string: (optional) path to video file}

\item{attacks}{data.frame: as returned by \code{\link[=ov_simplified_attack_table]{ov_simplified_attack_table()}} or \code{\link[=ov_default_attack_table]{ov_default_attack_table()}}}

\item{setter_calls}{data.frame: as returned by \code{\link[=ov_default_setter_calls_table]{ov_default_setter_calls_table()}}}

\item{winning_symbols}{data.frame: as returned by \code{\link[=ov_default_winning_symbols]{ov_default_winning_symbols()}}}

\item{zones_or_cones}{string: "Z" or "C". Will be ignored if \code{zones_or_cones} is provided in the \code{match} parameter}

\item{regulation}{string: "indoor rally point", "beach rally point", or "indoor sideout". Will be ignored if \code{regulation} is provided in the \code{match} parameter}

\item{comments}{character: optional vector of length up to 5, of comments}
}
\value{
A datavolley object
}
\description{
Create a new datavolley match object
}
\examples{
x <- dv_create(teams = data.frame(team_id = c("TM1", "TM2"), team = c("Team 1", "Team 2")),
               comments = "Test file",
               players_h = data.frame(firstname = toupper(letters[1:7]), lastname = "Player",
                                      number = 1:7),
               players_v = data.frame(firstname = letters[10:15], lastname = "VisPlayer",
                                      number = 10:15))

## enter the team lineups for set 1
x <- dv_set_lineups(x, set_number = 1, lineups = list(6:1, 15:10), setter_positions = c(2, 1))

}
