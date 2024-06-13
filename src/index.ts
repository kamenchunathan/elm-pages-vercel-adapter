import { copyFile, cp, mkdir } from "fs/promises";
import { emptyDir } from "fs-extra";
import { join } from "path";
import { glob } from "glob";


// NOTE: These are configurable
// TODO: Add options to read these from environment variables or receive them as config 
//  options from the run function since it is intended to be used as a plugin
const VERCEL_OUTPUT_DIR = join(".vercel", "output");
const ELM_DIST_DIR = "dist";


export default async function run(
  { routePatterns }: {
    routePatterns: {
      kind: "static" | "prerender" | "serverless",
      pathPattern: string
    }[],
  }
) {
  const staticFilesDir = join(VERCEL_OUTPUT_DIR, "static");
  const functionsDir = join(VERCEL_OUTPUT_DIR, "functions");

  await emptyDir(VERCEL_OUTPUT_DIR);
  await mkdir(staticFilesDir);
  await mkdir(functionsDir);

  // Copy static assets
  // These are not dependent on route and are contained in the assets directory plus an elm.js
  // and elm-[some hash].js 
  // TODO: Copy the elm scripts to the static files directory
  await cp(join(ELM_DIST_DIR, "assets"), join(staticFilesDir, "assets"), { recursive: true });

  // Prerendered and Static Routes
  for (const routePattern of routePatterns) {
    if (routePattern.kind === "static" || routePattern.kind === "prerender") {
      await handlePrerenderedRoute(routePattern.pathPattern, ELM_DIST_DIR, staticFilesDir);
    }
  }

  // Serverless Routes
  await createServerlessFunction("ssr_", functionsDir);
  await createServerlessFunction("isr_", functionsDir);

}


async function handlePrerenderedRoute(pathPattern: string, elmDistDir: string, staticFilesDir: string) {
  console.log('Handle route: ' + pathPattern);
  const prerenderedRoutesGlob = join(elmDistDir + pathPatternToGlob(pathPattern), 'index.html');
  const htmlFiles = await glob(prerenderedRoutesGlob, {});

  for (const file of htmlFiles) {
    // NOTE: Magic number 10 is the length of the string '/index.html'
    const folder = file.substring(elmDistDir.length, file.length - 10);
    const dstDir = join(staticFilesDir, folder);
    await mkdir(dstDir, { recursive: true });
    await copyFile(file, join(dstDir, 'index.html'));
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

async function createServerlessFunction(funcName: string, functionsDir: string) {
  const funcDir = join(functionsDir, funcName) + ".func";
  await mkdir(funcDir);
}
