#!/usr/bin/env bash
# model-rust auto memory — Cursor hook entry (Unix).
# Usage: model-rust-auto.sh <beforeSubmitPrompt|afterAgentResponse|stop>
set -u

EVENT="${1:-}"
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
STATE_DIR="$HOOK_DIR/state"
export HOOK_DIR WORKSPACE_ROOT STATE_DIR EVENT
export STATE_PATH="$STATE_DIR/model-rust-pending.json"
export LOG_PATH="$STATE_DIR/model-rust-auto.log"
export DISABLE_PATH="$STATE_DIR/model-rust-auto.off"

mkdir -p "$STATE_DIR"

if [[ ! -f "$DISABLE_PATH" && "${MODEL_RUST_AUTO:-}" != "0" ]] && ! command -v python3 >/dev/null 2>&1; then
  printf '%s' '{}'
  exit 0
fi

# stdin JSON → python driver
python3 - "$EVENT" <<'PY'
import json, os, re, sys, subprocess
from datetime import datetime
from pathlib import Path

event = sys.argv[1] if len(sys.argv) > 1 else ""
raw = sys.stdin.read()
workspace = Path(os.environ["WORKSPACE_ROOT"])
state_dir = Path(os.environ["STATE_DIR"])
state_path = Path(os.environ["STATE_PATH"])
log_path = Path(os.environ["LOG_PATH"])
disable_path = Path(os.environ["DISABLE_PATH"])
min_chars = 6

def out(obj):
    sys.stdout.write(obj if isinstance(obj, str) else json.dumps(obj, ensure_ascii=False))

def log(msg: str) -> None:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with log_path.open("a", encoding="utf-8") as f:
        f.write(f"{datetime.now().isoformat()} {msg}\n")

def sanitize(text: str, max_chars: int) -> str:
    if not text:
        return ""
    lines = [
        ln for ln in text.splitlines()
        if not re.search(r"(MONGODB_URI|password\s*=|api[_-]?key|secret\s*=|Bearer\s+\S+)", ln, re.I)
    ]
    joined = "\n".join(lines).strip()
    return joined if len(joined) <= max_chars else joined[: max_chars - 1] + "…"

def parse_in():
    try:
        return json.loads(raw) if raw.strip() else {}
    except Exception:
        return {}

if disable_path.is_file() or os.environ.get("MODEL_RUST_AUTO") == "0":
    log(f"SKIP disabled event={event}")
    out('{"continue":true}' if event == "beforeSubmitPrompt" else "{}")
    raise SystemExit(0)

data = parse_in()
skip_re = re.compile(r"^(ok|okay|thanks|thank you|ยืนยัน|confirm|yes|y|no|n|ได้|ครับ|ค่ะ)\s*$", re.I)
skill_re = re.compile(r"(^|\s)/(fix|make|feature|plan|ship|review|note|upgrades)\b", re.I)
project_re = re.compile(r"MODEL-RUST-PROJECT:\s*([a-z0-9][a-z0-9-]*)", re.I)

def project_from_text(text: str):
    m = project_re.search(text or "")
    return m.group(1).lower() if m else None

if event == "beforeSubmitPrompt":
    prompt = ""
    for key in ("prompt", "prompt_text", "text", "message", "content"):
        val = data.get(key)
        if val is not None and str(val).strip():
            prompt = str(val)
            break
    p = prompt.strip()
    if len(p) < min_chars or skip_re.match(p):
        if state_path.is_file():
            state_path.unlink()
        log("SKIP short/ack prompt")
    else:
        m = skill_re.search(prompt)
        skill = m.group(2).lower() if m else "chat"
        state = {
            "prompt": sanitize(prompt, 2000),
            "skill": skill,
            "response": "",
            "createdAtIso": datetime.now().isoformat(),
            "saved": False,
        }
        state_path.write_text(json.dumps(state, ensure_ascii=False), encoding="utf-8")
        log(f"STAGE skill={skill} chars={len(p)}")
    out('{"continue":true}')
    raise SystemExit(0)

if event == "afterAgentResponse":
    if state_path.is_file():
        state = json.loads(state_path.read_text(encoding="utf-8"))
        if not state.get("saved"):
            text = str(data.get("text") or "")
            state["response"] = sanitize(text, 2000)
            proj = project_from_text(text)
            if proj:
                state["project"] = proj
            state_path.write_text(json.dumps(state, ensure_ascii=False), encoding="utf-8")
            log(f"RESP chars={len(text)} project={state.get('project') or '-'}")
    out("{}")
    raise SystemExit(0)

if event == "stop":
    status = str(data.get("status") or "completed")
    # Ignore loop_count — same as model-rust-auto.mjs (tool loops must still save).
    if status != "completed":
        log(f"SKIP stop status={status}")
        out("{}")
        raise SystemExit(0)
    if not state_path.is_file():
        log("SKIP stop no-pending")
        out("{}")
        raise SystemExit(0)
    state = json.loads(state_path.read_text(encoding="utf-8"))
    if state.get("saved") or not str(state.get("prompt") or "").strip():
        log("SKIP stop no-pending")
        out("{}")
        raise SystemExit(0)

    candidates = [
        workspace / "agent-skills/model-rust/target/release/model-rust",
        workspace / "agent-skills/model-rust/target/debug/model-rust",
        workspace / "model-rust/target/release/model-rust",
        workspace / "model-rust/target/debug/model-rust",
    ]
    bin_path = next((p for p in candidates if p.is_file() and os.access(p, os.X_OK)), None)
    if not bin_path:
        log("FAIL no-binary")
        out("{}")
        raise SystemExit(0)

    prompt = str(state.get("prompt") or "")
    resp = str(state.get("response") or "")
    skill = str(state.get("skill") or "chat") or "chat"
    project = str(state.get("project") or "").strip().lower() or project_from_text(resp)
    stub = {
        "prompt": prompt,
        "summary": sanitize(resp, 200) or f"agent completed /{skill}",
        "body": sanitize(resp, 2000),
        "tags": [skill, "auto"],
        "source": "chat",
        "skill": skill,
    }
    if project:
        stub["project"] = project
    tmp = state_dir / "model-rust-auto-add.json"
    tmp.write_text(json.dumps(stub, ensure_ascii=False), encoding="utf-8")
    crate_root = bin_path.resolve().parent.parent
    try:
        proc = subprocess.run(
            [str(bin_path), "add", "--json", str(tmp)],
            capture_output=True,
            text=True,
            cwd=str(crate_root),
        )
        if proc.returncode == 0:
            state_path.unlink(missing_ok=True)
            log(f"SAVED ok project={project or '-'} out={(proc.stdout or '').strip()}")
        else:
            log(f"FAIL add exit={proc.returncode} out={(proc.stderr or proc.stdout or '').strip()}")
    finally:
        tmp.unlink(missing_ok=True)
    out("{}")
    raise SystemExit(0)

out("{}")
PY
