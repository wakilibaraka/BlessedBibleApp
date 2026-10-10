#!/usr/bin/env python3
"""Generate docs/privacy_policy.md and docs/privacy_policy.html from
assets/legal/privacy_policy.json (the single source the app also renders).

Usage:  python3 tool/build_privacy_policy.py [--check]
  --check  exit 1 if the generated files are out of date (used by CI)
"""
import html
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets", "legal", "privacy_policy.json")
MD = os.path.join(ROOT, "docs", "privacy_policy.md")
HTML = os.path.join(ROOT, "docs", "privacy_policy.html")


def build_md(p):
    out = [f"# {p['title']}", "", f"**{p['app']}** · Effective date: {p['effectiveDate']}", ""]
    for s in p["sections"]:
        out += [f"## {s['heading']}", ""]
        for para in s["paragraphs"]:
            out += [para, ""]
    out += ["<!-- Generated from assets/legal/privacy_policy.json by tool/build_privacy_policy.py. Do not edit. -->", ""]
    return "\n".join(out)


def build_html(p):
    e = html.escape
    email = p["contactEmail"]
    body = []
    for s in p["sections"]:
        body.append(f"    <h2>{e(s['heading'])}</h2>")
        for para in s["paragraphs"]:
            text = e(para).replace(e(email), f'<a href="mailto:{e(email)}">{e(email)}</a>')
            body.append(f"    <p>{text}</p>")
    return f"""<!DOCTYPE html>
<!-- Generated from assets/legal/privacy_policy.json by tool/build_privacy_policy.py. Do not edit. -->
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{e(p['title'])} - {e(p['app'])}</title>
  <style>
    :root {{ color-scheme: light dark; --text: #2b2b2b; --muted: #6b6b6b; --accent: #7a4e2d; --bg: #fffdf9; --rule: #e8e2d9; }}
    @media (prefers-color-scheme: dark) {{ :root {{ --text: #ece6dd; --muted: #a9a196; --accent: #d6a77a; --bg: #181512; --rule: #3a332c; }} }}
    body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
           line-height: 1.6; color: var(--text); background: var(--bg); max-width: 760px; margin: 0 auto; padding: 24px 16px 48px; }}
    h1 {{ color: var(--accent); margin-bottom: 4px; }}
    h2 {{ border-bottom: 1px solid var(--rule); padding-bottom: 6px; margin-top: 32px; font-size: 1.15rem; }}
    .date {{ color: var(--muted); font-style: italic; margin-top: 0; }}
    a {{ color: var(--accent); }}
  </style>
</head>
<body>
  <main>
    <h1>{e(p['title'])}</h1>
    <p class="date">{e(p['app'])} · Effective date: {e(p['effectiveDate'])}</p>
{chr(10).join(body)}
  </main>
</body>
</html>
"""


def main():
    with open(SRC, encoding="utf-8") as f:
        policy = json.load(f)
    outputs = {MD: build_md(policy), HTML: build_html(policy)}
    if "--check" in sys.argv:
        stale = [p for p, text in outputs.items()
                 if not os.path.exists(p) or open(p, encoding="utf-8").read() != text]
        if stale:
            print("Out of date (run python3 tool/build_privacy_policy.py):")
            for p in stale:
                print("  " + os.path.relpath(p, ROOT))
            sys.exit(1)
        print("Privacy policy docs are up to date.")
        return
    for path, text in outputs.items():
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("wrote " + os.path.relpath(path, ROOT))


if __name__ == "__main__":
    main()
