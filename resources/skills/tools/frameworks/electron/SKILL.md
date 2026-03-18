# Electron Skill

<!-- category: template -->

## Overview
Electron runs a Chromium renderer and a Node.js main process in a single desktop app.
The critical concept: main process (Node.js, full OS access) communicates with renderer
(browser sandbox) via IPC through a preload bridge. Security, module format (CJS vs ESM),
and native module compilation are the top sources of bugs.
[FILL: How Electron is used in THIS project — app purpose, target platforms]

## Core Setup
- Electron version: [FILL: e.g., 34.x]
- Bundler (main): [FILL: esbuild / webpack / tsup — MUST output CJS]
- Bundler (renderer): [FILL: Vite / webpack — standard web bundling]
- Native modules: [FILL: better-sqlite3, node-pty, sharp, etc.]
- Packaging: [FILL: electron-builder / electron-forge]

## Module Format — CJS vs ESM
**#1 source of Electron boot failures.** Electron's main process uses `require()`.
- If `package.json` has `"type": "module"`, `.js` files are treated as ESM — native modules break
- **Fix**: Remove `"type": "module"` from the main app's package.json, OR output `.cjs` files
- Bundle main process with `format: 'cjs'`, keep native modules as `external`
- The renderer is a web page — ESM via Vite is fine there
[FILL: Module format decisions in THIS project]

## Native Modules
Native addons (`.node` files) are compiled against a specific Node ABI. System Node.js
and Electron's bundled Node.js have DIFFERENT ABI versions.
- Install `@electron/rebuild` as devDependency
- Run `npx @electron/rebuild` after any native module install
- Add `"postinstall": "npx @electron/rebuild"` to package.json
- Error `NODE_MODULE_VERSION X requires Y` = forgot to rebuild
[FILL: Native modules used in THIS project and rebuild configuration]

## Process Architecture & IPC
```
Main Process (Node.js) ◄──IPC──► Renderer Process (Chromium)
       │                                    │
       │ preload.ts (bridge)                │
       │ contextBridge.exposeInMainWorld()  │
```
- `ipcMain.handle` / `ipcRenderer.invoke` for request/response (returns Promise)
- `webContents.send` / `ipcRenderer.on` for streaming (main pushes to renderer)
- Always return unsubscribe functions from `on` listeners to prevent memory leaks
- IPC uses structured clone — no functions, classes, or circular references
[FILL: IPC channel design in THIS project]

## Security — Context Isolation
**ALWAYS: `contextIsolation: true`, `nodeIntegration: false`.**
- Preload script bridges main and renderer via `contextBridge.exposeInMainWorld`
- Never pass `ipcRenderer` directly — expose specific typed methods only
- Declare renderer API type: `declare global { interface Window { myApi: ... } }`
- Set `sandbox: false` only if preload needs Node APIs (fs, path, etc.)
[FILL: Security configuration in THIS project]

## Development Workflow
- Renderer: Vite dev server on `http://localhost:5173` with HMR
- Main: esbuild watch + manual Electron restart (no HMR for main process)
- Use `app.isPackaged` to detect dev vs production
- DevTools: `mainWindow.webContents.openDevTools()` in dev only
- Build order: renderer first (produces dist/), then main (references renderer dist)
[FILL: Dev commands and workflow in THIS project]

## Packaging
- electron-builder reads `main` from package.json for entry point
- `extraMetadata.main` in config overrides package.json for packaged builds
- Native modules in node_modules are rebuilt for target platform automatically
- macOS: code signing + notarization required for distribution
[FILL: Packaging configuration in THIS project]

## macOS Conventions
- `titleBarStyle: 'hiddenInset'` for frameless with native traffic lights
- `app.on('activate')` — recreate window on dock click (macOS convention)
- `app.on('window-all-closed')` — don't quit on macOS
[FILL: Platform-specific behavior in THIS project]

## Where to Look
- Main process: [FILL: Path to main entry and services]
- Preload: [FILL: Path to preload script]
- Renderer: [FILL: Path to renderer app]
- IPC types: [FILL: Path to shared IPC type definitions]
- Build config: [FILL: Path to esbuild/electron-builder config]
- Docs: https://www.electronjs.org/docs/latest/

## Common Pitfalls
- `"type": "module"` in package.json breaks main process — remove it or output `.cjs`
- Forgetting `@electron/rebuild` after native module install — instant ABI crash
- Passing non-cloneable objects through IPC (functions, classes) — silent failures
- `__dirname` in bundled code points to bundle location, not source — use `app.getAppPath()`
- Hot reload only works for renderer — main process changes require restart
- Not handling `app.on('activate')` on macOS — dock click does nothing
