library(shiny)
library(leaflet)
library(citybikes)

cities <- c(
  "Chicago" = "divvy",
  "London" = "santander-cycles"
)

ui <- fluidPage(

  titlePanel("citybikes"),

  selectInput(
    inputId = "city",
    label = "Choose a city:",
    choices = cities
  ),

  leafletOutput(
    outputId = "bike_map",
    height = "600px"
  )
)

server <- function(input, output, session) {

  stations <- reactive({

    citybikes::get_stations(input$city)

  })

  output$bike_map <- renderLeaflet({

    data <- stations()

    data <- data[data$free_bikes > 0, ]

    leaflet(data) |>
      addTiles() |>
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        popup = ~paste0(
          "<b>", name, "</b><br>",
          "Bikes available: ", free_bikes, "<br>",
          "Empty slots: ", empty_slots
        )
      )

  })
}

shinyApp(
  ui = ui,
  server = server
)
