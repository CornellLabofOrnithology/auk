% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auk-version.R
\name{auk_version}
\alias{auk_version}
\title{Versions of auk, the EBD, and the eBird taxonomy}
\usage{
auk_version()
}
\value{
A list with three elements:
\itemize{
\item \code{auk_version}: the version of \code{auk}, e.g. \code{"auk 0.4.1"}.
\item \code{ebd_version}: a date object specifying the release date of the EBD
version that this \code{auk} version is designed to work with.
\item \code{taxonomy_version}: the year of the taxonomy built in to this version of
\code{auk}, i.e. the one stored in \link{ebird_taxonomy}.
}
}
\description{
This package depends on the version of the EBD and on the eBird taxonomy. Use
this function to determine the currently installed version of \code{auk}, the
version of the EBD that this \code{auk} version works with, and the version of the
eBird taxonomy included in the packages. The EBD is update quarterly, in
March, June, September, and December, while the taxonomy is updated annually
in August or September. To ensure proper functioning, always use the latest
version of the auk package and the EBD.
}
\examples{
auk_version()
}
\seealso{
Other helpers: 
\code{\link{auk_ebd_version}()},
\code{\link{ebird_species}()},
\code{\link{get_ebird_taxonomy}()},
\code{\link{process_barcharts}()}
}
\concept{helpers}
