import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/lib/index.ts"],
  format: ["cjs", "esm"],
  dts: true,
  clean: true,
  splitting: true,
  shims: true,
  minify: true,
  sourcemap: true,
});
