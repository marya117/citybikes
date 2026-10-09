library(shiny)
library(leaflet)
library(citybikes)

# Getting the list of available bike-sharing networks
networks_url <- "https://api.citybik.es/v2/networks"

response <- httr2::request(networks_url) |>
  httr2::req_perform()

networks_json <- httr2::resp_body_string(response)
networks_data <- jsonlite::fromJSON(networks_json)

# Keeping network IDs and their locations
networks <- data.frame(
  id = networks_data$networks$id,
  city = networks_data$networks$location$city,
  country_code = networks_data$networks$location$country,
  stringsAsFactors = FALSE
)

# Converting country codes to country names
country_codes <- sort(unique(networks$country_code))

country_names <- countrycode::countrycode(
  country_codes,
  origin = "iso2c",
  destination = "country.name",
  custom_match = c("XK" = "Kosovo"),
  warn = FALSE
)

# Using country codes if a name is still unavailable
country_names[is.na(country_names)] <- country_codes[
  is.na(country_names)
]

# Sorting countries alphabetically
country_order <- order(country_names)

country_choices <- setNames(
  country_codes[country_order],
  country_names[country_order]
)

# User interface
ui <- fluidPage(
  titlePanel("CityBikes"),

  # CSS to move the Leaflet zoom controls
  tags$head(
    tags$style(HTML("
      .leaflet-top.leaflet-left {
        left: auto !important;
        right: 10px !important;
      }
      .leaflet-top.leaflet-right {
        right: 10px !important;
      }
    "))
  ),

  selectInput(
    inputId = "country",
    label = "Choose a country:",
    choices = country_choices
  ),

  selectInput(
    inputId = "city",
    label = "Choose a city (optional):",
    choices = c("All cities" = ""),
    selected = ""
  ),

  # Adding space between the dropdowns and the map
  tags$div(
    style = "margin-top: 20px;",
    leafletOutput(
      outputId = "bike_map",
      height = "600px"
    )
  )
)

# Server logic
server <- function(input, output, session) {

  # Updating the city dropdown when the country changes
  observeEvent(input$country, {
    available_cities <- networks$city[
      networks$country_code == input$country &
        !is.na(networks$city) &
        nzchar(networks$city)
    ]

    available_cities <- sort(unique(available_cities))

    updateSelectInput(
      session = session,
      inputId = "city",
      choices = c(
        "All cities" = "",
        setNames(available_cities, available_cities)
      ),
      selected = ""
    )
  })

  # Finding networks matching the selected country and city
  selected_networks <- reactive({
    result <- networks[
      networks$country_code == input$country,
      ,
      drop = FALSE
    ]

    if (!is.null(input$city) && input$city != "") {
      result <- result[
        result$city == input$city,
        ,
        drop = FALSE
      ]
    }

    result
  })

  # Retrieving station data for the selected networks
  stations <- reactive({
    network_ids <- selected_networks()$id

    if (length(network_ids) == 0) {
      return(NULL)
    }

    station_list <- lapply(network_ids, function(id) {
      tryCatch({
        station_data <- citybikes::get_stations(id)
        station_data$network_id <- id
        station_data$city <- networks$city[
          match(id, networks$id)
        ]
        station_data
      }, error = function(e) {
        NULL
      })
    })

    station_list <- Filter(
      function(x) !is.null(x),
      station_list
    )

    if (length(station_list) == 0) {
      return(NULL)
    }

    do.call(rbind, station_list)
  })

  # Displaying the map
  output$bike_map <- renderLeaflet({
    data <- stations()

    if (is.null(data) || nrow(data) == 0) {
      return(leaflet() |> addTiles())
    }

    # Showing only stations with available bikes
    data <- data[
      !is.na(data$free_bikes) & data$free_bikes > 0,
      ,
      drop = FALSE
    ]

    if (nrow(data) == 0) {
      return(leaflet() |> addTiles())
    }

    leaflet(
      data,
      options = leafletOptions(zoomControl = TRUE)
    ) |>
      addTiles() |>
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        popup = ~paste0(
          "<b>", name, "</b><br>",
          "City: ", city, "<br>",
          "Bikes available: ", free_bikes, "<br>",
          "Empty slots: ", empty_slots
        )
      )
  })
}

shinyApp(ui = ui, server = server)
