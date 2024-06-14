type AdapterOtpions = {
    renderFunctionFilePath: string;
    routePatterns: RoutePattern[];
    apiRoutePatterns: any[];
};
type RoutePattern = {
    kind: "static" | "prerender" | "serverless" | "prerender-with-fallback";
    pathPattern: string;
};
declare function run({ routePatterns, renderFunctionFilePath }: AdapterOtpions): Promise<void>;

export { run as default };
