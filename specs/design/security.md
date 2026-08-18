# Exchange Rate Lookup — Security Design

## Roles → permissions

There is a single actor, **User**, per the PRD — no admin or elevated role exists in this phase, and every visitor has identical access.

## Authentication (Thunder)

- **No sign-in: `exchange-webapp` and `exchange-api`** — this design deliberately overrides the organization's default of signing every web app's users in via SSO through Thunder. Story 1 explicitly calls for opening the app without creating an account or signing in, so this is a stated product decision, not an omission.
- Neither component declares a `thunder-app` dependency, and neither expects any bearer token or identity header on requests.
- `exchange-api` is called only by `exchange-webapp` and is not otherwise exposed to the internet; it performs no authentication or authorization of its own.

## Role resolution

- Not applicable — there is no caller identity to resolve. Every request to `exchange-api` is treated identically, and every visitor to `exchange-webapp` sees the same screens with no login gate.