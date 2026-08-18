// ExchangeRate-API's conversion_rates map gives codes and rates only, never a
// display name, so this is a small embedded ISO 4217 code -> name table
// covering the common currencies typically present in that map. It is not
// exhaustive: a code returned by the provider but missing here falls back to
// using its own code as the display name (see currencyDisplayName below).
final map<string> & readonly currencyNames = {
    "USD": "US Dollar",
    "EUR": "Euro",
    "GBP": "Pound Sterling",
    "JPY": "Yen",
    "AUD": "Australian Dollar",
    "CAD": "Canadian Dollar",
    "CHF": "Swiss Franc",
    "CNY": "Yuan Renminbi",
    "HKD": "Hong Kong Dollar",
    "NZD": "New Zealand Dollar",
    "SEK": "Swedish Krona",
    "KRW": "Won",
    "SGD": "Singapore Dollar",
    "NOK": "Norwegian Krone",
    "MXN": "Mexican Peso",
    "INR": "Indian Rupee",
    "RUB": "Russian Ruble",
    "ZAR": "Rand",
    "TRY": "Turkish Lira",
    "BRL": "Brazilian Real",
    "TWD": "New Taiwan Dollar",
    "DKK": "Danish Krone",
    "PLN": "Zloty",
    "THB": "Baht",
    "IDR": "Rupiah",
    "HUF": "Forint",
    "CZK": "Czech Koruna",
    "ILS": "New Israeli Sheqel",
    "CLP": "Chilean Peso",
    "PHP": "Philippine Peso",
    "AED": "UAE Dirham",
    "SAR": "Saudi Riyal",
    "MYR": "Malaysian Ringgit",
    "RON": "Romanian Leu",
    "BGN": "Bulgarian Lev",
    "ISK": "Iceland Krona",
    "EGP": "Egyptian Pound",
    "PKR": "Pakistan Rupee",
    "BDT": "Taka",
    "VND": "Dong",
    "UAH": "Hryvnia",
    "NGN": "Naira",
    "KES": "Kenyan Shilling",
    "ARS": "Argentine Peso",
    "COP": "Colombian Peso",
    "PEN": "Sol",
    "QAR": "Qatari Rial",
    "KWD": "Kuwaiti Dinar",
    "BHD": "Bahraini Dinar",
    "OMR": "Rial Omani",
    "JOD": "Jordanian Dinar",
    "LKR": "Sri Lanka Rupee",
    "MAD": "Moroccan Dirham",
    "DZD": "Algerian Dinar",
    "TND": "Tunisian Dinar",
    "GHS": "Ghana Cedi",
    "XOF": "CFA Franc BCEAO",
    "XAF": "CFA Franc BEAC"
};

// Best-effort display name for a currency code: the static table when known,
// otherwise the code itself so the required `name` field is never empty.
isolated function currencyDisplayName(string code) returns string {
    string? known = currencyNames[code];
    if known is string {
        return known;
    }
    return code;
}
