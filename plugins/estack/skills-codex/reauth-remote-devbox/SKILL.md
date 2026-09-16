---
name: reauth-remote-devbox
description: Repair Codex or MCP plugin authentication on a remote development machine. Use after the user changes ChatGPT accounts or workspaces, when remote tasks report an invalid token, or when a plugin is enabled but reports AuthRequired or Not logged in. Use for Codex Desktop remote connections; use ordinary Codex login guidance for local-only authentication.
---

# Reauthenticate a remote devbox

Restore a Codex Desktop remote connection after an account or workspace change. A successful `codex login` updates cached credentials, but an app-server or proxy process that predates the login can keep stale authentication state. A task created under the prior account can also remain inaccessible even after the connection is healthy.

Use the official [Codex authentication documentation](https://learn.chatgpt.com/docs/auth) when current login behavior matters.

## Establish the state

Identify the remote host and the account and workspace the user intends to use. Confirm the active account and workspace in the ChatGPT Desktop profile. The remote command `codex login status` reports the authentication method, not the ChatGPT identity, so do not treat it as proof that both sides use the same account.

Inspect the remote machine without printing credentials:

```bash
ssh <host> 'codex login status; codex --version; ps -eo pid,lstart,etimes,args | grep -E "codex.*app-server|app-server.*codex" | grep -v grep || true'
```

For file-based credential storage, `stat ~/.codex/auth.json` can establish whether the app-server predates the login. Never read or print that file. The credential may instead live in the remote operating system's credential store.

Check the Codex tasks on the remote host before restarting anything. Use Codex thread tools to identify active tasks for the matching remote host. If any task is active, explain that restarting the app-server will interrupt it and get explicit user authorization before continuing.

## Align the accounts

The ChatGPT Desktop session and the remote CLI must use the account and workspace the user intends for the remote task.

If the remote login is wrong, run `codex logout`, then `codex login --device-auth` on the remote machine. Have the user complete the device flow with the intended account and workspace. Use another documented login method only when device authentication is unavailable or the user chose that method.

Do not delete credential files by hand, inspect token contents, print process environments, or copy credentials between machines unless the user explicitly requests the documented headless-machine fallback.

## Authenticate an MCP plugin

MCP OAuth credentials belong to the machine that runs Codex. A plugin authenticated on the laptop can still show `Not logged in` on a remote devbox.

On the devbox, check the server and start its login:

```bash
codex mcp list
codex mcp login <server>
```

Keep the login command running. Its generated `redirect_uri` names a localhost callback port. Use that port rather than assuming a fixed value.

On Eugene's laptop, run `devfwd <callback-port>` in a separate terminal and keep it running. `devfwd` is a laptop-only helper; do not try to run it on the devbox. Then open the latest authorization URL in the laptop browser.

Close callback tabs from earlier attempts before retrying. An old URL can reach the new listener with stale OAuth state and fail with `Authorization state not found`. A browser page that says authentication completed is not sufficient proof. The devbox command must report success, and `codex mcp list` must show `OAuth` for the server.

After login, make one small read-only plugin call. If the task still has no tools for that plugin, reload the task or start a new one so Codex can discover them.

## Restart the stale connection

After the login succeeds, restart only the Codex app-server and app-server proxy processes on the remote host. Resolve their exact PIDs from the process list, confirm each command belongs to Codex, and send `TERM` to those PIDs. Do not use a broad process-name kill.

ChatGPT Desktop normally reconnects. If replacement processes do not appear within 30 seconds, ask the user to restart that remote connection in **Settings > Connections**, then inspect the processes again. Confirm every replacement process started after the authentication change.

## Verify and interpret

Retry the task the user was trying to resume. If practical within the user's request, also test a new remote task without creating disposable tasks or threads without authorization.

- If both new and resumed tasks work, the stale remote process caused the failure.
- If new tasks work but the old task still fails, the old task likely belongs to the prior account or workspace. Local token repair cannot transfer task ownership. Use the prior account to continue it, or start replacement work under the new account.
- If all remote tasks fail, verify the Desktop account and workspace again, inspect the replacement process start times, and collect only relevant redacted app-server error lines. Do not expose tokens or unrelated task content.

Finish with the remote host, the user-confirmed account and workspace, whether processes were restarted, and which task types now work. State clearly when an old task remains bound to the previous account.
