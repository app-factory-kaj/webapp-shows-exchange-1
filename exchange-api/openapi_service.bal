import ballerina/http;
import ballerina/log;
import ballerina/url;

listener http:Listener ep0 = new (9090);

// No sign-in anywhere in this service (see specs/design/security.md); the
// only thing exposed here is CORS so exchange-webapp's browser can call these
// GET endpoints directly - there is no API gateway in front of this service.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET"]
    }
}
service / on ep0 {
    # List supported currencies
    #
    # + search - filter by currency code or name
    # + 'limit - max items to return
    # + offset - items to skip
    # + return - Paginated list of supported currencies
    resource function get currencies(string? search, int 'limit = 20, int offset = 0) returns CurrencyList|http:InternalServerError {
        ProviderSnapshot|error snapshot = fetchProviderData();
        if snapshot is error {
            log:printError("failed to load currency data", 'error = snapshot);
            return <http:InternalServerError>{body: {code: 500, message: "exchange rate data unavailable"}};
        }

        int boundedLimit = 'limit < 1 ? 20 : ('limit > 100 ? 100 : 'limit);
        int boundedOffset = offset < 0 ? 0 : offset;

        string[] allCodes = snapshot.rates.keys().sort();
        Currency[] matching = [];
        string? normalizedSearch = ();
        if search is string && search.trim().length() > 0 {
            normalizedSearch = search.trim().toLowerAscii();
        }

        foreach string code in allCodes {
            string name = currencyDisplayName(code);
            if normalizedSearch is string {
                boolean codeMatches = code.toLowerAscii().includes(normalizedSearch);
                boolean nameMatches = name.toLowerAscii().includes(normalizedSearch);
                if !codeMatches && !nameMatches {
                    continue;
                }
            }
            matching.push({code: code, name: name});
        }

        int total = matching.length();
        int endIndex = boundedOffset + boundedLimit;
        if endIndex > total {
            endIndex = total;
        }
        Currency[] page = boundedOffset < total ? matching.slice(boundedOffset, endIndex) : [];

        string? nextUri = endIndex < total ? buildPageUri(boundedLimit, endIndex, search) : ();
        string? previousUri = ();
        if boundedOffset > 0 {
            int previousOffset = boundedOffset - boundedLimit;
            if previousOffset < 0 {
                previousOffset = 0;
            }
            previousUri = buildPageUri(boundedLimit, previousOffset, search);
        }

        CurrencyList result = {count: total, next: nextUri, previous: previousUri, data: page};
        return result;
    }

    # Get the current USD exchange rate for a currency
    #
    # + code - ISO 4217 currency code, e.g. EUR
    # + return - returns can be any of following types
    # http:Ok (Current rate for the requested currency)
    # http:BadRequest (Invalid currency code)
    # http:NotFound (Currency not found)
    resource function get currencies/[string code]/rate() returns ExchangeRate|ErrorBadRequest|ErrorNotFound|http:InternalServerError {
        string normalizedCode = code.trim().toUpperAscii();
        if !re `^[A-Z]{3}$`.isFullMatch(normalizedCode) {
            ErrorBadRequest badRequest = {
                body: {code: 400, message: "invalid currency code", description: "currency code must be 3 letters"}
            };
            return badRequest;
        }

        ProviderSnapshot|error snapshot = fetchProviderData();
        if snapshot is error {
            log:printError("failed to load exchange rate data", 'error = snapshot);
            return <http:InternalServerError>{body: {code: 500, message: "exchange rate data unavailable"}};
        }

        decimal? rate = snapshot.rates[normalizedCode];
        if rate is () {
            ErrorNotFound notFound = {
                body: {code: 404, message: "currency not found", description: "no rate available for " + normalizedCode}
            };
            return notFound;
        }

        ExchangeRate exchangeRate = {currencyCode: normalizedCode, rateToUsd: rate, asOfDate: snapshot.asOfDate};
        return exchangeRate;
    }
}

// Builds a relative pagination URI preserving the current search term.
isolated function buildPageUri(int 'limit, int offset, string? search) returns string {
    string uri = string `/currencies?limit=${'limit}&offset=${offset}`;
    if search is string && search.trim().length() > 0 {
        string|error encoded = url:encode(search, "UTF-8");
        string safeSearch = encoded is string ? encoded : search;
        uri = uri + "&search=" + safeSearch;
    }
    return uri;
}
