#' Compare bike-sharing system sizes across countries
#'
#' Compares bike-sharing systems across countries by counting
#' their networks and stations.
#'
#' @param countries A character vector of country names.
#' @return A data frame containing each country, the number of
#'   bike-sharing networks, and the total number of stations.
#' @export
compare_system_sizes <- function(countries) {
  if (!is.character(countries) ||
      length(countries) == 0 ||
      anyNA(countries) ||
      any(!nzchar(countries))) {
    stop("Please provide one or more valid country names.")
  }

  results <- lapply(countries, function(country) {
    country_networks <- find_networks(country = country)

    if (nrow(country_networks) == 0) {
      return(data.frame(
        country = country,
        networks = 0L,
        stations = 0L
      ))
    }

    country_code <- countrycode::countrycode(
      country,
      "country.name",
      "iso2c"
    )

    # Retrieving network IDs directly from the API
    response <- httr2::request(
      "https://api.citybik.es/v2/networks"
    ) |>
      httr2::req_perform()

    network_data <- jsonlite::fromJSON(
      httr2::resp_body_string(response)
    )

    ids <- network_data$networks$id[
      network_data$networks$location$country == country_code
    ]

    station_counts <- vapply(ids, function(id) {
      tryCatch(
        nrow(get_stations(id)),
        error = function(e) NA_integer_
      )
    }, integer(1))

    data.frame(
      country = country,
      networks = length(ids),
      stations = if (all(is.na(station_counts))) {
        NA_integer_
      } else {
        sum(station_counts, na.rm = TRUE)
      }
    )
  })

  do.call(rbind, results)
}
