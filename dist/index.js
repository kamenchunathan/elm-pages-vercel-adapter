'use strict';

var promises = require('fs/promises');
var fsExtra = require('fs-extra');
var path$1 = require('path');
var glob = require('glob');
var esbuild = require('esbuild');
var process = require('process');

var __require = /* @__PURE__ */ ((x) => typeof require !== "undefined" ? require : typeof Proxy !== "undefined" ? new Proxy(x, {
  get: (a, b) => (typeof require !== "undefined" ? require : a)[b]
}) : x)(function(x) {
  if (typeof require !== "undefined") return require.apply(this, arguments);
  throw Error('Dynamic require of "' + x + '" is not supported');
});
var __async = (__this, __arguments, generator) => {
  return new Promise((resolve, reject) => {
    var fulfilled = (value) => {
      try {
        step(generator.next(value));
      } catch (e) {
        reject(e);
      }
    };
    var rejected = (value) => {
      try {
        step(generator.throw(value));
      } catch (e) {
        reject(e);
      }
    };
    var step = (x) => x.done ? resolve(x.value) : Promise.resolve(x.value).then(fulfilled, rejected);
    step((generator = generator.apply(__this, __arguments)).next());
  });
};

// raw-loader:./server.ts?raw
var server_default = '// @ts-ignore\nimport { render } from "render";\n\nexport default async function(req, res) {\n\n  try {\n    const elmResponse = await render(reqToJson(req));\n    for (const [key, value] of Object.entries(elmResponse.headers)) {\n      res.setHeader(key, value);\n    }\n\n    if (elmResponse.kind === "bytes") {\n      res.setHeader("Content-Type", "application/octet-stream");\n      res.setHeader("x-powered-by", "elm-pages");\n      res.status(elmResponse.statusCode).end(Buffer.from(elmResponse.body));\n    } else if (elmResponse.kind === "api-response") {\n      res.status(elmResponse.statusCode).end(elmResponse.body);\n    } else {\n      res.setHeader("Content-Type", "text/html");\n      res.setHeader("x-powered-by", "elm-pages");\n      res.statusCode = elmResponse.statusCode;\n      res.end(elmResponse.body);\n    }\n  } catch (error) {\n    console.error(error);\n    res.status(500).setHeader("Content-Type", "text/html").end(`<body><h1>Error</h1><pre>${JSON.stringify(error, null, 2)}</pre></body>`);\n  }\n\n}\n\nfunction reqToJson(req) {\n  console.log(req);\n  const protocol = req.headers[\'x-forwarded-proto\'] || req.protocol || \'http\';\n  const host = req.headers[\'x-forwarded-host\'] || req.headers.host || \'localhost:3000\';\n  const absoluteUrl = `${protocol}://${host}${req.url}`;\n\n  return {\n    requestTime: Math.round(new Date().getTime()),\n    method: req.method,\n    headers: req.headers,\n    rawUrl: absoluteUrl,\n    body: req.body || null,\n    multiPartFormData: null,\n  };\n}\n\n\n\n';

