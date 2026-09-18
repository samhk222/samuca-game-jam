import { execFile } from "node:child_process";
import { chmod, mkdir, readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const run = promisify(execFile);
const directory = fileURLToPath(new URL("../.tools/tls/", import.meta.url));

export async function provisionTls() {
	const { stdout } = await run("tailscale", ["status", "--json"], { timeout: 15000 });
	const status = JSON.parse(stdout);
	const hostname = status.Self?.DNSName?.replace(/\.$/, "");
	if (status.BackendState !== "Running" || !hostname) {
		throw new Error("Tailscale must be signed in and running to obtain an HTTPS certificate.");
	}

	await mkdir(directory, { recursive: true, mode: 0o700 });
	await chmod(directory, 0o700);
	const certFile = `${directory}${hostname}.crt`;
	const keyFile = `${directory}${hostname}.key`;

	async function renew() {
		// Tailscale reuses a valid certificate or renews it; keys never leave .tools/.
		await run("tailscale", [
			"cert", "--min-validity=24h",
			`--cert-file=${certFile}`, `--key-file=${keyFile}`, hostname,
		], { timeout: 120000 });
		await chmod(keyFile, 0o600);
		const [cert, key] = await Promise.all([readFile(certFile), readFile(keyFile)]);
		return { cert, key };
	}

	console.log(`Obtaining HTTPS certificate for ${hostname} (requires tailnet HTTPS certificates).`);
	return { hostname, credentials: await renew(), renew };
}
