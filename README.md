# Elm Pages Vercel Adapter
A vercel adapter for the elm pages 


## Roadmap
- [x] Prerendered routes
- [ ] Server rendered routes
- [ ] Prerender with fallback
- [ ] Api Routes

### Todo
- [ ] Copy other assets to the root of the static dir e.g. 'elm.js'
- [ ] Convert to a typescript project and figure out how to build it for js projects


## Usage
In your elm pages config
```js
// elm-pages.config.mjs
import { defineConfig } from "vite";
import adapter from "vercel-adapter";

export default {
  vite: defineConfig({}),
  adapter
};
```
## Known Issues
When running with `pnpm` Install dependencies with `pnpm install --shamefully-hoist` to make all dependencies available to the esbuid program. 
If you get resolution issues check that this may be the issue

## Contributing

