"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const promises_1 = require("fs/promises");
const fs_extra_1 = require("fs-extra");
const path_1 = require("path");
const glob_1 = require("glob");
// NOTE: These are configurable
// TODO: Add options to read these from environment variables or receive them as config 
//  options from the run function since it is intended to be used as a plugin
const VERCEL_OUTPUT_DIR = (0, path_1.join)(".vercel", "output");
const ELM_DIST_DIR = "dist";
async function run({ routePatterns }) {
    const staticFilesDir = (0, path_1.join)(VERCEL_OUTPUT_DIR, "static");
    const functionsDir = (0, path_1.join)(VERCEL_OUTPUT_DIR, "functions");
    await (0, fs_extra_1.emptyDir)(VERCEL_OUTPUT_DIR);
    await (0, promises_1.mkdir)(staticFilesDir);
    await (0, promises_1.mkdir)(functionsDir);
    // Copy static assets
    // These are not dependent on route and are contained in the assets directory plus an elm.js
    // and elm-[some hash].js 
    // TODO: Copy the elm scripts to the static files directory
    await (0, promises_1.cp)((0, path_1.join)(ELM_DIST_DIR, "assets"), (0, path_1.join)(staticFilesDir, "assets"), { recursive: true });
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
exports.default = run;
async function handlePrerenderedRoute(pathPattern, elmDistDir, staticFilesDir) {
    console.log('Handle route: ' + pathPattern);
    const prerenderedRoutesGlob = (0, path_1.join)(elmDistDir + pathPatternToGlob(pathPattern), 'index.html');
    const htmlFiles = await (0, glob_1.glob)(prerenderedRoutesGlob, {});
    for (const file of htmlFiles) {
        // NOTE: Magic number 10 is the length of the string '/index.html'
        const folder = file.substring(elmDistDir.length, file.length - 10);
        const dstDir = (0, path_1.join)(staticFilesDir, folder);
        await (0, promises_1.mkdir)(dstDir, { recursive: true });
        await (0, promises_1.copyFile)(file, (0, path_1.join)(dstDir, 'index.html'));
    }
}
function pathPatternToGlob(pathPattern) {
    return pathPattern.split("/")
        .map(pathSegment => {
        if (pathSegment.startsWith(":")) {
            return "*";
        }
        else if (pathSegment === "*") {
            return "**";
        }
        else {
            return pathSegment;
        }
    }).join("/");
}
async function createServerlessFunction(funcName, functionsDir) {
    const funcDir = (0, path_1.join)(functionsDir, funcName) + ".func";
    await (0, promises_1.mkdir)(funcDir);
}
