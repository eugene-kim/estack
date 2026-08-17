#!/usr/bin/env bun

import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { createInterface } from "node:readline";

export type RateLimitWindow = {
  usedPercent: number;
  windowDurationMins: number | null;
  resetsAt: number | null;
};

type CreditsSnapshot = {
  hasCredits: boolean;
  unlimited: boolean;
  balance: string | null;
};

export type RateLimitSnapshot = {
  limitId: string | null;
  limitName: string | null;
  primary: RateLimitWindow | null;
  secondary: RateLimitWindow | null;
  credits: CreditsSnapshot | null;
  individualLimit: {
    limit: string;
    used: string;
    remainingPercent: number;
    resetsAt: number;
  } | null;
  spendControlReached: boolean | null;
  planType: string | null;
  rateLimitReachedType: string | null;
};

export type UsageResponse = {
  rateLimits: RateLimitSnapshot;
  rateLimitsByLimitId: Record<string, RateLimitSnapshot> | null;
  rateLimitResetCredits: {
    availableCount: number | string;
    credits: Array<unknown> | null;
  } | null;
};

type RpcMessage = {
  id?: number;
  result?: UsageResponse;
  error?: { message?: string };
};

const REQUEST_TIMEOUT_MS = 10_000;

function requestError(message: string | undefined): Error {
  if (message?.toLowerCase().includes("authentication required")) {
    return new Error("Codex account authentication is required to read usage.");
  }
  if (message && /(method not found|unknown method)/i.test(message)) {
    return new Error("This Codex version does not provide the usage lookup.");
  }
  return new Error("Codex usage lookup failed.");
}

function formatPercent(value: number): string {
  return Number.isInteger(value) ? String(value) : value.toFixed(1).replace(/\.0$/, "");
}

export function formatResetTime(epochSeconds: number | null): string {
  if (epochSeconds === null) return "unknown reset time";
  const date = new Date(epochSeconds * 1_000);
  if (Number.isNaN(date.getTime())) return "invalid reset time";
  return date.toISOString().replace("T", " ").replace(".000Z", " UTC");
}

function formatWindow(name: string, window: RateLimitWindow | null): string | null {
  if (!window) return null;
  const remaining = Math.max(0, 100 - window.usedPercent);
  const duration = window.windowDurationMins === null
    ? "unknown window"
    : `${formatPercent(window.windowDurationMins)} min window`;
  return `${name}: ${formatPercent(window.usedPercent)}% used, ${formatPercent(remaining)}% remaining; ${duration}; resets ${formatResetTime(window.resetsAt)}`;
}

function formatReached(snapshot: RateLimitSnapshot): string {
  if (snapshot.rateLimitReachedType) return snapshot.rateLimitReachedType;
  if (snapshot.spendControlReached === true) return "spend control";
  if (snapshot.spendControlReached === false) return "no";
  return "unknown";
}

function formatSnapshot(snapshot: RateLimitSnapshot, heading: string): string[] {
  const lines = [heading];
  for (const [name, window] of [["Primary", snapshot.primary], ["Secondary", snapshot.secondary]] as const) {
    const formatted = formatWindow(name, window);
    if (formatted) lines.push(formatted);
  }
  if (!snapshot.primary && !snapshot.secondary) lines.push("No usage windows reported.");
  lines.push(`Limit reached: ${formatReached(snapshot)}`);
  if (snapshot.individualLimit) {
    lines.push(`Spend limit: ${snapshot.individualLimit.used} of ${snapshot.individualLimit.limit} used, ${formatPercent(snapshot.individualLimit.remainingPercent)}% remaining; resets ${formatResetTime(snapshot.individualLimit.resetsAt)}`);
  }
  return lines;
}

function formatCredits(snapshot: RateLimitSnapshot, response: UsageResponse): string[] {
  const lines: string[] = [];
  if (!snapshot.credits) {
    lines.push("Extra credits: unavailable");
  } else if (snapshot.credits.unlimited) {
    lines.push("Extra credits: unlimited");
  } else if (!snapshot.credits.hasCredits) {
    lines.push("Extra credits: none");
  } else {
    lines.push(`Extra credits: ${snapshot.credits.balance ?? "available"}`);
  }

  const resetCredits = response.rateLimitResetCredits;
  lines.push(resetCredits ? `Rate-limit reset credits: ${String(resetCredits.availableCount)} available` : "Rate-limit reset credits: unavailable");
  return lines;
}

export function formatUsage(response: UsageResponse): string {
  const byId = response.rateLimitsByLimitId ?? {};
  const main = byId.codex ?? response.rateLimits;
  const lines = [`Plan: ${main.planType ?? "unknown"}`, ...formatSnapshot(main, "Codex")];

  const modelLimits = Object.entries(byId)
    .filter(([limitId]) => limitId !== "codex")
    .sort(([left], [right]) => left.localeCompare(right));
  if (modelLimits.length > 0) {
    lines.push("", "Model-specific limits");
    for (const [limitId, snapshot] of modelLimits) {
      lines.push(...formatSnapshot(snapshot, `${snapshot.limitName ?? limitId} (${limitId})`));
    }
  }

  lines.push("", ...formatCredits(main, response));
  return lines.join("\n");
}

async function stopChild(child: ChildProcessWithoutNullStreams): Promise<void> {
  if (child.exitCode !== null) return;
  child.stdin.end();
  child.kill("SIGTERM");
  await Promise.race([
    new Promise<void>((resolve) => child.once("exit", () => resolve())),
    new Promise<void>((resolve) => setTimeout(resolve, 250)),
  ]);
  if (child.exitCode === null) child.kill("SIGKILL");
}

export async function readUsage(timeoutMs = REQUEST_TIMEOUT_MS): Promise<UsageResponse> {
  const child = spawn("codex", ["app-server"], { stdio: ["pipe", "pipe", "pipe"] });
  child.stderr.resume();
  const lines = createInterface({ input: child.stdout });

  try {
    return await new Promise<UsageResponse>((resolve, reject) => {
      const timeout = setTimeout(() => reject(new Error("Codex usage lookup timed out.")), timeoutMs);
      const finish = (action: () => void): void => {
        clearTimeout(timeout);
        action();
      };

      child.once("error", () => finish(() => reject(new Error("Could not start the Codex app-server."))));
      child.once("exit", () => finish(() => reject(new Error("Codex app-server stopped before returning usage."))));
      lines.on("line", (line) => {
        let message: RpcMessage;
        try {
          message = JSON.parse(line) as RpcMessage;
        } catch {
          return;
        }

        if (message.id === 1 && message.error) {
          finish(() => reject(new Error("Could not initialize the Codex usage lookup.")));
          return;
        }
        if (message.id === 1) {
          child.stdin.write(`${JSON.stringify({ id: 2, method: "account/rateLimits/read" })}\n`);
          return;
        }
        if (message.id !== 2) return;

        if (message.error) {
          finish(() => reject(requestError(message.error.message)));
        } else if (message.result) {
          finish(() => resolve(message.result));
        } else {
          finish(() => reject(new Error("Codex returned an invalid usage response.")));
        }
      });

      child.stdin.write(`${JSON.stringify({ id: 1, method: "initialize", params: { clientInfo: { name: "usage-check", version: "1.0" } } })}\n`);
    });
  } finally {
    lines.close();
    await stopChild(child);
  }
}

if (import.meta.main) {
  try {
    console.log(formatUsage(await readUsage()));
  } catch (error) {
    console.error(error instanceof Error ? error.message : "Codex usage lookup failed.");
    process.exitCode = 1;
  }
}
