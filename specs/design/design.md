# Exchange Rate Lookup — Design

## Overview

A single-page webapp lets any visitor pick a currency and see its current exchange rate to USD, refreshed daily — no sign-in required. `exchange-webapp` (React SPA) handles the currency-lookup UI; it calls `exchange-api` (Ballerina service), which resolves currencies and their daily USD rates from ExchangeRate-API (v6.exchangerate-api.com) and returns them to the webapp. The service layer keeps the external provider's API key off the browser and gives the platform one place to cache/normalize daily rates.

## Context (C1)

```mermaid
graph TD
    User[User]
    Webapp[Exchange Rate Webapp]
    API[Exchange Rate API]
    Provider[ExchangeRate-API]

    User -->|looks up a currency| Webapp
    Webapp -->|REST calls| API
    API -->|fetches daily rates| Provider
```

## Domain model (ER)

```mermaid
erDiagram
    CURRENCY {
        string code PK
        string name
    }
    EXCHANGE_RATE {
        string currencyCode PK "FK to Currency"
        decimal rateToUsd
        date asOfDate
    }
    CURRENCY ||--|| EXCHANGE_RATE : "has current rate"
```

## Key flows

### Currency rate lookup

```mermaid
sequenceDiagram
    actor User
    participant Webapp as Exchange Rate Webapp
    participant API as Exchange Rate API
    participant Provider as ExchangeRate-API

    User->>Webapp: Open app, select/search currency (e.g. EUR)
    Webapp->>API: GET /currencies/{code}/rate
    API->>Provider: Fetch today's rate for code -> USD
    Provider-->>API: Rate + as-of date
    API-->>Webapp: { currencyCode, rateToUsd, asOfDate }
    Webapp-->>User: Show rate and "last updated" timestamp
```

