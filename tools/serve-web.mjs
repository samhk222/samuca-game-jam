import { createReadStream, existsSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { createServer as createHttpsServer } from "node:https";
import { extname, join, normalize, relative, resolve } from "node:path";
import { provisionTls } from "./tailscale-tls.mjs";

const root = resolve(process.argv[2] ?? "build/web");
const port = Number(process.argv[3] ?? "7777");
const httpOnly = process.env.HTTP_ONLY === "1";
const host = process.argv[4] ?? (httpOnly ? "127.0.0.1" : "0.0.0.0");
const mimeTypes = {
	".css": "text/css; charset=utf-8",
	".html": "text/html; charset=utf-8",
	".js": "text/javascript; charset=utf-8",
	".json": "application/json; charset=utf-8",
	".pck": "application/octet-stream",
	".png": "image/png",
	".svg": "image/svg+xml",
	".wasm": "application/wasm",
};

if (!Number.isInteger(port) || port < 1 || port > 65535) {
	throw new Error(`Invalid port: ${process.argv[3]}`);
}

const handler = (request, response) => {
	const pathname = decodeURIComponent(new URL(request.url ?? "/", "http://localhost").pathname);
	const requestedPath = pathname === "/" ? "index.html" : pathname.slice(1);
	const filePath = normalize(join(root, requestedPath));

	if (relative(root, filePath).startsWith("..") || !existsSync(filePath) || !statSync(filePath).isFile()) {
		response.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
		response.end("Not found\n");
		return;
	}

	response.writeHead(200, {
		"Cache-Control": "no-cache",
		"Content-Type": mimeTypes[extname(filePath)] ?? "application/octet-stream",
	});
	createReadStream(filePath).pipe(response);
};

const tls = httpOnly ? null : await provisionTls();
const server = tls ? createHttpsServer(tls.credentials, handler) : createServer(handler);
if (tls) {
	const renewal = setInterval(async () => {
		server.setSecureContext(await tls.renew());
		console.log("HTTPS certificate refreshed.");
	}, 12 * 60 * 60 * 1000);
	renewal.unref();
	server.on("close", () => clearInterval(renewal));
}
server.listen(port, host, () => {
	console.log(`Serving ${root} on ${host}:${port}`);
	console.log(tls
		? `Play: https://${tls.hostname}:${port} (direct HTTPS; no Tailscale Serve)`
		: `Local only: http://127.0.0.1:${port} (remote Godot play requires HTTPS)`);
});
