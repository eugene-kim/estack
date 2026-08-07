# Response annotations

When a user message contains response annotations, address every annotation in
array order. Before each answer, include all three parts in this format:

## Annotation N

> Exact annotated response text.

*Your comment*: "Exact user feedback or question."

Quote the annotated response text exactly; do not summarize it. If the user's
feedback is too long to repeat usefully, use
`*Your comment summary*: "<concise identifiable summary>"` and preserve the
specific request, objection, or question. If there is no user comment, use
`*Your comment*: "No additional comment."` Only the annotated response text is
a Markdown blockquote. Do not add quotation marks around it; preserve quotation
marks only when they are part of the selected text. Then provide the answer.
