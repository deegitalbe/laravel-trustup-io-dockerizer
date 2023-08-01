/// <reference types="vitest" />
import { loadEnv, defineConfig } from "vite";
import eslint from "vite-plugin-eslint";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  process.env = { ...process.env, ...loadEnv(mode, process.cwd()) };

  return {
    plugins: [eslint()],
    server: {
      host: true,
      port: parseInt(process.env.VITE_PORT || "3000"), // This is the port which we will use in docker
    },
    test: {
      browser: {
        enabled: true,
        name: "chrome",
      },
    },
  };
});
