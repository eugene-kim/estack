---
name: investigate
description: Investigate a reported failure, incident, unexpected behavior, or reference ID to determine what happened and why, then assess whether a concrete telemetry improvement would make the next investigation faster. Use when the user asks to investigate, diagnose, trace, or explain an operational issue.
---

# Investigate

Find the strongest evidence-backed explanation for what happened. Treat the investigation as read-only unless the user also asks for a fix.

## Approach

- Anchor the investigation on the exact incident details the user provided: reference or request ID, route, action, time, environment, and visible error. Do not replace those details with a broader search when a precise correlation key exists.
- Start with the system's operational evidence, such as logs, exceptions, traces, analytics, request metadata, and session replay. Follow project-specific observability guidance and inspect event schemas before writing queries.
- Correlate the incident across the request lifecycle and relevant system boundaries. Use repository code to explain the recorded behavior, not as a substitute for production evidence.
- Build a traceable chain from the user-visible symptom through the recorded failure to the responsible code path, query, dependency, or data condition. Separate established facts from inference and state the confidence of the conclusion.
- Test plausible competing explanations when the evidence permits it. Do not stop at the first matching error message or assign a root cause only because a nearby code path looks suspicious.
- If the evidence cannot establish a root cause, give the narrowest supported conclusion and identify exactly what is unknowable. Do not invent certainty to complete the report.

## Inline telemetry review

After reaching the root cause or the strongest supported conclusion, assess how well the available telemetry supported this investigation in the same response.

- Name the signals that led to the conclusion and any detours, ambiguity, or manual correlation the investigation required.
- Recommend a telemetry change only when a specific missing, misleading, or hard-to-correlate signal made this investigation slower or left an important question unanswered.
- Tie each recommendation to the observed gap. State what should be recorded or rendered, where in the lifecycle it belongs, and how it would shorten a similar investigation. Check that the signal does not already exist before proposing it.
- Consider the whole path when relevant: user-visible reference and safe error state, correlation identifiers, request outcome, phase timing, query or dependency context, exception details and source maps, and the fields needed to find the event efficiently. Treat these as prompts, not a required checklist.
- Do not create a generic observability wish list. If the existing telemetry produced a direct and complete evidence chain without costly detours, say **No telemetry change required** and explain briefly why.
- Surface recommendations only. Do not implement the product fix or telemetry changes unless the user asks.

## Result

Lead with what happened and why. Include the evidence that supports it, the confidence and remaining uncertainty, and the inline telemetry assessment. Distinguish the underlying product issue from any telemetry opportunity so neither is mistaken for the other.
