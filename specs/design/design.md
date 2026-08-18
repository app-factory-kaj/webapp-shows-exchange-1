# Exchange Rate Lookup — Design

## Overview

A single-page webapp lets any visitor pick a currency and see its current exchange rate to USD, refreshed daily — no sign-in required. `exchange-webapp` (React SPA) handles the currency-lookup UI; it calls `exchange-api` (Ballerina service), which resolves currencies and their daily USD rates from ExchangeRate-API (v6.exchangerate-api.com) and returns them to the webapp. The service layer keeps the external provider's API key off the browser and gives the platform one place to cache/normalize daily rates.

## Context (C1)

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

