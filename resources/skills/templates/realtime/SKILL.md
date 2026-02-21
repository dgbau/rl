# Real-Time Communication

<!-- category: template -->

## Overview

Patterns for building real-time features: live updates, presence, messaging,
and collaboration with reliable delivery and graceful degradation.

## Architecture

[FILL: WebSocket / Server-Sent Events (SSE) / Long-Polling]

### Selection Guidance

| Approach    | Direction      | Best For                         | Reconnect |
|-------------|--------------- |----------------------------------|-----------|
| WebSocket   | Bidirectional  | Chat, collaboration, gaming      | Manual    |
| SSE         | Server → Client| Live feeds, notifications, logs  | Automatic |
| Long-Polling| Bidirectional  | Legacy fallback, firewall issues | Manual    |

## Library

[FILL: Socket.IO / Ably / Pusher / LiveKit / Liveblocks / PartyKit / Supabase Realtime]

## Connection Lifecycle

```typescript
class RealtimeConnection {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private heartbeatId: ReturnType<typeof setInterval> | null = null;

  connect(url: string) {
    this.ws = new WebSocket(url);
    this.ws.onopen = () => { this.reconnectAttempts = 0; this.startHeartbeat(); };
    this.ws.onclose = (e) => { this.stopHeartbeat(); if (!e.wasClean) this.reconnect(url); };
    this.ws.onerror = () => { this.ws?.close(); };
  }

  private reconnect(url: string) {
    if (this.reconnectAttempts >= 10) return;
    const delay = Math.min(1000 * 2 ** this.reconnectAttempts, 30000);
    setTimeout(() => { this.reconnectAttempts++; this.connect(url); }, delay * (0.5 + Math.random() * 0.5));
  }

  private startHeartbeat() {
    this.heartbeatId = setInterval(() => {
      if (this.ws?.readyState === WebSocket.OPEN) this.ws.send('{"type":"ping"}');
    }, 30000);
  }

  private stopHeartbeat() { if (this.heartbeatId) clearInterval(this.heartbeatId); }
}
```

- Reconnect with exponential backoff + jitter; heartbeat detects silent disconnects
- Handle `visibilitychange`: pause heartbeat when tab is hidden

## Presence & Typing Indicators

- Broadcast presence periodically; expire on server-side timeout (e.g., 60s)
- Typing indicator: debounce with ~2s timeout to avoid flooding
- Throttle cursor position updates to ~20/sec max for collaborative cursors

## Message Ordering & Delivery Guarantees

- Assign server-side monotonic sequence IDs to each message
- Client tracks last received sequence ID; requests backfill on reconnect
- For at-least-once delivery: client ACKs messages; server retries unACKed
- For exactly-once semantics: use idempotency keys on message processing
- Use CRDTs (Yjs, Automerge) for conflict-free collaborative editing

## Offline Queue & Sync

- Queue outbound messages while offline; flush in order on reconnect
- Persist queue to IndexedDB for durability across page reloads
- Resolve conflicts using last-write-wins, operational transforms, or CRDTs (Yjs, Automerge)

## Scaling

- Use sticky sessions (IP hash or cookie) for WebSocket load balancing
- Pub/sub backend (Redis Pub/Sub, NATS, Kafka) for cross-server message fanout
- Shard rooms/channels across server instances
- Monitor: active connections per server, message throughput, fan-out latency
- Consider managed services (Ably, Pusher) to avoid operational complexity

## Common Pitfalls

- Not implementing reconnection logic — users see stale data silently
- Missing heartbeat — idle connections get killed by proxies/load balancers (often ~60s)
- Flooding the server with per-keystroke events — always debounce/throttle
- Assuming message order on the client without server-assigned sequence IDs
- Not handling tab visibility — background tabs waste resources and battery
