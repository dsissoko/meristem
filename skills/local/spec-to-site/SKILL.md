# spec-to-site

Generate a browsable static site from `docs/specs/` using docsify + Mermaid rendering.

## When to use

When the user asks to share, export, or preview the specs as a navigable site.

## Output

- `docs/site/index.html` — docsify bootstrap with Mermaid plugin
- `docs/site/_sidebar.md` — auto-generated navigation from `docs/specs/` tree
- `docs/specs/` files are **copied** into `docs/site/` preserving the directory structure — docsify requires all files to be under its `basePath`

## Steps

### 1. Copy specs into site

```bash
cp -r docs/specs/* docs/site/
```

Docsify requires all served files to be under its `basePath` (`docs/site/`). Links in `_sidebar.md` are relative to `docs/site/`.

### 2. Generate `docs/site/_sidebar.md`

Walk `docs/specs/` recursively. Build a nested sidebar from the directory structure.

Rules:
- Directory name → section header (capitalize, replace `-` with space)
- `.md` file → link relative to `docs/site/` (no prefix needed)
- Ignore files starting with `_`
- Order: directories before files, alphabetical within each group

Example output:
```markdown
- **Architecture**
  - **Software**
    - [C4 Context](architecture/software/c4-context.md)
    - [C4 Containers](architecture/software/c4-containers.md)
  - **Infrastructure**
    - [C4 Deployment](architecture/infrastructure/c4-deployment.md)
- **Functional**
  - ...
```

### 3. Generate `docs/site/index.html`

Single HTML file. No build step — docsify renders markdown at runtime in the browser.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Specs</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">
  <style>
    :root { --theme-color: #0969da; }
    .sidebar { background: #f6f8fa; }
  </style>
</head>
<body>
  <div id="app"></div>
  <script>
    window.$docsify = {
      name: 'Specs',
      repo: '',
      loadSidebar: true,
      subMaxLevel: 2,
      basePath: '.',
      mermaidConfig: { querySelector: ".mermaid" }
    }
  </script>
  <script type="module">
    import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs";
    mermaid.initialize({ startOnLoad: true });
    window.mermaid = mermaid;
  </script>
  <script src="https://unpkg.com/docsify-mermaid@2.0.1/dist/docsify-mermaid.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/docsify@4/lib/docsify.min.js"></script>
</body>
</html>
```

**Critical loading order:** mermaid (ESM module) → docsify-mermaid plugin → docsify. Inverting this order breaks Mermaid rendering.

### 4. Create a README.md in docs/site/ as homepage

### 5. Offer preview (local environments only)

Before launching the server, **detect the execution environment**:

- If running in a **cloud or remote container** (e.g. OpenHands cloud, Codex cloud, CI): do **not** start the server — it would be unreachable. Inform the user that `docs/site/` has been generated and can be previewed by running locally:
  ```bash
  npx docsify-cli serve docs/site --port 3000
  ```

- If running **locally**: ask the user explicitly before launching:
  > "The site has been generated in `docs/site/`. Do you want me to start a local preview server?"

  If yes, first ensure no docsify server is already running:
  ```bash
  if [ -f docs/.docsify.pid ]; then
    kill $(cat docs/.docsify.pid) 2>/dev/null
    rm -f docs/.docsify.pid docs/.docsify-serve.out
  fi
  pkill -f docsify-cli 2>/dev/null || true
  ```

  Then launch:
  ```bash
  npx docsify-cli serve docs/site --port 3000 > docs/.docsify-serve.out 2>&1 &
  echo $! > docs/.docsify.pid
  sleep 3
  cat docs/.docsify-serve.out
  ```

  Read the output to extract the actual port (docsify picks an available one if 3000 is taken):
  ```
  Serving /path/to/docs/site now.
  Listening at http://localhost:<port>
  ```

  Verify the server is running:
  ```bash
  curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>
  ```
  Expected: `200`. Report the exact URL to the user.

  **Always inform the user how to stop the server:**
  ```bash
  # Stop via saved PID
  kill $(cat docs/.docsify.pid) && rm docs/.docsify.pid && rm -f docs/.docsify-serve.out

  # Or stop all docsify processes
  pkill -f docsify-cli
  ```

  Add `docs/.docsify.pid` and `docs/.docsify-serve.out` to `.gitignore` if not already present.

> **Note:** docsify and Mermaid are loaded from CDN at runtime. Internet access is required when previewing the site in the browser.

## Constraints

- Node.js / npx only — no Python, no system dependencies
- CDN for docsify and Mermaid (requires internet access at preview time)
- No build step — docsify renders markdown at runtime in the browser
- `docs/site/` is a generated artifact — always regenerate from `docs/specs/` when specs change

## What the agent must NOT do

- Do not install docsify globally (`npm install -g`) — use `npx` only
- Do not edit files under `docs/specs/` — `docs/site/` is the only write target
