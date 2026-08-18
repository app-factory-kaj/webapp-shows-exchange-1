# Exchange Rate Lookup — Security Design

## Roles → permissions

There is a single actor (User) per the PRD — no admin or elevated role exists in this phase. Every signed-in user has identical access; there is no per-user data segmentation.

## Authentication (Thunder)

- Shared dependency name: `thunder-app`, declared on BOTH `exchange-webapp` and `exchange-api`.
- Scopes: `openid profile email` (default).
- `exchange-webapp` performs OIDC + PKCE sign-in against Thunder and attaches the resulting bearer token to every call to `exchange-api`.
- `exchange-api` sits behind the gateway, which validates the token and injects identity headers before the request reaches the service.
- No component is publicly reachable without sign-in: the webapp requires a signed-in session before it shows the currency picker; the API requires a valid bearer token on every operation.

## Role resolution

- `exchange-api` treats any caller with a valid Thunder-issued token as a `User` — there is no additional claim-based role mapping since the product defines only one role.
- A request with no token, or a token that fails validation, is rejected with `401 Unauthorized` (deny by default).