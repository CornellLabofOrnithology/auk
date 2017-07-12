#' eBird Taxonomy
#'
#' A simplified version of the taxonomy used by eBird. Includes proper species
#' as well as various other categories such as `spuh` (e.g. *duck sp.*) and
#' *slash* (e.g. *American Black Duck/Mallard*). This taxonomy is based on the
#' Clements Checklist, which is updated annually, typically in the late summer. 
#' Non-ASCII characters (e.g. those with accents) have been converted to ASCII 
#' equivalents in this data frame.
#'
#' @format A data frame with eight variables and 15,251 rows:
#' - `taxon_order`: numeric value used to sort rows in taxonomic order.
#' - `category`: whether the entry is for a species or another
#' field-identifiable taxon, such as `spuh`, `slash`, `hybrid`, etc.
#' - `species_code`: a unique alphanumeric code identifying each species.
#' - `name_common`: the common name of the species as used in eBird.
#' - `name_scientific`: the scientific name of the species.
#' - `order`: the scientific name of the order that the species belongs to.
#' - `family`: the family of the species, in the form "Parulidae (New World
#' Warblers)".
#' - `report_as`: for subspecies and recognizable forms, this field links to the 
#' corresponding species code.
#'
#' For further details, see \url{http://help.ebird.org/customer/en/portal/articles/1006825-the-ebird-taxonomy}
#'
"ebird_taxonomy"
