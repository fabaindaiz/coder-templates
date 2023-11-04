---
display_name: KasmVNC
description: KasmVNC - KasvVNC remote desktop in the browser
icon: ../.icons/kasmvnc.svg
maintainer_github: fabaindaiz
verified: false
tags: [vnc]
---

# KasvVNC

Install KasmVNC on a workspace to enable remote desktop access in the browser.
Only works on Linux workspaces based on debian distributions.

```hcl
module "kasmvnc" {
  source = "https://registry.coder.com/modules/kasvnc"
  agent_id = coder_agent.example.id
}
```
