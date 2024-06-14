import { defineConfig } from 'tsup';
import RawPlugin from 'esbuild-plugin-raw';

export default defineConfig({
  esbuildPlugins: [RawPlugin()],
  treeshake: true
});
