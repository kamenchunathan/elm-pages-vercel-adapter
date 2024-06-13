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
In your elm-pages config provide adapter.default as the adapter because of the way js works

```
// elm-pages.config.mjs
import { defineConfig } from "vite";
import adapter from "vercel-adapter";


export default {
  vite: defineConfig({}),
  adapter: adapter.default,
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is procesed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
};
```
## Contributing
