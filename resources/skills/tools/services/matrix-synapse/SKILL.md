# Matrix Protocol & Synapse Homeserver

<!-- category: template -->

## Overview

Decentralized, federated communication using the Matrix protocol, Synapse
homeserver deployment, client SDKs, end-to-end encryption, and bridging.

## Matrix Protocol Fundamentals

- **Federation**: Homeservers replicate room state across domains via Server-Server API
- **DAG-based events**: Room history forms a directed acyclic graph, not a linear log
- **State resolution**: Conflicts between federated servers resolved algorithmically (v2 state res)
- **Room IDs**: `!opaque:server.tld` — immutable, globally unique
- **User IDs**: `@user:server.tld`
- **Event types**: `m.room.message`, `m.room.member`, `m.room.create`, `m.room.power_levels`

## Synapse Homeserver Setup

- Deploy via Docker: `matrixdotorg/synapse:latest` with PostgreSQL (not SQLite in production)
- Generate config: `docker run --rm matrixdotorg/synapse generate`
- Reverse proxy with nginx/Caddy; serve `.well-known/matrix/server` and `/client`
- Configure `homeserver.yaml`: URL previews, rate limiting, media storage limits

### Workers Mode (Scaling)

- Split into worker processes: sync, federation sender, media repo, push
- Use Redis for inter-worker communication; all workers share PostgreSQL

## Client-Server API

```typescript
import { createClient } from 'matrix-js-sdk';

const client = createClient({
  baseUrl: 'https://matrix.example.com',
  userId: '@bot:example.com',
  accessToken: process.env.MATRIX_ACCESS_TOKEN,
});

await client.startClient({ initialSyncLimit: 20 });

client.on('Room.timeline', (event, room) => {
  if (event.getType() === 'm.room.message') {
    console.log(`[${room.name}] ${event.getSender()}: ${event.getContent().body}`);
  }
});
```

- Use `matrix-js-sdk` for Node.js bots and web clients
- Use `matrix-react-sdk` as the foundation for Element-like UIs
- Sync loop (`/sync`) is the primary data flow — long-poll for updates

## Room Management

- Create rooms with `createRoom()` — set visibility, preset (private/public/trusted)
- Power levels control who can send events, invite, kick, ban
- Room aliases (`#room:server.tld`) are human-friendly pointers to room IDs
- Spaces are rooms that organize other rooms hierarchically (`m.space.child`)
- Use room versioning to upgrade rooms to newer state resolution algorithms

## End-to-End Encryption (E2EE)

- **Olm**: 1:1 sessions (double ratchet, like Signal protocol)
- **Megolm**: Group sessions (one outbound session per room per device)
- **Cross-signing**: Users verify their own devices; others verify the user
- **Key backup**: Encrypted server-side backup of Megolm keys (SSSS)

```typescript
// Enable E2EE on room creation
await client.createRoom({
  initial_state: [{
    type: 'm.room.encryption',
    state_key: '',
    content: { algorithm: 'm.megolm.v1.aes-sha2' },
  }],
});
```

- Verify devices via emoji comparison or QR code scanning
- Key sharing: devices request keys from other devices in the room
- Bootstrap cross-signing and key backup during initial device setup

## Application Services (Bridges)

- Bridges connect Matrix to Slack, Discord, IRC, Telegram, Signal
- Register via `registration.yaml` (app service token, homeserver token, namespace regex)
- Popular implementations: mautrix (Python), matrix-appservice-bridge (Node.js)

## Media & Sliding Sync

- Media via `/_matrix/media/v3/upload` and `/download`; use S3-compatible store in production
- Configure `max_upload_size` in `homeserver.yaml`; thumbnails generated server-side
- Sliding Sync (MSC3575): efficient partial room list, replaces full `/sync`
- Alternatives: Dendrite (Go, lower resources), Conduit (Rust, single-binary)

## Common Pitfalls

- Forgetting `.well-known` delegation — federation will not work without it
- Not setting up key backup — users lose message history on new devices
- SQLite in production — locks under concurrent load; migrate to PostgreSQL
- Unbounded media storage — set retention policies and size limits
