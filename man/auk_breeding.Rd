% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auk-breeding.R
\name{auk_breeding}
\alias{auk_breeding}
\title{Filter to only include observations with breeding codes}
\usage{
auk_breeding(x)
}
\arguments{
\item{x}{\code{auk_ebd} object; reference to basic dataset file created by
\code{\link[=auk_ebd]{auk_ebd()}}.}
}
\value{
An \code{auk_ebd} object.
}
\description{
eBird users have the option of specifying breeding bird atlas codes for their
observations, for example, if nesting building behaviour is observed. Use
this filter to select only those observations with an associated breeding
code. This function only defines the filter and, once all filters have been
defined, \code{\link[=auk_filter]{auk_filter()}} should be used to call AWK and perform the filtering.
}
\examples{
system.file("extdata/ebd-sample.txt", package = "auk") \%>\%
  auk_ebd() \%>\%
  auk_breeding()
}
\seealso{
Other filter: 
\code{\link{auk_bbox}()},
\code{\link{auk_bcr}()},
\code{\link{auk_complete}()},
\code{\link{auk_country}()},
\code{\link{auk_county}()},
\code{\link{auk_date}()},
\code{\link{auk_distance}()},
\code{\link{auk_duration}()},
\code{\link{auk_exotic}()},
\code{\link{auk_extent}()},
\code{\link{auk_filter}()},
\code{\link{auk_last_edited}()},
\code{\link{auk_observer}()},
\code{\link{auk_project}()},
\code{\link{auk_protocol}()},
\code{\link{auk_species}()},
\code{\link{auk_state}()},
\code{\link{auk_time}()},
\code{\link{auk_year}()}
}
\concept{filter}
