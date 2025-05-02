valid_protocols <-c(
  "Incidental", "Stationary", "Traveling", "Historical",
  "Banding", "eBird Pelagic Protocol", "Nocturnal Flight Call Count",
  "Area", "Stationary (2 band, 25m)", "Stationary (2 band, 30m)",
  "Stationary (2 band, 50m)", "Stationary (2 band, 75m)",
  "Stationary (2 band, 100m)", "Stationary (3 band, 30m+100m)",
  "Traveling (2 band, 25m)", "Stationary (Directional)"
)
usethis::use_data(valid_protocols, overwrite = TRUE)