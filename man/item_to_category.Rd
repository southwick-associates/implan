% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{item_to_category}
\alias{item_to_category}
\title{Implan hunting item to category crosswalk}
\format{A data frame with 150 rows and 5 columns"
\describe{
  \item{activity_group}{"oia", "hunt", "fish", "wildlife"}
  \item{type}{"trip" or "equip"}
  \item{item}{food, lodge, etc.}
  \item{category}{implan spending category}
  \item{share}{category share for item}
}}
\usage{
item_to_category
}
\description{
A dataset to relate national survey spending data with implan spending categories
prepared from `system.file("extdata", "implan-categories.xlsx", package = "implan")`
}
\seealso{
Other data: 
\code{\link{category_to_sector536}},
\code{\link{category_to_sector546}},
\code{\link{sector536_to_sector546}},
\code{\link{sectors536}},
\code{\link{sectors546}},
\code{\link{spending}}
}
\concept{data}
\keyword{datasets}
