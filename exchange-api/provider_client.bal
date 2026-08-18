import ballerina/http;
import ballerina/log;
import ballerina/time;

// Fixed address of the external ExchangeRate-API provider (per its own
// contract's `servers:` entry) - not an injected dependency URL, since only
// the API key is platform-wired for this "external" dependency.
final http:Client providerClient = check new ("https://v6.exchangerate-api.com/v6");

// Rates refresh daily upstream, so a fetch is cached for this long rather than
// hitting the provider on every request.
final decimal CACHE_TTL_SECONDS = 21600.0d;

// Shape returned by the provider's `/v6/{apiKey}/latest/USD`, restricted to
// the fields this service actually reads. Field names bind to the wire
// payload's exact keys.
type LatestRatesResponse record {|
    string result;
    string time_last_update_utc?;
    string base_code;
    map<decimal> conversion_rates;
|};

// In-memory snapshot of the provider's last successful fetch.
type ProviderSnapshot record {|
    map<decimal> rates;
    string asOfDate;
    time:Utc fetchedAt;
|};

isolated ProviderSnapshot? cachedSnapshot = ();

isolated function readCachedSnapshot() returns ProviderSnapshot? {
    lock {
        ProviderSnapshot? current = cachedSnapshot;
        if current is () {
            return ();
        }
        decimal ageSeconds = time:utcDiffSeconds(time:utcNow(), current.fetchedAt);
        if ageSeconds > CACHE_TTL_SECONDS {
            return ();
        }
        return current.clone();
    }
}

isolated function writeCachedSnapshot(ProviderSnapshot snapshot) {
    lock {
        cachedSnapshot = snapshot.clone();
    }
}

// Fetches the latest USD conversion rates, using the in-memory cache when it
// is still fresh. Returns an error when the API key is missing/empty or the
// provider call fails - callers turn that into a 5xx rather than crashing.
isolated function fetchProviderData() returns ProviderSnapshot|error {
    ProviderSnapshot? cached = readCachedSnapshot();
    if cached is ProviderSnapshot {
        return cached;
    }

    string apiKey = exchangeRateApiKey;
    if apiKey.trim().length() == 0 {
        return error("EXCHANGE_RATE_API_KEY is not configured");
    }

    string path = "/" + apiKey + "/latest/USD";
    json response = check providerClient->get(path);
    LatestRatesResponse latestRates = check response.cloneWithType(LatestRatesResponse);
    if latestRates.result != "success" {
        return error("exchange rate provider returned a non-success result");
    }

    string? timeLastUpdateUtc = latestRates?.time_last_update_utc;
    string asOfDate = timeLastUpdateUtc is string ? toIsoDate(timeLastUpdateUtc) : todayIsoDate();

    ProviderSnapshot snapshot = {
        rates: latestRates.conversion_rates.clone(),
        asOfDate: asOfDate,
        fetchedAt: time:utcNow()
    };
    writeCachedSnapshot(snapshot);
    return snapshot;
}

final map<string> & readonly monthNumbers = {
    "Jan": "01", "Feb": "02", "Mar": "03", "Apr": "04", "May": "05", "Jun": "06",
    "Jul": "07", "Aug": "08", "Sep": "09", "Oct": "10", "Nov": "11", "Dec": "12"
};

// Parses the provider's `time_last_update_utc` (RFC 1123 style, e.g.
// "Sun, 17 Aug 2025 00:00:01 +0000") into an ISO 8601 date ("2025-08-17").
// Falls back to today's date if the format is ever unexpected.
isolated function toIsoDate(string providerTimestamp) returns string {
    string[] parts = re `\s+`.split(providerTimestamp.trim());
    if parts.length() < 4 {
        log:printWarn("unexpected provider timestamp format", timestamp = providerTimestamp);
        return todayIsoDate();
    }
    string day = parts[1];
    string monthAbbrev = parts[2];
    string year = parts[3];
    string? monthNumber = monthNumbers[monthAbbrev];
    if monthNumber is () {
        log:printWarn("unrecognized month in provider timestamp", timestamp = providerTimestamp);
        return todayIsoDate();
    }
    string paddedDay = day.length() == 1 ? "0" + day : day;
    return year + "-" + monthNumber + "-" + paddedDay;
}

isolated function todayIsoDate() returns string {
    time:Civil civil = time:utcToCivil(time:utcNow());
    int year = civil.year;
    int month = civil.month;
    int day = civil.day;
    string monthStr = month < 10 ? "0" + month.toString() : month.toString();
    string dayStr = day < 10 ? "0" + day.toString() : day.toString();
    return year.toString() + "-" + monthStr + "-" + dayStr;
}
