// @ts-ignore
import { render } from "render";

export default async function(req, res) {

  try {
    const elmResponse = await render(reqToJson(req));
    for (const [key, value] of Object.entries(elmResponse.headers)) {
      res.setHeader(key, value);
    }

    if (elmResponse.kind === "bytes") {
      res.setHeader("Content-Type", "application/octet-stream");
      res.setHeader("x-powered-by", "elm-pages");
      res.status(elmResponse.statusCode).end(Buffer.from(elmResponse.body));
    } else if (elmResponse.kind === "api-response") {
      res.status(elmResponse.statusCode).end(elmResponse.body);
    } else {
      res.setHeader("Content-Type", "text/html");
      res.setHeader("x-powered-by", "elm-pages");
      res.statusCode = elmResponse.statusCode;
      res.end(elmResponse.body);
    }
  } catch (error) {
    console.error(error);
    res.status(500).setHeader("Content-Type", "text/html").end(`<body><h1>Error</h1><pre>${JSON.stringify(error, null, 2)}</pre></body>`);
  }

}

function reqToJson(req) {
  console.log(req);
  const protocol = req.headers['x-forwarded-proto'] || req.protocol || 'http';
  const host = req.headers['x-forwarded-host'] || req.headers.host || 'localhost:3000';
  const absoluteUrl = `${protocol}://${host}${req.url}`;

  return {
    requestTime: Math.round(new Date().getTime()),
    method: req.method,
    headers: req.headers,
    rawUrl: absoluteUrl,
    body: req.body || null,
    multiPartFormData: null,
  };
}



