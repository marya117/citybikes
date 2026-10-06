test_that("find_networks find networks in a city",{
  result<- find_networks(city="Göteborg")
  expect_true(is.data.frame(result))
  expect_true(nrow(result)>0)
})
test_that("find_networks find networks in a city",{
  result<- find_networks(country="sweden")
  expect_true(is.data.frame(result))
  expect_true(nrow(result)>0)
})
test_that("find_networks can search by city and country", {
  result <- find_networks(
    city = "Göteborg",
    country = "Sweden")
  expect_true(is.data.frame(result))
  expect_true(nrow(result) > 0)
  expect_true(all(result$city == "Göteborg"))
  expect_true(all(result$country == "SE"))
})
