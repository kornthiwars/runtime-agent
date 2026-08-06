use chrono::Utc;
use clap::{Parser, Subcommand};
use futures::TryStreamExt;
use mongodb::bson::{doc, oid::ObjectId, Bson, DateTime as BsonDateTime};
use mongodb::options::ClientOptions;
use mongodb::{Client, Database};
use serde_json::json;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process;
use std::time::Duration;

const MAX_PROBLEM: usize = 500;
const MAX_SUMMARY: usize = 200;
const MAX_PROMPT: usize = 2000;
const MAX_TITLE: usize = 120;

#[derive(Parser, Debug)]
#[command(
    name = "model-rust",
    about = "AI ops memory CLI (prompt/problem/solution) on MongoDB"
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Ping MongoDB using MONGODB_URI from model-rust/.env
    Ping,
    /// Insert stub -> prompts/problems/solutions/cases; print ids only
    Add {
        #[arg(long)]
        json: Option<PathBuf>,
        #[arg(long)]
        prompt: Option<String>,
        #[arg(long)]
        problem: Option<String>,
        #[arg(long, name = "solution-summary")]
        solution_summary: Option<String>,
        #[arg(long)]
        title: Option<String>,
        #[arg(long)]
        body: Option<String>,
        #[arg(long)]
        project: Option<String>,
        #[arg(long)]
        tag: Vec<String>,
        #[arg(long = "fix-step")]
        fix_step: Vec<String>,
        #[arg(long)]
        source: Option<String>,
    },
    /// Search cases (≤5 short rows); no secrets
    Search {
        #[arg(long, short = 'q')]
        q: String,
        #[arg(long)]
        project: Option<String>,
        #[arg(long, default_value_t = 5)]
        limit: usize,
    },
    /// Get one case by id (linked prompt/problem/solution clipped)
    Get {
        #[arg(long)]
        id: String,
    },
    /// Durable /note memory (collection `notes` — not chat cases)
    Note {
        #[command(subcommand)]
        action: NoteAction,
    },
}

#[derive(Subcommand, Debug)]
enum NoteAction {
    /// Insert one durable note
    Add {
        #[arg(long)]
        json: Option<PathBuf>,
        #[arg(long)]
        project: Option<String>,
        #[arg(long)]
        kind: Option<String>,
        #[arg(long)]
        title: Option<String>,
        #[arg(long)]
        body: Option<String>,
        #[arg(long)]
        tag: Vec<String>,
        /// YYYY-MM-DD last valid day (optional)
        #[arg(long)]
        expires: Option<String>,
    },
    /// List newest notes (cap 20)
    List {
        #[arg(long)]
        project: Option<String>,
        #[arg(long, default_value_t = 20)]
        limit: usize,
    },
    /// Find notes by text/title/tags
    Find {
        #[arg(long, short = 'q')]
        q: String,
        #[arg(long)]
        project: Option<String>,
        #[arg(long, default_value_t = 10)]
        limit: usize,
    },
}

fn load_env_files() {
    let env_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(".env");
    if env_path.is_file() {
        // Prefer model-rust/.env over ambient process env (e.g. leftover MONGODB_DB).
        let _ = dotenvy::from_path_override(&env_path);
    }
}

fn mongodb_uri() -> String {
    match env::var("MONGODB_URI") {
        Ok(v) => {
            let t = v.trim();
            if t.is_empty() {
                eprintln!("Missing MONGODB_URI (set in model-rust/.env). Secrets not printed.");
                process::exit(1);
            }
            t.to_string()
        }
        Err(_) => {
            eprintln!("Missing MONGODB_URI (set in model-rust/.env). Secrets not printed.");
            process::exit(1);
        }
    }
}

fn mongodb_db_name() -> String {
    match env::var("MONGODB_DB") {
        Ok(v) => {
            let t = v.trim();
            if t.is_empty() {
                "kb".to_string()
            } else {
                t.to_string()
            }
        }
        Err(_) => "kb".to_string(),
    }
}

