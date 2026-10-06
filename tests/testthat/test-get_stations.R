test_that("get_stations returns station data", {
  result <- get_stations("e-cargobike-goteborg")

  expect_true(is.data.frame(result))
  expect_true(nrow(result) > 0)
  expect_named(
    result,
    c("name", "latitude", "longitude", "timestamp",
      "free_bikes", "empty_slots")
  )
})
test_that("get_stations rejects invalid network IDs", {
  expect_error(
    get_stations(123),
    "Invalid network ID"
  )

  expect_error(
    get_stations(""),
    "Invalid network ID"
  )
})
test_that("get_stations rejects a non-existent network", {
  expect_error(
    get_stations("abc123"),
    "Network not found"
  )
})
