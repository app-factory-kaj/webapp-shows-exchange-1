// Exchange Rate Lookup — two screens, single role (signed-in User)

screen CurrencyPicker "User searches and selects a currency to look up"
  navbar "ExchangeRate"
  row
    heading "Find a currency"
    right
    search "Search currency code or name…"
  text "Pick a currency to see its current exchange rate to USD."
  table "Code | Currency" -> RateDetail
    row "EUR | Euro"
    row "GBP | British Pound"
    row "JPY | Japanese Yen"
    row "INR | Indian Rupee"
    row "AUD | Australian Dollar"

screen RateDetail "User views the current USD exchange rate for the selected currency"
  navbar "ExchangeRate"
  breadcrumb "Currencies / EUR"
  row
    heading "1 EUR = 1.0842 USD"
    badge "Daily rate" info
  text "Last updated: Aug 18, 2026"
  card "Currency | EUR | Euro"
  row
    right
    button "Back to search" -> CurrencyPicker
