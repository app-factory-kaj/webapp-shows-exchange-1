type Env = {
  EXCHANGE_API_URL: string;
};

declare global {
  interface Window {
    _env_: Env;
  }
}

if (!window._env_) {
  throw new Error(
    "window._env_ not set — /env-config.js failed to load. " +
      "The platform mounts this file; if you see this locally, host " +
      "/env-config.js from your dev server.",
  );
}

if (!window._env_.EXCHANGE_API_URL) {
  throw new Error("EXCHANGE_API_URL not set in window._env_");
}

export const env: Env = window._env_;
