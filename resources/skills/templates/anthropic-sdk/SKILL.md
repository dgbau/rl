# Anthropic SDK Skill

<!-- category: template -->

## Overview
The `@anthropic-ai/sdk` is the official TypeScript/JavaScript SDK for the Anthropic API.
Supports streaming responses, tool use (function calling), vision, and extended thinking.
The API is stateless — full message history is sent with every request.
[FILL: How the Anthropic SDK is used in THIS project — features, models, integration pattern]

## Core Setup
```bash
pnpm add @anthropic-ai/sdk
```
- API key: `ANTHROPIC_API_KEY` env var (SDK reads it automatically — never hardcode)
- Client: `new Anthropic()` — no config needed if env var is set
- For Electron: set key in main process env, not renderer
- Version: [FILL: SDK version used]

## Models
| Model | ID | Best For |
|-------|----|----------|
| Opus 4.6 | `claude-opus-4-6` | Complex reasoning, planning |
| Sonnet 4.6 | `claude-sonnet-4-6` | Best balance of speed + capability |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Fast, cheap — classification, extraction |

- Use Haiku for simple routing/classification, Sonnet for user-facing chat, Opus for complex code gen
- Cost: Opus ~5x Sonnet ~4x Haiku per token
[FILL: Which model(s) used and why]

## Streaming
**Always stream for user-facing chat.** Non-streaming only for background/batch.
```typescript
const stream = client.messages.stream({
  model: 'claude-sonnet-4-6', max_tokens: 4096,
  system: systemPrompt, messages,
});
stream.on('text', (text) => { /* incremental chunks */ });
const final = await stream.finalMessage();
```
- Pass `{ signal: abortController.signal }` as second arg for cancellation
- Handle `stream.on('error')` — unhandled errors crash the process
- Always abort streams on user navigation to avoid wasted tokens
[FILL: Streaming pattern in THIS project]

## Tool Use (Function Calling)
```typescript
const response = await client.messages.create({
  model, max_tokens, tools: [{
    name: 'tool_name', description: '...',
    input_schema: { type: 'object', properties: { ... }, required: [...] },
  }],
  messages,
});
// Check response.content for type: 'tool_use' blocks
// Send results back as type: 'tool_result' in next user message
```
[FILL: Tools defined in THIS project, if any]

## Vision
- Supports PNG, JPEG, GIF, WebP — max 5MB per image
- Send as `{ type: 'image', source: { type: 'base64', media_type, data } }`
- Or URL: `{ type: 'image', source: { type: 'url', url } }`
[FILL: Vision usage in THIS project]

## Error Handling
- `Anthropic.APIError` with `.status`: 400 (bad request), 401 (auth), 429 (rate limit), 529 (overloaded), 500 (server)
- 429/529 are retryable — SDK has built-in retries (configurable via `maxRetries`)
- Always catch streaming errors separately via `stream.on('error')`
[FILL: Error handling strategy]

## System Prompts
- Separate `system` parameter — NOT a message in the messages array
- Sent with every request (stateless API)
- Keep focused — counts toward context window
[FILL: System prompt strategy and location]

## Structured Output
Ask Claude to output JSON in tagged code blocks for parsing:
````
```json:type-name
{ ... }
```
````
Parse with regex: `/```json:(\S+)\s*\n([\s\S]*?)```/g`
[FILL: Structured output patterns in THIS project]

## Where to Look
- SDK client: [FILL: Path to AI service/client code]
- System prompts: [FILL: Path to prompt templates]
- Types: [FILL: Path to AI-related type definitions]
- Docs: https://docs.anthropic.com/en/docs
- SDK: https://github.com/anthropics/anthropic-sdk-typescript

## Common Pitfalls
- API is stateless — must send full message history every request
- `role: 'system'` in messages array is wrong — use the `system` parameter
- Not aborting streams on navigation — leaked streams waste tokens
- Exceeding context window silently — truncate old messages for long conversations
- Using Opus for simple tasks — 5x cost with marginal improvement for easy work
