#!/usr/bin/env node
const { spawn } = require("child_process");
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.MCP_PORT || 37184;

let API_KEY = process.env.GETNOTE_API_KEY;
let CLIENT_ID = process.env.GETNOTE_CLIENT_ID;

if (!API_KEY || !CLIENT_ID) {
  const paths = [
    path.join(__dirname, "credentials.json"),
    path.join(__dirname, "..", "config", "credentials.json"),
  ];
  for (const p of paths) {
    if (fs.existsSync(p)) {
      const c = JSON.parse(fs.readFileSync(p, "utf-8"));
      API_KEY = API_KEY || c.api_key;
      CLIENT_ID = CLIENT_ID || c.client_id;
      console.log(`[bridge] 凭证: ${p}`);
      break;
    }
  }
}

const child = spawn("npx", ["@getnote/mcp", "--api-key", API_KEY, "--client-id", CLIENT_ID], {
  stdio: ["pipe", "pipe", "pipe"],
  env: { ...process.env, GETNOTE_API_KEY: API_KEY, GETNOTE_CLIENT_ID: CLIENT_ID },
  shell: true,
});

child.stderr.on("data", (d) => {
  const m = d.toString().trim();
  if (m && !m.includes("npm notice")) console.log(`[mcp] ${m}`);
});
child.on("exit", (c) => { console.log(`[bridge] mcp exit code=${c}`); process.exit(c || 0); });

const pending = new Map();
const sseClients = new Set();
let buf = "";

child.stdout.on("data", (data) => {
  buf += data.toString();
  const lines = buf.split("\n");
  buf = lines.pop();
  for (const line of lines) {
    const t = line.trim();
    if (!t) continue;
    try {
      const msg = JSON.parse(t);
      if (msg.id !== undefined && pending.has(msg.id)) {
        pending.get(msg.id).resolve(msg);
        pending.delete(msg.id);
      } else if (msg.id === undefined) {
        for (const res of sseClients) res.write(`data: ${JSON.stringify(msg)}\n\n`);
      }
    } catch (e) { /* skip */ }
  }
});

function send(req) {
  return new Promise((resolve, reject) => {
    const id = req.id || Date.now() + Math.random();
    req.id = id;
    pending.set(id, { resolve, reject });
    child.stdin.write(JSON.stringify(req) + "\n");
    setTimeout(() => { if (pending.has(id)) { pending.delete(id); reject(new Error("timeout")); } }, 30000);
  });
}

const server = http.createServer(async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Accept");
  if (req.method === "OPTIONS") { res.writeHead(204); res.end(); return; }

  if (req.url === "/health" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", mcp_connected: true }));
    return;
  }

  if (req.url === "/mcp" && req.method === "GET") {
    res.writeHead(200, { "Content-Type": "text/event-stream", "Cache-Control": "no-cache", Connection: "keep-alive" });
    res.write(": connected\n\n");
    sseClients.add(res);
    req.on("close", () => sseClients.delete(res));
    return;
  }

  if (req.url === "/mcp" && req.method === "POST") {
    let body = "";
    req.on("data", (c) => body += c);
    req.on("end", async () => {
      try {
        const response = await send(JSON.parse(body));
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(response));
      } catch (e) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: e.message }));
      }
    });
    return;
  }
  res.writeHead(404); res.end("Not Found");
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`[bridge] 已启动 http://127.0.0.1:${PORT}/mcp`);
  console.log(`[bridge] 健康检查 http://127.0.0.1:${PORT}/health`);
});

process.on("SIGINT", () => { child.kill(); server.close(); process.exit(0); });
