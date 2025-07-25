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
var server_default = '// @ts-ignore\nimport * as render from "render";\n\nexport default function(request, response) {\n  console.debug("query", request.query);\n  console.debug("url", request.url);\n  console.debug("headers", request.headers);\n  console.debug(render);\n\n  const { name = \'friend\' } = request.query\n\n  const body =\n    `Howdy ${name}, from Vercel!\\n` +\n    `Node.js: ${process.version}\\n` +\n    `Request URL: ${request.url}\\n` +\n    `Server time: ${new Date().toISOString()})`\n\n  response.setHeader(\'Content-Type\', \'text/plain\')\n  response.end(body)\n}\n';

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
    yield writeConfigJson();
    yield promises.cp(path$1.join(ELM_DIST_DIR, "assets"), path$1.join(staticFilesDir, "assets"), { recursive: true });
    for (const routePattern of routePatterns) {
      if (routePattern.kind === "static" || routePattern.kind === "prerender") {
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
    const prerenderedRoutesGlob = path$1.join(elmDistDir + pathPatternToGlob(pathPattern), "index.html");
    const htmlFiles = yield glob.glob(prerenderedRoutesGlob, {});
    for (const file of htmlFiles) {
      const folder = file.substring(elmDistDir.length, file.length - 10);
      const dstDir = path$1.join(staticFilesDir, folder);
      yield promises.mkdir(dstDir, { recursive: true });
      yield promises.copyFile(file, path$1.join(dstDir, "index.html"));
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
      handler: "index.mjs"
    });
    try {
      let buildResult = yield esbuild.build(
        {
          platform: "node",
          target: "node16",
          format: "esm",
          stdin: {
            contents: server_default,
            resolveDir: process.cwd(),
            sourcefile: "server.ts"
          },
          legalComments: "none",
          bundle: true,
          treeShaking: true,
          outfile: path$1.join(funcDir, "index.mjs"),
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
function writeConfigJson(_routes) {
  return __async(this, null, function* () {
    yield promises.writeFile(path.join(VERCEL_OUTPUT_DIR, "config.json"), JSON.stringify({
      version: 3
    }));
  });
}

module.exports = run;
