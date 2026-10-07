#'
#' Searches the CityBikes API for bike-sharing networks
#' available in the specified city or country.
#'
#' @param city The name of the city to search for.
#' @param country The name of the country to search for.
#' @return A data frame containing matching bike-sharing networks.
#' @export

find_networks <- function(city = NULL, country = NULL) {
  if (is.null(city) && is.null(country)) {
    stop("Please provide either a city or a country.")
  }
  networks_url <- "https://api.citybik.es/v2/networks"
  response <- httr2::request(networks_url) |>
    httr2::req_perform()
  networks_json <- httr2::resp_body_string(response)
  networks_data <- jsonlite::fromJSON(networks_json)
  if (!is.null(country)) {
    country_code <- countrycode::countrycode(
      country,
      "country.name",
      "iso2c"
    )}
  if (!is.null(city) && !is.null(country)) {
    result <- networks_data$networks$location[
      networks_data$networks$location$city == city &
        networks_data$networks$location$country == country_code,
    ]}
  else if (!is.null(city)) {
    result <- networks_data$networks$location[
      networks_data$networks$location$city == city,
    ]}
  else {
    result <- networks_data$networks$location[
      networks_data$networks$location$country == country_code,
    ]}
  if (nrow(result) == 0) {
    message("No bike-sharing network found")
  }
  return(result)
}
