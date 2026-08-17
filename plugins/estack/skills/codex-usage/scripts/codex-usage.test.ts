import { describe, expect, test } from "bun:test";

import { formatResetTime, formatUsage, type UsageResponse } from "./codex-usage";

const fixture: UsageResponse = {
  rateLimits: {
    limitId: "codex",
    limitName: "Codex",
    primary: { usedPercent: 32.5, windowDurationMins: 300, resetsAt: 1_800_000_000 },
    secondary: { usedPercent: 80, windowDurationMins: null, resetsAt: null },
    credits: { hasCredits: false, unlimited: false, balance: null },
    individualLimit: null,
    spendControlReached: null,
    planType: "plus",
    rateLimitReachedType: null,
  },
  rateLimitsByLimitId: {
    codex: {
      limitId: "codex",
      limitName: "Codex",
      primary: { usedPercent: 32.5, windowDurationMins: 300, resetsAt: 1_800_000_000 },
      secondary: null,
      credits: { hasCredits: false, unlimited: false, balance: null },
      individualLimit: null,
      spendControlReached: false,
      planType: "plus",
      rateLimitReachedType: null,
    },
    codex_bengalfox: {
      limitId: "codex_bengalfox",
      limitName: "GPT-5.3-Codex-Spark",
      primary: { usedPercent: 12, windowDurationMins: 1440, resetsAt: 1_800_086_400 },
      secondary: null,
      credits: null,
      individualLimit: null,
      spendControlReached: null,
      planType: null,
      rateLimitReachedType: null,
    },
  },
  rateLimitResetCredits: { availableCount: 0, credits: [] },
};

describe("formatUsage", () => {
  test("reports main and model-specific usage with computed remaining percentages", () => {
    const output = formatUsage(fixture);
    expect(output).toContain("32.5% used, 67.5% remaining");
    expect(output).toContain("12% used, 88% remaining");
    expect(output).toContain("GPT-5.3-Codex-Spark (codex_bengalfox)");
    expect(output).toContain("Limit reached: no");
    expect(output).toContain("Limit reached: unknown");
    expect(output).toContain("Extra credits: none");
    expect(output).toContain("Rate-limit reset credits: 0 available");
  });

  test("renders reset epochs and null optional fields", () => {
    expect(formatResetTime(1_800_000_000)).toBe("2027-01-15 08:00:00 UTC");
    expect(formatResetTime(null)).toBe("unknown reset time");
    expect(formatUsage({ ...fixture, rateLimitsByLimitId: null, rateLimitResetCredits: null })).toContain("Rate-limit reset credits: unavailable");
  });
});
