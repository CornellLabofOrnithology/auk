#' Split an eBird data file by species
#' 
#' Given an eBird Basic Dataset (EBD) and a list of species, split the file into 
#' multiple text files, one for each species. This function is typically used 
#' after [auk_filter()] has been applied if the resulting file is too large to 
#' be read in all at once.
#'
#' @param file character; input file.
#' @param species species character; species to filter and split by, provided as
#'   scientific or English common names, or a mixture of both. These names must
#'   match the official eBird Taxomony ([ebird_taxonomy]).
#' @param prefix character; a file and directory prefix. For example, if 
#'   splitting by species "A" and "B" and `prefix = "data/ebd_"`, the resulting 
#'   files will be "data/ebd_A.txt" and "data/ebd_B.txt".
#' @param ext characer; file extension, typically "txt".
#' @param sep character; the input field separator, the eBird file is tab
#'   separated by default. Must only be a single character and space delimited
#'   is not allowed since spaces appear in many of the fields.
#' @param overwrite logical; overwrite output files if they already exists
#'
#' @return A vector of output filenames, one for each species.
#' @export
#' @examples
#' \dontrun{
#' species <- c("Gray Jay", "Cyanocitta stelleri")
#' # get the path to the example data included in the package
#' # in practice, provide path to a filtered ebd file
#' # e.g. f <- "data/ebd_filtered.txt
#' f <- system.file("extdata/ebd-sample.txt", package = "auk")
#' # output to a temporary directory for example
#' # in practice, provide the path to the output location
#' # e.g. prefix <- "output/ebd_"
#' prefix <- file.path(tempdir(), "ebd_")
#' species_files <- auk_split(f, species = species, prefix = prefix)
#' }
auk_split <- function(file, species, prefix = "", ext = "txt", sep = "\t",
                      overwrite = FALSE) {
  awk_path <- auk_getpath()
  if (is.na(awk_path)) {
    stop("auk_clean() requires a valid AWK install.")
  }
  assertthat::assert_that(
    file.exists(file),
    is.character(species),
    assertthat::is.string(prefix),
    assertthat::is.string(ext),
    assertthat::is.string(sep), nchar(sep) == 1, sep != " ",
    assertthat::is.flag(overwrite)
  )
  file <- path.expand(file)
  
  # check all species names are valid and convert to scientific
  species_clean <- ebird_species(species)
  if (any(is.na(species_clean))) {
    stop(
      paste0("The following species were not found in the eBird taxonomy: \n\t",
             paste(species[is.na(species_clean)], collapse =", "))
    )
  }
  if (length(species_clean) < 1) {
    stop("Provide at least 1 species to split on.")
  }
  
  # check output files
  if (!dir.exists(dirname(prefix))) {
    stop("Output directory doesn't exist.")
  }
  prefix <- path.expand(prefix)
  f_sp <- paste0(prefix,
                 stringr::str_replace_all(species_clean, "[^a-zA-Z]", "_"),
                 ".", ext)
  for (f in f_sp) {
    if (file.exists(f)) {
      if (overwrite) {
        unlink(f_sp)
      } else {
        stop("Output file already exists, use overwrite = TRUE.")
      }
    }
  }
  
  # determine species column number
  header <- tolower(get_header(file, sep))
  sp_col <- which(header == "scientific name")
  stopifnot(length(sp_col) == 1)
  
  # copy in header rows
  header_row <- readLines(file, 1)
  for (f in f_sp) {
    writeLines(header_row, f)
  }
  
  # set up species filter
  sp_condition <- paste0("$", sp_col, " == \"", species_clean, "\"",
                         collapse = " || ")
  
  # construct awk command
  awk <- str_interp(awk_split,
                    list(sep = sep, col = sp_col, condition = sp_condition,
                         prefix = prefix, ext = ext))
  
  # run command
  exit_code <- system2(awk_path, args = paste0("'", awk, "' ", file))
  if (exit_code == 0) {
    f_sp
  } else {
    exit_code
  }
}

awk_split <- "
BEGIN {
  FS = \"${sep}\"
  OFS = \"${sep}\"
}
{
  if (${condition}) {
    species = $${col}
    gsub(/[^a-zA-Z]/, \"_\", species)
    species = \"${prefix}\"species\".${ext}\"
    print >> species
    close (species)
  }
}
"