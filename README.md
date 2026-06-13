# 🔐 QB-AntiBackdoor

A lightweight, performance-friendly runtime security script designed for the **QBCore Framework**. It actively monitors your server environment to intercept, log, and block malicious code injection, unauthorized network calls, and suspicious global events stemming from compromised or leaked resources.

---

## 🧮 Features

* **Dynamic Code Interception:** Hooks into global Lua functions (`load`, `loadstring`) to completely kill execution paths of runtime code injections.
* **Network Traffic Filtering:** Constantly checks `PerformHttpRequest` calls and drops handshakes heading toward known backdoor command centers (Pastebin, raw GitHub raw repositories, unauthorized webhooks).
* **Global Event Safeguards:** Inspects mass server-to-client broadcasts (`-1` targets) ensuring sensitive events can't be spammed across your players.
* **Instant Containment:** Auto-drops players attempting to execute malicious injected payloads from executive execution loops.
* **Fully Server-Side:** Zero performance impact on the client side, running at **0.00ms CPU time** at rest on the server.

---

## 🧰 Requirements

* [FXServer](https://fivem.net/) (Linux or Windows)
* [QBCore Framework](https://github.com/qbcore-framework)
* *No extra dependencies or external database requirements required.*

---

## 🚀 Installation

### 1. File Placement
Download the repository files and extract them into your server's resource directory. It is highly recommended to place it within a security category folder:
```text
resources/[security]/qb-antibackdoor/
├── fxmanifest.lua
└── server.lua
