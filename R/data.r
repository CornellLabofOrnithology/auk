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
#' - `common_name`: the common name of the species as used in eBird.
#' - `scientific_name`: the scientific name of the species.
#' - `order`: the scientific name of the order that the species belongs to.
#' - `family`: the family of the species, in the form "Parulidae (New World
#' Warblers)".
#' - `report_as`: for taxa that can be resolved to true species (i.e. species,
#' subspecies, and recognizable forms), this field links to the corresponding
#' species code. For taxa that can't be resolved, this field is `NA`.
#'
#' For further details, see \url{http://help.ebird.org/customer/en/portal/articles/1006825-the-ebird-taxonomy}
"ebird_taxonomy"

#' eBird States
#'
#' A data frame of state codes used by eBird. These codes are 4 to 6 characters, 
#' consisting of two parts, the 2-letter ISO country code and a 1-3 character 
#' state code, separated by a dash. For example, `"US-NY"` corresponds to New 
#' York State in the United States. These state codes are required to filter by 
#' state using [auk_state()].
#' 
#' 
#' Note that some countries are not broken into states in eBird and therefore do 
#' not appear in this data frame.
#' 
#' @format A data frame with four variables and 3,145 rows:
#' - `country`: short form of English country name.
#' - `country_code`: 2-letter ISO country code.
#' - `state`: state name.
#' - `state_code`: 4 to 6 character state code.
"ebird_states"