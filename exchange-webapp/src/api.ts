import createClient from "openapi-fetch";
import type { paths } from "./generated/exchange-api";
import { env } from "./env";

const BASE_URL = env.EXCHANGE_API_URL;
if (!BASE_URL) {
  throw new Error("EXCHANGE_API_URL not set in window._env_");
}

export const exchangeApi = createClient<paths>({ baseUrl: BASE_URL });
