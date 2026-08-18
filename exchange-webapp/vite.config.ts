import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// No `base` — this app is served at its own gateway hostname's root.
export default defineConfig({
  plugins: [react()],
});