// src/index.ts
var path = __require("path");
var VERCEL_OUTPUT_DIR = path$1.join(".vercel", "output");
var ELM_DIST_DIR = "dist";
function run(_0) {
  return __async(this, arguments, function* ({ routePatterns, renderFunctionFilePath }) {
    const staticFilesDir = path$1.join(VERCEL_OUTPUT_DIR, "static");
    const functionsDir = path$1.join(VERCEL_OUTPUT_DIR, "functions");
    yield fsExtra.emptyDir(VERCEL_OUTPUT_DIR);
    yield promises.mkdir(staticFilesDir);
    yield promises.mkdir(functionsDir);
    yield writeConfigJson(routePatterns);
    yield promises.cp(ELM_DIST_DIR, path$1.join(staticFilesDir), { recursive: true });
    for (const routePattern of routePatterns) {
      if (routePattern.kind === "static" || routePattern.kind === "prerender" || routePattern.kind == "prerender-with-fallback") {
        yield handlePrerenderedRoute(routePattern.pathPattern, ELM_DIST_DIR, staticFilesDir);
      }
    }
    yield createServerlessFunction("ssr_", functionsDir, renderFunctionFilePath);
    yield createServerlessFunction("isr_", functionsDir, renderFunctionFilePath);
  });
}
function handlePrerenderedRoute(pathPattern, elmDistDir, staticFilesDir) {
  return __async(this, null, function* () {
    console.log("Handle route: " + pathPattern);
    const prerenderedRoutesGlob = path$1.join(elmDistDir + pathPatternToGlob(pathPattern), "{index.html,content.dat}");
    const htmlFiles = yield glob.glob(prerenderedRoutesGlob, {});
    for (const file of htmlFiles) {
      const dstDir = path$1.join(staticFilesDir, path.dirname(file).substring(elmDistDir.length));
      yield promises.mkdir(dstDir, { recursive: true });
      yield promises.copyFile(file, path$1.join(dstDir, path.basename(file)));
    }
  });
}
function pathPatternToGlob(pathPattern) {
  return pathPattern.split("/").map((pathSegment) => {
    if (pathSegment.startsWith(":")) {
      return "*";
    } else if (pathSegment === "*") {
      return "**";
    } else {
      return pathSegment;
    }
  }).join("/");
}
function createServerlessFunction(funcName, functionsDir, renderFunctionFilePath) {
  return __async(this, null, function* () {
    const funcDir = path$1.join(functionsDir, funcName) + ".func";
    yield promises.mkdir(funcDir);
    console.log(process.cwd());
    console.log(funcDir);
    fsExtra.writeJson(path.join(funcDir, ".vc-config.json"), {
      runtime: "nodejs20.x",
      handler: "index.js"
    });
    try {
      let buildResult = yield esbuild.build(
        {
          platform: "node",
          target: "node20",
          format: "cjs",
          stdin: {
            contents: server_default,
            resolveDir: process.cwd(),
            sourcefile: "server.ts"
          },
          legalComments: "none",
          bundle: true,
          treeShaking: true,
          outfile: path$1.join(funcDir, "index.js"),
          external: [...__require("module").builtinModules],
          alias: {
            "render": renderFunctionFilePath
          }
        }
      );
    } catch (e) {
      console.warn("If error is a resolution error and you're running with pnpm install your dependencies with `pnpm install --shamefully-hoist`");
      console.error(e);
      throw e;
    }
  });
}
function generateServerlessRoutes(routePatterns) {
  const serverRoutes = routePatterns.filter(
    (route) => route.kind === "prerender-with-fallback" || route.kind === "serverless"
  );
  const allRoutes = [];
  for (const route of serverRoutes) {
    const isISR = route.kind === "prerender-with-fallback";
    const destination = isISR ? "/isr_" : "/ssr_";
    const segments = route.pathPattern.substring(1).split("/");
    const regexSegments = segments.map((segment) => {
      if (segment.includes(":")) {
        const paramName = segment.replace(":", "");
        return isISR ? `(?<${paramName}>[^/]*)` : `([^/]*)`;
      } else {
        return isISR ? `(?<${segment}>${segment})` : segment;
      }
    });
    const sourcePattern = `/${regexSegments.join("/")}`;
    allRoutes.push(
      { src: sourcePattern, dest: destination, check: true },
      {
        src: isISR ? `${sourcePattern}/(?<content>content.dat)` : `${sourcePattern}/content.dat`,
        dest: destination,
        check: true
      }
    );
  }
  return allRoutes;
}
function writeConfigJson(routes) {
  return __async(this, null, function* () {
    const serverlessRoutes = generateServerlessRoutes(routes);
    yield fsExtra.writeJson(path.join(VERCEL_OUTPUT_DIR, "config.json"), {
      version: 3,
      routes: [
        { handle: "filesystem" },
        {
          src: "^/([^/]+(?:/[^/]+)*)/?$",
          dest: "/$1/index.html"
        },
        ...serverlessRoutes
      ]
    });
  });
}

module.exports = run;
