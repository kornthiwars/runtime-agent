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
  const secretLine =
    /(MONGODB_URI|password\s*=|api[_-]?key|secret\s*=|Bearer\s+\S+)/i;
  // user:pass@host URIs even without MONGODB_URI= prefix
  const credUri =
    /\b(?:mongodb(?:\+srv)?|postgres(?:ql)?|mysql|mariadb|redis|amqp|https?):\/\/[^\s/"']+:[^\s/"']+@[^\s]+/gi;
  const lines = String(text)
    .split(/\r?\n/)
    .filter((ln) => !secretLine.test(ln))
    .map((ln) => ln.replace(credUri, "[REDACTED_URI]"));
  let joined = lines.join("\n").trim();
  if (joined.length <= max) return joined;
  return joined.slice(0, Math.max(0, max - 1)) + "…";
}

function stripBom(s) {
  let t = String(s || "");
  // UTF-8 BOM / ZWNBSP / mis-decoded leading junk before JSON
  t = t.replace(/^\uFEFF/, "").replace(/^﻿/, "");
  const i = t.search(/[\[{]/);
  if (i > 0) t = t.slice(i);
  return t.trim();
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
    const cleaned = stripBom(raw);
    return cleaned ? JSON.parse(cleaned) : null;
  } catch (e) {
    log(`FAIL json-parse err=${e.message}`);
    return null;
  }
}

function promptText(obj) {
  if (!obj || typeof obj !== "object") return "";
  for (const key of [
    "prompt",
    "prompt_text",
    "text",
    "message",
    "content",
    "query",
    "input",
    "user_prompt",
  ]) {
    if (obj[key] != null && String(obj[key]).trim()) return String(obj[key]);
  }
  // Nested shapes Cursor may send
  for (const nest of ["data", "payload", "request", "message"]) {
    const inner = obj[nest];
    if (inner && typeof inner === "object") {
      const nested = promptText(inner);
      if (nested) return nested;
    }
  }
  if (typeof obj.message === "string" && obj.message.trim()) return obj.message;
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

/** Agent sets project via a reply line: MODEL-RUST-PROJECT: <slug> */
function projectFromText(text) {
  const m = String(text || "").match(
    /MODEL-RUST-PROJECT:\s*([a-z0-9][a-z0-9-]*)/i
  );
  return m ? m[1].toLowerCase() : null;
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
  const keys =
    data && typeof data === "object" ? Object.keys(data).slice(0, 12).join(",") : "";
  log(
    `IN beforeSubmitPrompt chars=${prompt.trim().length} hasJson=${!!data} keys=${keys}`
  );
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
  const text =
    (data && data.text != null && String(data.text)) ||
    promptText(data) ||
    "";
  const state = readState();
  if (state && !state.saved) {
    state.response = sanitize(text, 2000);
    const proj = projectFromText(text);
    if (proj) state.project = proj;
    writeState(state);
    log(`RESP chars=${text.length} project=${state.project || "-"}`);
  }
  out({});
  process.exit(0);
}

if (event === "stop") {
  const status = data && data.status != null ? String(data.status) : "completed";
  // Persist on completed turns only. Ignore loop_count — Cursor often sends ≥1
  // after tool loops; skipping those dropped most auto-saves.
  if (status !== "completed") {
    log(`SKIP stop status=${status}`);
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
  const project =
    (state.project && String(state.project).trim()) ||
    projectFromText(resp) ||
    null;
  const stub = {
    prompt,
    summary: sanitize(resp, 200) || `agent completed /${skill}`,
    body: sanitize(resp, 2000),
    tags: [skill, "auto"],
    source: "chat",
    skill,
  };
  if (project) stub.project = project;
  const tmp = path.join(stateDir, "model-rust-auto-add.json");
  fs.writeFileSync(tmp, JSON.stringify(stub), "utf8");
  const crateRoot = path.resolve(path.dirname(bin), "..", "..");
  try {
    const r = spawnSync(bin, ["add", "--json", tmp], {
      encoding: "utf8",
      windowsHide: true,
      cwd: crateRoot,
    });
    if (r.status === 0) {
      clearState();
      log(`SAVED ok project=${project || "-"} out=${(r.stdout || "").trim()}`);
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
