import { copyFile, cp, mkdir } from "fs/promises";
import { emptyDir, writeJson } from "fs-extra";
import { join } from "path";
import { glob } from "glob";
import { build } from "esbuild";
import { cwd } from "process";

// @ts-ignore
import serverSrc from "./server.ts?raw"
import path = require("path");


// NOTE: These are configurable
// TODO: Add options to read these from environment variables or receive them as config 
//  options from the run function since it is intended to be used as a plugin
const VERCEL_OUTPUT_DIR = join(".vercel", "output");
const ELM_DIST_DIR = "dist";

type AdapterOtpions = {
  renderFunctionFilePath: string,
  routePatterns: RoutePattern[],
  // TODO: Add actual type later when I get to testing this
  apiRoutePatterns: any[]
}


type RoutePattern = {
  kind: "static" | "prerender" | "serverless" | "prerender-with-fallback",
  pathPattern: string
}


export default async function run({ routePatterns, renderFunctionFilePath }: AdapterOtpions) {
  const staticFilesDir = join(VERCEL_OUTPUT_DIR, "static");
  const functionsDir = join(VERCEL_OUTPUT_DIR, "functions");

  await emptyDir(VERCEL_OUTPUT_DIR);
  await mkdir(staticFilesDir);
  await mkdir(functionsDir);

  await writeConfigJson(routePatterns);

  await cp(ELM_DIST_DIR, join(staticFilesDir), { recursive: true });

  // Prerendered and Static Routes
  for (const routePattern of routePatterns) {
    if (routePattern.kind === "static" || routePattern.kind === "prerender" || routePattern.kind == "prerender-with-fallback") {
      await handlePrerenderedRoute(routePattern.pathPattern, ELM_DIST_DIR, staticFilesDir);
    }
  }

  // Serverless Routes
  await createServerlessFunction("ssr_", functionsDir, renderFunctionFilePath);
  await createServerlessFunction("isr_", functionsDir, renderFunctionFilePath);

}




async function handlePrerenderedRoute(pathPattern: string, elmDistDir: string, staticFilesDir: string) {
  console.log('Handle route: ' + pathPattern);
  const prerenderedRoutesGlob = join(elmDistDir + pathPatternToGlob(pathPattern), '{index.html,content.dat}');
  const htmlFiles = await glob(prerenderedRoutesGlob, {});

  for (const file of htmlFiles) {
    const dstDir = join(staticFilesDir, path.dirname(file).substring(elmDistDir.length));
    await mkdir(dstDir, { recursive: true });
    await copyFile(file, join(dstDir, path.basename(file)));
  }
}

function pathPatternToGlob(pathPattern: string) {
  return pathPattern.split("/")
    .map(pathSegment => {
      if (pathSegment.startsWith(":")) {
        return "*"
      }
      else if (pathSegment === "*") {
        return "**"
      }
      else {
        return pathSegment
      }
    }).join("/");
}

async function createServerlessFunction(funcName: string, functionsDir: string, renderFunctionFilePath: string) {
  const funcDir = join(functionsDir, funcName) + ".func";
  await mkdir(funcDir);
  console.log(cwd())
  console.log(funcDir)


  // Function config
  writeJson(path.join(funcDir, '.vc-config.json'), {
    runtime: 'nodejs20.x',
    handler: 'index.js'
  });


  try {

    let buildResult = await build(
      {
        platform: 'node',
        target: 'node20',
        format: "cjs",
        stdin: {
          contents: serverSrc,
          resolveDir: cwd(),
          sourcefile: "server.ts"
        },
        legalComments: "none",
        bundle: true,
        treeShaking: true,
        outfile: join(funcDir, 'index.js'),
        external: [...require('module').builtinModules],
        alias: {
          'render': renderFunctionFilePath
        },
      }
    );
  }
  catch (e) {
    console.warn("If error is a resolution error and you're running with pnpm install your dependencies with `pnpm install --shamefully-hoist`");
    console.error(e)
    throw e;
  }
}

function generateServerlessRoutes(routePatterns: RoutePattern[]) {
  // Filter routes that need server-side handling
  const serverRoutes = routePatterns.filter(route =>
    route.kind === "prerender-with-fallback" ||
    route.kind === "serverless"
  );

  const allRoutes = [];

  for (const route of serverRoutes) {
    const isISR = route.kind === "prerender-with-fallback";
    const destination = isISR ? "/isr_" : "/ssr_";

    const segments = route.pathPattern.substring(1).split("/");
    const regexSegments = segments.map(segment => {
      if (segment.includes(":")) {
        // Dynamic segment: :id becomes (?<id>[^/]*) for ISR or ([^/]*) for serverless
        const paramName = segment.replace(":", "");
        return isISR ? `(?<${paramName}>[^/]*)` : `([^/]*)`;
      } else {
        // Static segment: stays as-is for serverless, becomes named group for ISR
        return isISR ? `(?<${segment}>${segment})` : segment;
      }
    });

    const sourcePattern = `/${regexSegments.join("/")}`;

    // Create main route and content.dat route
    allRoutes.push(
      { src: sourcePattern, dest: destination, check: true },
      {
        src: isISR
          ? `${sourcePattern}/(?<content>content.dat)`
          : `${sourcePattern}/content.dat`,
        dest: destination,
        check: true
      }
    );
  }

  return allRoutes;
}

async function writeConfigJson(routes: RoutePattern[]) {
  const serverlessRoutes = generateServerlessRoutes(routes);

  await writeJson(path.join(VERCEL_OUTPUT_DIR, 'config.json'), {
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
}
