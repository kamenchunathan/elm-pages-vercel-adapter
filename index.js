import { copyFile, cp, mkdir } from "fs/promises";
import { emptyDir } from "fs-extra";
import { join } from "path";
import { glob } from "glob";

const VERCEL_OUTPUT_DIR = join(".vercel", "output");
const ELM_DIST_DIR = "dist";


export default async function run({ routePatterns }) {
  const staticFilesDir = join(VERCEL_OUTPUT_DIR, "static");
  const functionsDir = join(VERCEL_OUTPUT_DIR, "functions");

  await emptyDir(VERCEL_OUTPUT_DIR);
  await mkdir(staticFilesDir);
  await mkdir(functionsDir);

  await cp(join(ELM_DIST_DIR, "assets"), join(staticFilesDir, "assets"), { recursive: true });

  for (const routePattern of routePatterns) {
    if (routePattern.kind === "static") {
      await handlePrerenderedRoute(routePattern.pathPattern, ELM_DIST_DIR, staticFilesDir);
    } else if (routePattern.kind === "prerender") {
      await handlePrerenderedRoute(routePattern.pathPattern, ELM_DIST_DIR, staticFilesDir);
    } else if (routePattern.kind === "serverless") {
      await createServerlessFunction(routePattern.pathPattern, functionsDir);
    }
  }
}


async function handlePrerenderedRoute(pathPattern, elmDistDir, staticFilesDir) {
  const prerenderedRoutesGlob = `${elmDistDir}${pathPatternToGlob(pathPattern)}/index.html`;
  const htmlFiles = await glob(prerenderedRoutesGlob, {});

  for (const file of htmlFiles) {
    // NOTE: Magic number 10 is the length of the string '/index.html'
    const folder = file.substring(elmDistDir.length, file.length - 10);
    const dstDir = `${staticFilesDir}/${folder}`;
    await mkdir(dstDir, { recursive: true });
    await copyFile(file, `${dstDir}/index.html`);
  }
}

export function pathPatternToGlob(pathPattern) {
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

async function createServerlessFunction(funcName, functionsDir) {
  const funcDir = join(functionsDir, funcName) + ".func";
}
