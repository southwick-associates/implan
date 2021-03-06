% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/output.R
\name{output_read_csv}
\alias{output_read_csv}
\title{Read Implan CSV output into R data frames for an implan activity}
\usage{
output_read_csv(dirname)
}
\arguments{
\item{dirname}{directory name that stores files for selected activity}
}
\description{
Read Implan CSV output into R data frames for an implan activity
}
\examples{
output_dir <- system.file("extdata", "output", package = "implan")
dirname <- file.path(output_dir, "region1", "hunt")
dat <- output_read_csv(dirname)
output_combine(dat)
}
\seealso{
Other functions for implan output loading: 
\code{\link{output_combine}()},
\code{\link{output_format_tax}()},
\code{\link{output}()}
}
\concept{functions for implan output loading}
