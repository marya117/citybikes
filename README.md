# citybikes

<!-- badges: start -->
[![R-CMD-check](https://github.com/marya117/citybikes/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/marya117/citybikes/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
<!-- badges: end -->

An R package for accessing and searching bike-sharing network and station
information from the [CityBikes API](https://api.citybik.es/v2/), which covers
bike-share systems in hundreds of cities worldwide.

## Features

- Search for bike-sharing networks with `find_networks()`
- Retrieve live station data for a network with `get_stations()`
- Compare the size of different bike-sharing systems with `compare_system_sizes()`
- Interactive Shiny app for exploring networks and stations

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("marya117/citybikes")
```

## Usage

```r
library(citybikes)

# Search for bike-sharing networks
networks <- find_networks(city = "Stockholm")

# Get stations for a network (here: Divvy in Chicago)
stations <- get_stations("divvy")

# Compare the size of bike-sharing systems across countries
compare_system_sizes(c("Sweden", "Belgium", "France"))
```

See `?find_networks`, `?get_stations` and `?compare_system_sizes` for the full
argument lists, or browse the vignette:

```r
vignette("citybikes")
```

## Shiny app

The package ships with an interactive Shiny app in `inst/shiny-app`:

```r
shiny::runApp(system.file("shiny-app", package = "citybikes"))
```

## Development

```r
devtools::load_all()   # load the package
devtools::document()   # regenerate docs and NAMESPACE
devtools::test()       # run the testthat tests
devtools::check()      # full R CMD check
```

Every push and pull request is checked by the R-CMD-check GitHub Actions
workflow shown in the badge above.

## Authors

- Sheethal Lakshmana (author, maintainer)
- Mariam Yayloyan (author, contributor)

## License

MIT, see [LICENSE.md](LICENSE.md).

## Acknowledgements

Data provided by the open [CityBikes](https://citybik.es/) API.