fn clip(text: &str, max: usize) -> String {
    let s = text.trim();
    if s.chars().count() <= max {
        return s.to_string();
    }
    let truncated: String = s.chars().take(max.saturating_sub(1)).collect();
    format!("{}…", truncated.trim_end())
}

fn norm_tags(tags: impl IntoIterator<Item = String>) -> Vec<String> {
    let mut out = Vec::new();
    let mut seen = std::collections::HashSet::new();
    for t in tags {
        let key = t.trim().to_lowercase();
        if key.is_empty() || !seen.insert(key.clone()) {
            continue;
        }
        out.push(key);
    }
    out
}

async fn connect() -> (Client, Database) {
    let uri = mongodb_uri();
    let mut opts = ClientOptions::parse(&uri).await.unwrap_or_else(|e| {
        eprintln!(
            "Mongo parse/connect config failed: {}. Check URI shape / network. Secrets not printed.",
            e
        );
        process::exit(1);
    });
    opts.server_selection_timeout = Some(Duration::from_secs(20));
    opts.connect_timeout = Some(Duration::from_secs(20));
    let client = Client::with_options(opts).unwrap_or_else(|e| {
        eprintln!("Mongo client failed: {e}. Secrets not printed.");
        process::exit(1);
    });
    let db_name = mongodb_db_name();
    let db = client.database(&db_name);
    (client, db)
}

async fn cmd_ping() {
    load_env_files();
    let (_client, db) = connect().await;
    db.run_command(doc! { "ping": 1 }).await.unwrap_or_else(|e| {
        eprintln!(
            "Mongo ping failed: {}. Check Atlas IP allowlist / DNS / network. Secrets not printed.",
            e
        );
        process::exit(1);
    });
    println!(
        "{}",
        json!({
            "ok": 1,
            "mode": "uri",
            "database": mongodb_db_name(),
            "binary": "model-rust"
        })
    );
}

struct Stub {
    prompt: String,
    problem: String,
    summary: String,
    title: Option<String>,
    body: String,
    project: Option<String>,
    tags: Vec<String>,
    fix_steps: Vec<String>,
    source: String,
}

fn parse_source(raw: Option<&str>) -> String {
    match raw.map(|s| s.trim().to_lowercase()).as_deref() {
        Some("chat") => "chat".to_string(),
        Some("import") => "import".to_string(),
        Some("manual") | None | Some("") => "manual".to_string(),
        Some(other) => {
            eprintln!("invalid source {other:?}; use manual|chat|import");
            process::exit(2);
        }
    }
}

