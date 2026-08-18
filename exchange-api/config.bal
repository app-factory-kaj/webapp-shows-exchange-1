import ballerina/os;

// API key for the external ExchangeRate-API provider. Injected by the platform
// via the exchange-rate-provider dependency's wiring. Left empty at startup is
// tolerated (see provider_client.bal) so the service never crashes hard on a
// missing secret — a request that needs it fails with a 502 instead.
configurable string exchangeRateApiKey = os:getEnv("EXCHANGE_RATE_API_KEY");
