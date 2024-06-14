// @ts-ignore
import * as render from "render";

export default function(request, response) {
  console.debug("query", request.query);
  console.debug("url", request.url);
  console.debug("headers", request.headers);
  console.debug(render);

  const { name = 'friend' } = request.query

  const body =
    `Howdy ${name}, from Vercel!\n` +
    `Node.js: ${process.version}\n` +
    `Request URL: ${request.url}\n` +
    `Server time: ${new Date().toISOString()})`

  response.setHeader('Content-Type', 'text/plain')
  response.end(body)
}