fn parse_stub(
    json: Option<PathBuf>,
    prompt: Option<String>,
    problem: Option<String>,
    summary: Option<String>,
    title: Option<String>,
    body: Option<String>,
    project: Option<String>,
    tags: Vec<String>,
    fix_steps: Vec<String>,
    source: Option<String>,
) -> Stub {
    let mut prompt = prompt.filter(|s| !s.trim().is_empty());
    let mut problem = problem.filter(|s| !s.trim().is_empty());
    let mut summary = summary.filter(|s| !s.trim().is_empty());
    let mut title = title.filter(|s| !s.trim().is_empty());
    let mut body = body.unwrap_or_default();
    let mut project = project.filter(|s| !s.trim().is_empty());
    let mut tags = tags;
    let mut fix_steps = fix_steps;
    let mut source = source.filter(|s| !s.trim().is_empty());

    if let Some(path) = json {
        let raw = fs::read_to_string(&path).unwrap_or_else(|e| {
            eprintln!("Cannot read stub JSON: {e}");
            process::exit(2);
        });
        let v: serde_json::Value = serde_json::from_str(&raw).unwrap_or_else(|e| {
            eprintln!("Invalid stub JSON: {e}");
            process::exit(2);
        });
        if prompt.is_none() {
            prompt = v
                .get("prompt")
                .or_else(|| v.get("text"))
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
        if problem.is_none() {
            problem = v
                .get("problem")
                .or_else(|| v.get("description"))
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
        if summary.is_none() {
            summary = v
                .get("solutionSummary")
                .or_else(|| v.get("summary"))
                .or_else(|| v.get("solution"))
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
        if title.is_none() {
            title = v.get("title").and_then(|x| x.as_str()).map(|s| s.to_string());
        }
        if body.is_empty() {
            body = v
                .get("body")
                .and_then(|x| x.as_str())
                .unwrap_or("")
                .to_string();
        }
        if project.is_none() {
            project = v
                .get("project")
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
        if tags.is_empty() {
            if let Some(arr) = v.get("tags").and_then(|x| x.as_array()) {
                tags = arr
                    .iter()
                    .filter_map(|x| x.as_str().map(|s| s.to_string()))
                    .collect();
            }
        }
        if fix_steps.is_empty() {
            let steps = v
                .get("fixSteps")
                .or_else(|| v.get("fix_steps"))
                .and_then(|x| x.as_array());
            if let Some(arr) = steps {
                fix_steps = arr
                    .iter()
                    .filter_map(|x| x.as_str().map(|s| s.to_string()))
                    .collect();
            }
        }
        if source.is_none() {
            source = v
                .get("source")
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
    }

    let prompt = prompt.unwrap_or_else(|| {
        eprintln!("add requires prompt");
        process::exit(2);
    });
    let problem = problem.unwrap_or_else(|| {
        eprintln!("add requires problem");
        process::exit(2);
    });
    let summary = summary.unwrap_or_else(|| {
        eprintln!("add requires solution-summary");
        process::exit(2);
    });

    Stub {
        prompt,
        problem,
        summary,
        title,
        body,
        project,
        tags: norm_tags(tags),
        fix_steps: fix_steps
            .into_iter()
            .map(|s| clip(&s, 300))
            .filter(|s| !s.is_empty())
            .collect(),
        source: parse_source(source.as_deref()),
    }
}

fn oid_str(id: ObjectId) -> String {
    id.to_hex()
}

async fn cmd_add(stub: Stub) {
    let (_client, db) = connect().await;
    let now = BsonDateTime::from_millis(Utc::now().timestamp_millis());
    let title_prompt = clip(
        stub.title
            .as_deref()
            .unwrap_or_else(|| stub.prompt.lines().next().unwrap_or(stub.prompt.as_str())),
        MAX_TITLE,
    );
    let title_problem = clip(
        stub.title.as_deref().unwrap_or(stub.problem.as_str()),
        MAX_TITLE,
    );
    let title_solution = clip(
        stub.title.as_deref().unwrap_or(stub.summary.as_str()),
        MAX_TITLE,
    );

    let prompts = db.collection::<mongodb::bson::Document>("prompts");
    let p = prompts
        .insert_one(doc! {
            "text": clip(&stub.prompt, MAX_PROMPT),
            "title": title_prompt,
            "tags": &stub.tags,
            "createdAt": now,
            "updatedAt": now,
        })
        .await
        .unwrap_or_else(|e| {
            eprintln!("insert prompts failed: {e}");
            process::exit(1);
        });
    let prompt_id = p
        .inserted_id
        .as_object_id()
        .expect("prompt ObjectId");

    let problems = db.collection::<mongodb::bson::Document>("problems");
    let b = problems
        .insert_one(doc! {
            "title": title_problem,
            "description": clip(&stub.problem, MAX_PROBLEM),
            "promptId": prompt_id,
            "tags": &stub.tags,
            "createdAt": now,
            "updatedAt": now,
        })
        .await
        .unwrap_or_else(|e| {
            eprintln!("insert problems failed: {e}");
            process::exit(1);
        });
    let problem_id = b.inserted_id.as_object_id().expect("problem ObjectId");

    let solutions = db.collection::<mongodb::bson::Document>("solutions");
    let s = solutions
        .insert_one(doc! {
            "title": title_solution,
            "summary": clip(&stub.summary, MAX_SUMMARY),
            "body": stub.body.trim(),
            "fixSteps": &stub.fix_steps,
            "rootCause": "",
            "verify": "",
            "tags": &stub.tags,
            "createdAt": now,
            "updatedAt": now,
        })
        .await
        .unwrap_or_else(|e| {
            eprintln!("insert solutions failed: {e}");
            process::exit(1);
        });
    let solution_id = s.inserted_id.as_object_id().expect("solution ObjectId");

    let project_bson = match stub.project {
        Some(p) => Bson::String(p.trim().to_lowercase()),
        None => Bson::Null,
    };

    let cases = db.collection::<mongodb::bson::Document>("cases");
    let c = cases
        .insert_one(doc! {
            "promptId": prompt_id,
            "problemId": problem_id,
            "solutionId": solution_id,
            "project": project_bson,
            "source": &stub.source,
            "createdAt": now,
            "updatedAt": now,
        })
        .await
        .unwrap_or_else(|e| {
            eprintln!("insert cases failed: {e}");
            process::exit(1);
        });
    let case_id = c.inserted_id.as_object_id().expect("case ObjectId");

    println!(
        "{}",
        json!({
            "case": oid_str(case_id),
            "prompt": oid_str(prompt_id),
            "problem": oid_str(problem_id),
            "solution": oid_str(solution_id),
        })
    );
}

fn escape_regex(raw: &str) -> String {
    let mut out = String::with_capacity(raw.len());
    for c in raw.chars() {
        match c {
            '\\' | '.' | '+' | '*' | '?' | '(' | ')' | '[' | ']' | '{' | '}' | '^' | '$' | '|' => {
                out.push('\\');
                out.push(c);
            }
            _ => out.push(c),
        }
    }
    out
}

async fn cmd_search(q: String, project: Option<String>, limit: usize) {
    load_env_files();
    let q = q.trim();
    if q.is_empty() {
        eprintln!("search requires --q");
        process::exit(2);
    }
    let limit = limit.clamp(1, 5);
    let (_client, db) = connect().await;
    let pattern = escape_regex(q);
    let prompts = db.collection::<mongodb::bson::Document>("prompts");
    let problems = db.collection::<mongodb::bson::Document>("problems");
    let solutions = db.collection::<mongodb::bson::Document>("solutions");
    let cases = db.collection::<mongodb::bson::Document>("cases");

    let prompt_filter = doc! {
        "$or": [
            { "text": { "$regex": &pattern, "$options": "i" } },
            { "title": { "$regex": &pattern, "$options": "i" } },
            { "tags": { "$regex": &pattern, "$options": "i" } },
        ]
    };
    let mut prompt_ids: Vec<ObjectId> = Vec::new();
    let mut cursor = prompts
        .find(prompt_filter)
        .limit(20)
        .await
        .unwrap_or_else(|e| {
            eprintln!("search prompts failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(doc)) = cursor.try_next().await {
        if let Some(id) = doc.get_object_id("_id").ok() {
            prompt_ids.push(id);
        }
    }

    let problem_filter = doc! {
        "$or": [
            { "description": { "$regex": &pattern, "$options": "i" } },
            { "title": { "$regex": &pattern, "$options": "i" } },
            { "tags": { "$regex": &pattern, "$options": "i" } },
        ]
    };
    let mut problem_ids: Vec<ObjectId> = Vec::new();
    let mut cursor = problems
        .find(problem_filter)
        .limit(20)
        .await
        .unwrap_or_else(|e| {
            eprintln!("search problems failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(doc)) = cursor.try_next().await {
        if let Some(id) = doc.get_object_id("_id").ok() {
            problem_ids.push(id);
        }
    }

    let solution_filter = doc! {
        "$or": [
            { "summary": { "$regex": &pattern, "$options": "i" } },
            { "title": { "$regex": &pattern, "$options": "i" } },
            { "tags": { "$regex": &pattern, "$options": "i" } },
        ]
    };
    let mut solution_ids: Vec<ObjectId> = Vec::new();
    let mut cursor = solutions
        .find(solution_filter)
        .limit(20)
        .await
        .unwrap_or_else(|e| {
            eprintln!("search solutions failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(doc)) = cursor.try_next().await {
        if let Some(id) = doc.get_object_id("_id").ok() {
            solution_ids.push(id);
        }
    }

    let mut or_clauses: Vec<mongodb::bson::Document> = Vec::new();
    if !prompt_ids.is_empty() {
        or_clauses.push(doc! { "promptId": { "$in": &prompt_ids } });
    }
    if !problem_ids.is_empty() {
        or_clauses.push(doc! { "problemId": { "$in": &problem_ids } });
    }
    if !solution_ids.is_empty() {
        or_clauses.push(doc! { "solutionId": { "$in": &solution_ids } });
    }

    let mut case_filter = if or_clauses.is_empty() {
        doc! { "_id": { "$exists": false } }
    } else {
        doc! { "$or": or_clauses }
    };
    if let Some(p) = project.filter(|s| !s.trim().is_empty()) {
        case_filter.insert("project", p.trim().to_lowercase());
    }

    let mut rows = Vec::new();
    let mut cursor = cases
        .find(case_filter)
        .sort(doc! { "createdAt": -1 })
        .limit(limit as i64)
        .await
        .unwrap_or_else(|e| {
            eprintln!("search cases failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(case_doc)) = cursor.try_next().await {
        let case_id = match case_doc.get_object_id("_id") {
            Ok(id) => id,
            Err(_) => continue,
        };
        let prompt_id = case_doc.get_object_id("promptId").ok();
        let problem_id = case_doc.get_object_id("problemId").ok();
        let solution_id = case_doc.get_object_id("solutionId").ok();

        let prompt_text = if let Some(id) = prompt_id {
            prompts
                .find_one(doc! { "_id": id })
                .await
                .ok()
                .flatten()
                .and_then(|d| d.get_str("text").ok().map(|s| clip(s, 120)))
                .unwrap_or_default()
        } else {
            String::new()
        };
        let problem_text = if let Some(id) = problem_id {
            problems
                .find_one(doc! { "_id": id })
                .await
                .ok()
                .flatten()
                .and_then(|d| d.get_str("description").ok().map(|s| clip(s, 120)))
                .unwrap_or_default()
        } else {
            String::new()
        };
        let summary = if let Some(id) = solution_id {
            solutions
                .find_one(doc! { "_id": id })
                .await
                .ok()
                .flatten()
                .and_then(|d| d.get_str("summary").ok().map(|s| clip(s, 120)))
                .unwrap_or_default()
        } else {
            String::new()
        };
        let project = case_doc
            .get_str("project")
            .ok()
            .map(|s| s.to_string())
            .unwrap_or_default();

        rows.push(json!({
            "case": oid_str(case_id),
            "prompt": prompt_text,
            "problem": problem_text,
            "summary": summary,
            "project": project,
        }));
    }

    println!("{}", json!({ "ok": 1, "q": q, "hits": rows }));
}

async fn cmd_get(id: String) {
    load_env_files();
    let oid = ObjectId::parse_str(id.trim()).unwrap_or_else(|_| {
        eprintln!("get --id must be a Mongo ObjectId hex");
        process::exit(2);
    });
    let (_client, db) = connect().await;
    let cases = db.collection::<mongodb::bson::Document>("cases");
    let case_doc = cases
        .find_one(doc! { "_id": oid })
        .await
        .unwrap_or_else(|e| {
            eprintln!("get case failed: {e}");
            process::exit(1);
        })
        .unwrap_or_else(|| {
            eprintln!("case not found");
            process::exit(1);
        });

    let prompt_id = case_doc.get_object_id("promptId").ok();
    let problem_id = case_doc.get_object_id("problemId").ok();
    let solution_id = case_doc.get_object_id("solutionId").ok();

    let prompts = db.collection::<mongodb::bson::Document>("prompts");
    let problems = db.collection::<mongodb::bson::Document>("problems");
    let solutions = db.collection::<mongodb::bson::Document>("solutions");

    let prompt = if let Some(id) = prompt_id {
        prompts.find_one(doc! { "_id": id }).await.ok().flatten()
    } else {
        None
    };
    let problem = if let Some(id) = problem_id {
        problems.find_one(doc! { "_id": id }).await.ok().flatten()
    } else {
        None
    };
    let solution = if let Some(id) = solution_id {
        solutions.find_one(doc! { "_id": id }).await.ok().flatten()
    } else {
        None
    };

    println!(
        "{}",
        json!({
            "case": oid_str(oid),
            "project": case_doc.get_str("project").ok(),
            "source": case_doc.get_str("source").ok(),
            "prompt": prompt.as_ref().map(|d| json!({
                "id": prompt_id.map(oid_str),
                "text": d.get_str("text").ok().map(|s| clip(s, MAX_PROMPT)),
                "title": d.get_str("title").ok(),
                "tags": d.get_array("tags").ok().map(|a| a.iter().filter_map(|x| x.as_str()).collect::<Vec<_>>()).unwrap_or_default(),
            })),
            "problem": problem.as_ref().map(|d| json!({
                "id": problem_id.map(oid_str),
                "title": d.get_str("title").ok(),
                "description": d.get_str("description").ok().map(|s| clip(s, MAX_PROBLEM)),
            })),
            "solution": solution.as_ref().map(|d| json!({
                "id": solution_id.map(oid_str),
                "title": d.get_str("title").ok(),
                "summary": d.get_str("summary").ok().map(|s| clip(s, MAX_SUMMARY)),
                "body": d.get_str("body").ok().map(|s| clip(s, 2000)),
                "fixSteps": d.get_array("fixSteps").ok().map(|a| a.iter().filter_map(|x| x.as_str()).collect::<Vec<_>>()).unwrap_or_default(),
            })),
        })
    );
}

const NOTE_KINDS: &[&str] = &["decision", "constraint", "exception", "gotcha"];
const MAX_NOTE_BODY: usize = 4000;

fn parse_note_kind(raw: &str) -> String {
    let k = raw.trim().to_lowercase();
    if NOTE_KINDS.contains(&k.as_str()) {
        return k;
    }
    eprintln!(
        "invalid kind {raw:?}; use decision|constraint|exception|gotcha"
    );
    process::exit(2);
}

/// Parse YYYY-MM-DD → end-of-day UTC millis, or Null if empty.
fn parse_expires(raw: Option<&str>) -> Bson {
    let Some(s) = raw.map(str::trim).filter(|s| !s.is_empty()) else {
        return Bson::Null;
    };
    let date = chrono::NaiveDate::parse_from_str(s, "%Y-%m-%d").unwrap_or_else(|_| {
        eprintln!("expires must be YYYY-MM-DD");
        process::exit(2);
    });
    let dt = date
        .and_hms_opt(23, 59, 59)
        .expect("valid hms")
        .and_utc();
    Bson::DateTime(BsonDateTime::from_millis(dt.timestamp_millis()))
}

fn note_expired(doc: &mongodb::bson::Document) -> bool {
    match doc.get("expires") {
        Some(Bson::DateTime(dt)) => {
            let today = Utc::now().date_naive();
            let exp = chrono::DateTime::<Utc>::from_timestamp_millis(dt.timestamp_millis())
                .map(|d| d.date_naive());
            match exp {
                Some(d) => today > d,
                None => false,
            }
        }
        _ => false,
    }
}

fn note_expires_str(doc: &mongodb::bson::Document) -> Option<String> {
    match doc.get("expires") {
        Some(Bson::DateTime(dt)) => {
            chrono::DateTime::<Utc>::from_timestamp_millis(dt.timestamp_millis())
                .map(|d| d.format("%Y-%m-%d").to_string())
        }
        _ => None,
    }
}

struct NoteStub {
    project: String,
    kind: String,
    title: String,
    body: String,
    tags: Vec<String>,
    expires: Option<String>,
}

fn parse_note_stub(
    json: Option<PathBuf>,
    project: Option<String>,
    kind: Option<String>,
    title: Option<String>,
    body: Option<String>,
    tags: Vec<String>,
    expires: Option<String>,
) -> NoteStub {
    let mut project = project.filter(|s| !s.trim().is_empty());
    let mut kind = kind.filter(|s| !s.trim().is_empty());
    let mut title = title.filter(|s| !s.trim().is_empty());
    let mut body = body.unwrap_or_default();
    let mut tags = tags;
    let mut expires = expires.filter(|s| !s.trim().is_empty());

    if let Some(path) = json {
        let raw = fs::read_to_string(&path).unwrap_or_else(|e| {
            eprintln!("Cannot read note JSON: {e}");
            process::exit(2);
        });
        let v: serde_json::Value = serde_json::from_str(&raw).unwrap_or_else(|e| {
            eprintln!("Invalid note JSON: {e}");
            process::exit(2);
        });
        if project.is_none() {
            project = v
                .get("project")
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
        if kind.is_none() {
            kind = v.get("kind").and_then(|x| x.as_str()).map(|s| s.to_string());
        }
        if title.is_none() {
            title = v.get("title").and_then(|x| x.as_str()).map(|s| s.to_string());
        }
        if body.is_empty() {
            body = v
                .get("body")
                .and_then(|x| x.as_str())
                .unwrap_or("")
                .to_string();
        }
        if tags.is_empty() {
            if let Some(arr) = v.get("tags").and_then(|x| x.as_array()) {
                tags = arr
                    .iter()
                    .filter_map(|x| x.as_str().map(|s| s.to_string()))
                    .collect();
            }
        }
        if expires.is_none() {
            expires = v
                .get("expires")
                .and_then(|x| x.as_str())
                .map(|s| s.to_string());
        }
    }

    let project = project
        .unwrap_or_else(|| {
            eprintln!("note add requires --project");
            process::exit(2);
        })
        .trim()
        .to_lowercase();
    if !project
        .chars()
        .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
        || project.is_empty()
    {
        eprintln!("project must match [a-z0-9-]+");
        process::exit(2);
    }
    let kind = parse_note_kind(&kind.unwrap_or_else(|| {
        eprintln!("note add requires --kind");
        process::exit(2);
    }));
    let title = clip(
        &title.unwrap_or_else(|| {
            eprintln!("note add requires --title");
            process::exit(2);
        }),
        MAX_TITLE,
    );
    let body = clip(body.trim(), MAX_NOTE_BODY);
    if body.is_empty() {
        eprintln!("note add requires --body");
        process::exit(2);
    }

    NoteStub {
        project,
        kind,
        title,
        body,
        tags: norm_tags(tags),
        expires,
    }
}

async fn cmd_note_add(stub: NoteStub) {
    let (_client, db) = connect().await;
    let now = BsonDateTime::from_millis(Utc::now().timestamp_millis());
    let notes = db.collection::<mongodb::bson::Document>("notes");
    let res = notes
        .insert_one(doc! {
            "project": &stub.project,
            "kind": &stub.kind,
            "title": &stub.title,
            "body": &stub.body,
            "tags": &stub.tags,
            "expires": parse_expires(stub.expires.as_deref()),
            "createdAt": now,
            "updatedAt": now,
        })
        .await
        .unwrap_or_else(|e| {
            eprintln!("insert notes failed: {e}");
            process::exit(1);
        });
    let id = res.inserted_id.as_object_id().expect("note ObjectId");
    println!(
        "{}",
        json!({
            "ok": 1,
            "id": oid_str(id),
            "project": stub.project,
            "kind": stub.kind,
            "title": stub.title,
        })
    );
}

fn note_row(doc: &mongodb::bson::Document) -> serde_json::Value {
    let id = doc
        .get_object_id("_id")
        .map(oid_str)
        .unwrap_or_default();
    json!({
        "id": id,
        "project": doc.get_str("project").ok().unwrap_or(""),
        "kind": doc.get_str("kind").ok().unwrap_or(""),
        "title": doc.get_str("title").ok().unwrap_or(""),
        "body": doc.get_str("body").ok().map(|s| clip(s, 200)).unwrap_or_default(),
        "expires": note_expires_str(doc),
        "expired": note_expired(doc),
        "tags": doc.get_array("tags").ok().map(|a| a.iter().filter_map(|x| x.as_str()).collect::<Vec<_>>()).unwrap_or_default(),
    })
}

async fn cmd_note_list(project: Option<String>, limit: usize) {
    load_env_files();
    let limit = limit.clamp(1, 20);
    let (_client, db) = connect().await;
    let notes = db.collection::<mongodb::bson::Document>("notes");
    let filter = match project.filter(|s| !s.trim().is_empty()) {
        Some(p) => doc! { "project": p.trim().to_lowercase() },
        None => doc! {},
    };
    let mut items = Vec::new();
    let mut cursor = notes
        .find(filter)
        .sort(doc! { "createdAt": -1 })
        .limit(limit as i64)
        .await
        .unwrap_or_else(|e| {
            eprintln!("note list failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(doc)) = cursor.try_next().await {
        items.push(note_row(&doc));
    }
    println!("{}", json!({ "ok": 1, "items": items }));
}

async fn cmd_note_find(q: String, project: Option<String>, limit: usize) {
    load_env_files();
    let q = q.trim();
    if q.is_empty() {
        eprintln!("note find requires --q");
        process::exit(2);
    }
    let limit = limit.clamp(1, 10);
    let (_client, db) = connect().await;
    let notes = db.collection::<mongodb::bson::Document>("notes");
    let pattern = escape_regex(q);
    let mut filter = doc! {
        "$or": [
            { "title": { "$regex": &pattern, "$options": "i" } },
            { "body": { "$regex": &pattern, "$options": "i" } },
            { "tags": { "$regex": &pattern, "$options": "i" } },
            { "kind": { "$regex": &pattern, "$options": "i" } },
        ]
    };
    if let Some(p) = project.filter(|s| !s.trim().is_empty()) {
        filter = doc! {
            "$and": [
                { "project": p.trim().to_lowercase() },
                filter,
            ]
        };
    }
    let mut hits = Vec::new();
    let mut cursor = notes
        .find(filter)
        .sort(doc! { "createdAt": -1 })
        .limit(limit as i64)
        .await
        .unwrap_or_else(|e| {
            eprintln!("note find failed: {e}");
            process::exit(1);
        });
    while let Ok(Some(doc)) = cursor.try_next().await {
        hits.push(note_row(&doc));
    }
    println!("{}", json!({ "ok": 1, "q": q, "hits": hits }));
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Ping => cmd_ping().await,
        Commands::Add {
            json,
            prompt,
            problem,
            solution_summary,
            title,
            body,
            project,
            tag,
            fix_step,
            source,
        } => {
            load_env_files();
            let stub = parse_stub(
                json,
                prompt,
                problem,
                solution_summary,
                title,
                body,
                project,
                tag,
                fix_step,
                source,
            );
            cmd_add(stub).await;
        }
        Commands::Search { q, project, limit } => cmd_search(q, project, limit).await,
        Commands::Get { id } => cmd_get(id).await,
        Commands::Note { action } => match action {
            NoteAction::Add {
                json,
                project,
                kind,
                title,
                body,
                tag,
                expires,
            } => {
                load_env_files();
                let stub = parse_note_stub(json, project, kind, title, body, tag, expires);
                cmd_note_add(stub).await;
            }
            NoteAction::List { project, limit } => cmd_note_list(project, limit).await,
            NoteAction::Find { q, project, limit } => cmd_note_find(q, project, limit).await,
        },
    }
}
