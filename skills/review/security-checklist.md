# /review — security checklist

Use on every review; elevate to Critical when proven.

- [ ] Secrets / API keys / tokens in client bundles or committed files
- [ ] AuthZ ≠ UI hide only (server/API enforces)
- [ ] XSS sinks: unsanitized HTML, `dangerouslySetInnerHTML`, raw markdown
- [ ] Open redirect / SSRF / unvalidated URL fetch
- [ ] Raw internal errors or stack traces to users
- [ ] PII in logs, fixtures, or REPORT
- [ ] CSRF / cookie flags if session cookies change
- [ ] Widened CORS or public ACL by accident

Enterprise surfaces → also `enterprise-safety` (migration, payments, infra).
