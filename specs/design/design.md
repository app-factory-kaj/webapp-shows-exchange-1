# Exchange Rate Lookup — Design

## Overview

A single-page webapp lets a signed-in user pick a currency and see its current exchange rate to USD, refreshed daily. `exchange-webapp` (React SPA) handles sign-in via Thunder and the currency-lookup UI; it calls `exchange-api` (Ballerina service), which resolves currencies and their daily USD rates from an external exchange-rate data provider and returns them to the webapp. The service layer keeps the external provider's details off the browser and gives the platform one place to cache/normalize daily rates.

## Context (C1)

```mermaid
graph TD
    User[User]
    Webapp[Exchange Rate Webapp]
    API[Exchange Rate API]
    Thunder[Thunder Auth]
    Provider[Exchange Rate Data Provider]

    User -->|signs in, looks up a currency| Webapp
    Webapp -->|REST calls| API
    Webapp -->|OIDC sign-in| Thunder
    API -->|validates tokens| Thunder
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

### Sign-in

```mermaid
sequenceDiagram
    actor User
    participant Webapp as Exchange Rate Webapp
    participant Thunder as Thunder Auth

    User->>Webapp: Open app
    Webapp->>Thunder: Redirect to sign-in (OIDC + PKCE)
    Thunder-->>User: Present login
    User->>Thunder: Submit credentials
    Thunder-->>Webapp: Redirect back with tokens
    Webapp->>Webapp: Store session, show currency picker
```

### Currency rate lookup

```mermaid
sequenceDiagram
    actor User
    participant Webapp as Exchange Rate Webapp
    participant API as Exchange Rate API
    participant Provider as Exchange Rate Data Provider

    User->>Webapp: Select/search currency (e.g. EUR)
    Webapp->>API: GET /currencies/{code}/rate (bearer token)
    API->>API: Validate token
    API->>Provider: Fetch today's rate for code -> USD
    Provider-->>API: Rate + as-of date
    API-->>Webapp: { currencyCode, rateToUsd, asOfDate }
    Webapp-->>User: Show rate and "last updated" timestamp
```