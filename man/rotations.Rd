% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/substitutions_handler.R
\name{rotations}
\alias{rotations}
\title{Get team rotations point by point}
\usage{
rotations(x, team, start_point_id, set_number, new_rotation, new_rotation_id)
}
\arguments{
\item{x}{datavolley or data.frame: a datavolley object as returned by \code{read_dv}, or the plays component of that object}

\item{team}{string: team name}

\item{start_point_id}{vector: vector of pointids for which to return the rotation}

\item{set_number}{value: Set number}

\item{new_rotation}{vector: vector of player number, positioned from 1 to 6}

\item{new_rotation_id}{character: as for \code{new_rotation}, but providing player IDs instead of jersey numbers}
}
\value{
list of 2 data.frames. Current data.frame, without changes, and updated data.frame, with new player rotation.
}
\description{
Get team rotations point by point
}
\examples{
\dontrun{
  x <- read_dv(dv_example_file(), insert_technical_timeouts=FALSE)
  new_x <- rotations(x, start_point_id = 25, new_rotation = c(9,6,15,4,12,7))
}
}
\seealso{
\code{\link{read_dv}}
}
