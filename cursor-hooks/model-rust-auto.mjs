#!/usr/bin/env node
/**
 * model-rust auto memory — Cursor hook (Node; reliable stdin on Windows).
 * Usage: node model-rust-auto.mjs <beforeSubmitPrompt|afterAgentResponse|stop>
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const event = process.argv[2] || "";
const workspaceRoot = path.resolve(__dirname, "..", "..");
const stateDir = path.join(__dirname, "state");
const statePath = path.join(stateDir, "model-rust-pending.json");
const logPath = path.join(stateDir, "model-rust-auto.log");
const disablePath = path.join(stateDir, "model-rust-auto.off");
const minChars = 6;
const skillRe = /(^|\s)\/(fix|make|feature|plan|ship|review|note|upgrades)\b/i;
const skipRe =
  /^(ok|okay|thanks|thank you|ยืนยัน|confirm|yes|y|no|n|ได้|ครับ|ค่ะ)\s*$/i;

function out(obj) {
  process.stdout.write(typeof obj === "string" ? obj : JSON.stringify(obj));
}

function ensureState() {
  fs.mkdirSync(stateDir, { recursive: true });
}

function log(msg) {
  ensureState();
  fs.appendFileSync(logPath, `${new Date().toISOString()} ${msg}\n`, "utf8");
}

function sanitize(text, max) {
  if (!text) return "";
  const lines = String(text)
    .split(/\r?\n/)
    .filter(
      (ln) =>
        !/(MONGODB_URI|password\s*=|api[_-]?key|secret\s*=|Bearer\s+\S+)/i.test(
          ln
        )
    );
  let joined = lines.join("\n").trim();
  if (joined.length <= max) return joined;
  return joined.slice(0, Math.max(0, max - 1)) + "…";
}

function readStdin() {
  return new Promise((resolve) => {
    const chunks = [];
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (c) => chunks.push(c));
    process.stdin.on("end", () => resolve(chunks.join("")));
    process.stdin.on("error", () => resolve(""));
    // In case stdin is not piped
    if (process.stdin.isTTY) resolve("");
  });
}

function parseJson(raw) {
  try {
    return raw && raw.trim() ? JSON.parse(raw) : null;
  } catch (e) {
    log(`FAIL json-parse err=${e.message}`);
    return null;
  }
}

function promptText(obj) {
  if (!obj || typeof obj !== "object") return "";
  for (const key of ["prompt", "prompt_text", "text", "message", "content"]) {
    if (obj[key] != null && String(obj[key]).trim()) return String(obj[key]);
  }
  return "";
}

function shouldStage(prompt) {
  const p = prompt.trim();
  if (p.length < minChars) return false;
  if (skipRe.test(p)) return false;
  return true;
}

function skillTag(prompt) {
  const m = prompt.match(skillRe);
  return m ? m[2].toLowerCase() : "chat";
}

function resolveBin() {
  const candidates = [
    path.join(
      workspaceRoot,
      "agent-skills",
      "model-rust",
      "target",
      "release",
      "model-rust.exe"
    ),
    path.join(
      workspaceRoot,
      "agent-skills",
      "model-rust",
      "target",
      "debug",
      "model-rust.exe"
    ),
    path.join(workspaceRoot, "model-rust", "target", "release", "model-rust.exe"),
    path.join(workspaceRoot, "model-rust", "target", "debug", "model-rust.exe"),
    path.join(
      workspaceRoot,
      "agent-skills",
      "model-rust",
      "target",
      "release",
      "model-rust"
    ),
    path.join(
      workspaceRoot,
      "agent-skills",
      "model-rust",
      "target",
      "debug",
      "model-rust"
    ),
    path.join(workspaceRoot, "model-rust", "target", "release", "model-rust"),
    path.join(workspaceRoot, "model-rust", "target", "debug", "model-rust"),
  ];
  return candidates.find((p) => fs.existsSync(p)) || null;
}

function readState() {
  try {
    if (!fs.existsSync(statePath)) return null;
    return JSON.parse(fs.readFileSync(statePath, "utf8"));
  } catch {
    return null;
  }
}

function writeState(obj) {
  ensureState();
  fs.writeFileSync(statePath, JSON.stringify(obj), "utf8");
}

function clearState() {
  try {
    fs.unlinkSync(statePath);
  } catch {
    /* ignore */
  }
}

const raw = await readStdin();
log(`STDIN bytes=${raw.length} event=${event}`);

if (fs.existsSync(disablePath) || process.env.MODEL_RUST_AUTO === "0") {
  log(`SKIP disabled event=${event}`);
  out(event === "beforeSubmitPrompt" ? { continue: true } : {});
  process.exit(0);
}

const data = parseJson(raw);

if (event === "beforeSubmitPrompt") {
  const prompt = promptText(data);
  log(`IN beforeSubmitPrompt chars=${prompt.trim().length} hasJson=${!!data}`);
  if (shouldStage(prompt)) {
    const skill = skillTag(prompt);
    writeState({
      prompt: sanitize(prompt, 2000),
      skill,
      response: "",
      createdAtIso: new Date().toISOString(),
      saved: false,
    });
    log(`STAGE skill=${skill} chars=${prompt.trim().length}`);
  } else {
    clearState();
    log("SKIP short/ack prompt");
  }
  out({ continue: true });
  process.exit(0);
}

if (event === "afterAgentResponse") {
  const text = data && data.text != null ? String(data.text) : "";
  const state = readState();
  if (state && !state.saved) {
    state.response = sanitize(text, 2000);
    writeState(state);
    log(`RESP chars=${text.length}`);
  }
  out({});
  process.exit(0);
}

if (event === "stop") {
  const status = data && data.status != null ? String(data.status) : "completed";
  const loopCount =
    data && data.loop_count != null ? Number(data.loop_count) : 0;
  if (status !== "completed" || loopCount > 0) {
    log(`SKIP stop status=${status} loop=${loopCount}`);
    out({});
    process.exit(0);
  }
  const state = readState();
  if (!state || state.saved || !String(state.prompt || "").trim()) {
    log("SKIP stop no-pending");
    out({});
    process.exit(0);
  }
  const bin = resolveBin();
  if (!bin) {
    log("FAIL no-binary");
    out({});
    process.exit(0);
  }
  const skill = String(state.skill || "chat") || "chat";
  const prompt = String(state.prompt || "");
  const resp = String(state.response || "");
  const stub = {
    prompt,
    problem: sanitize(prompt, 500) || `agent turn: /${skill}`,
    solutionSummary: sanitize(resp, 200) || `agent completed /${skill}`,
    body: sanitize(resp, 2000),
    tags: [skill, "auto"],
    project: "skills",
    source: "chat",
    title: `/${skill} auto`,
  };
  const tmp = path.join(stateDir, "model-rust-auto-add.json");
  fs.writeFileSync(tmp, JSON.stringify(stub), "utf8");
  try {
    const r = spawnSync(bin, ["add", "--json", tmp], {
      encoding: "utf8",
      windowsHide: true,
    });
    if (r.status === 0) {
      clearState();
      log(`SAVED ok out=${(r.stdout || "").trim()}`);
    } else {
      log(
        `FAIL add exit=${r.status} out=${((r.stderr || r.stdout) || "").trim()}`
      );
    }
  } catch (e) {
    log(`FAIL add exception=${e.message}`);
  } finally {
    try {
      fs.unlinkSync(tmp);
    } catch {
      /* ignore */
    }
  }
  out({});
  process.exit(0);
}

out({});
process.exit(0);
