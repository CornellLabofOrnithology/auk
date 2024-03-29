% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auk-species.R
\name{auk_species}
\alias{auk_species}
\title{Filter the eBird data by species}
\usage{
auk_species(x, species, taxonomy_version, replace = FALSE)
}
\arguments{
\item{x}{\code{auk_ebd} object; reference to object created by \code{\link[=auk_ebd]{auk_ebd()}}.}

\item{species}{character; species to filter by, provided as scientific or
English common names, or a mixture of both. These names must match the
official eBird Taxomony (\link{ebird_taxonomy}).}

\item{taxonomy_version}{integer; the version (i.e. year) of the taxonomy. In
most cases, this should be left empty to use the version of the taxonomy
included in the package. See \code{\link[=get_ebird_taxonomy]{get_ebird_taxonomy()}}.}

\item{replace}{logical; multiple calls to \code{auk_species()} are additive,
unless \code{replace = FALSE}, in which case the previous list of species to
filter by will be removed and replaced by that in the current call.}
}
\value{
An \code{auk_ebd} object.
}
\description{
Define a filter for the eBird Basic Dataset (EBD) based on species. This
function only defines the filter and, once all filters have been defined,
\code{\link[=auk_filter]{auk_filter()}} should be used to call AWK and perform the filtering.
}
\details{
The list of species is checked against the eBird taxonomy for
validity. This taxonomy is updated once a year in August. The \code{auk} package
includes a copy of the eBird taxonomy, current at the time of release;
however, if the EBD and \code{auk} versions are not aligned, you may need to
explicitly specify which version of the taxonomy to use, in which case
the eBird API will be queried to get the correct version of the taxonomy.
}
\examples{
# common and scientific names can be mixed
species <- c("Canada Jay", "Pluvialis squatarola")
system.file("extdata/ebd-sample.txt", package = "auk") \%>\%
  auk_ebd() \%>\%
  auk_species(species)
  
# alternatively, without pipes
ebd <- auk_ebd(system.file("extdata/ebd-sample.txt", package = "auk"))
auk_species(ebd, species)
}
\seealso{
Other filter: 
\code{\link{auk_bbox}()},
\code{\link{auk_bcr}()},
\code{\link{auk_breeding}()},
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
\code{\link{auk_state}()},
\code{\link{auk_time}()},
\code{\link{auk_year}()}
}
\concept{filter}
