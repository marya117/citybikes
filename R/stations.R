#' Get bike-sharing stations
#'
#' Gets information about the stations in a CityBikes network,
#' including their location and current bike availability.
#'
#' @param network_id The ID of the CityBikes network.
#' @return A data frame containing station names, locations,
#'   update times, available bikes, and empty slots.
#' @export

get_stations<-function(network_id){
  network_url<-paste0(
    "https://api.citybik.es/v2/networks/",
    network_id
  )
  response<-httr2::request(network_url) |>
    httr2::req_perform()
  network_json<-httr2::resp_body_string(response)
  network_data<-jsonlite::fromJSON(network_json)
  stations<-network_data$network$stations[,c("name","latitude","longitude","timestamp","free_bikes","empty_slots")]
  return(stations)
}
