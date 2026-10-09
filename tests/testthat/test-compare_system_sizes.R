test_that("compare_system_sizes rejects invalid inputs", {
  expect_error(
    compare_system_sizes(),
    "argument .* is missing"
  )
  expect_error(compare_system_sizes(NULL), "valid country names")
  expect_error(compare_system_sizes(123), "valid country names")
  expect_error(compare_system_sizes(character(0)), "valid country names")
  expect_error(compare_system_sizes(NA_character_), "valid country names")
  expect_error(compare_system_sizes(""), "valid country names")
})

test_that("compare_system_sizes counts networks and stations", {
  api_json <- paste0(
    '{"networks":[',
    '{"id":"sweden1","location":{"country":"SE","city":"Stockholm"}},',
    '{"id":"sweden2","location":{"country":"SE","city":"Gothenburg"}},',
    '{"id":"belgium1","location":{"country":"BE","city":"Brussels"}}',
    ']}'
  )

  local_mocked_bindings(
    find_networks = function(city = NULL, country = NULL) {
      if (country == "Sweden") {
        data.frame(city = c("Stockholm", "Gothenburg"))
      } else {
        data.frame(city = "Brussels")
      }
    },
    get_stations = function(network_id) {
      station_count <- switch(
        network_id,
        sweden1 = 2L,
        sweden2 = 3L,
        belgium1 = 4L
      )
      data.frame(name = paste0("Station", seq_len(station_count)))
    },
    .package = "citybikes"
  )

  local_mocked_bindings(
    request = function(...) "mock_request",
    req_perform = function(req, ...) "mock_response",
    resp_body_string = function(resp, ...) api_json,
    .package = "httr2"
  )

  result <- compare_system_sizes(c("Sweden", "Belgium"))

  expect_equal(result$country, c("Sweden", "Belgium"))
  expect_equal(result$networks, c(2L, 1L))
  expect_equal(result$stations, c(5L, 4L))
})

test_that("compare_system_sizes handles countries with no networks", {
  api_json <- paste0(
    '{"networks":[',
    '{"id":"sweden1","location":{"country":"SE","city":"Stockholm"}}',
    ']}'
  )

  local_mocked_bindings(
    find_networks = function(city = NULL, country = NULL) {
      if (country == "Iceland") {
        data.frame(city = character(0))
      } else {
        data.frame(city = "Stockholm")
      }
    },
    get_stations = function(network_id) {
      data.frame(name = c("Station1", "Station2"))
    },
    .package = "citybikes"
  )

  local_mocked_bindings(
    request = function(...) "mock_request",
    req_perform = function(req, ...) "mock_response",
    resp_body_string = function(resp, ...) api_json,
    .package = "httr2"
  )

  result <- compare_system_sizes(c("Sweden", "Iceland"))

  expect_equal(result$networks, c(1L, 0L))
  expect_equal(result$stations, c(2L, 0L))
})

test_that("compare_system_sizes handles failed station requests", {
  api_json <- paste0(
    '{"networks":[',
    '{"id":"network1","location":{"country":"SE","city":"Stockholm"}},',
    '{"id":"network2","location":{"country":"SE","city":"Gothenburg"}}',
    ']}'
  )

  local_mocked_bindings(
    find_networks = function(city = NULL, country = NULL) {
      data.frame(city = c("Stockholm", "Gothenburg"))
    },
    get_stations = function(network_id) {
      if (network_id == "network1") {
        stop("API unavailable")
      }
      data.frame(name = c("Station1", "Station2", "Station3"))
    },
    .package = "citybikes"
  )

  local_mocked_bindings(
    request = function(...) "mock_request",
    req_perform = function(req, ...) "mock_response",
    resp_body_string = function(resp, ...) api_json,
    .package = "httr2"
  )

  result <- compare_system_sizes("Sweden")

  expect_equal(result$networks, 2L)
  expect_equal(result$stations, 3L)
})
