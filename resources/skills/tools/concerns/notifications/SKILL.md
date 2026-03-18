# Notification System

<!-- category: template -->

## Overview

Architecture for multi-channel notifications: push, in-app, email, with user
preferences, batching, delivery guarantees, and cross-device sync.

## Push Notification Architecture

```
                  +------------------+
                  |  Notification    |
                  |  Service         |
                  +--------+---------+
                           |
              +------------+------------+
              |            |            |
         +----v----+  +---v----+  +---v-----+
         | Web Push|  |  FCM   |  |  APNs   |
         |  (VAPID)|  |(Android)|  | (iOS)   |
         +---------+  +--------+  +---------+
```

### Web Push API

```typescript
// Service worker: handle push events
self.addEventListener('push', (event) => {
  const data = event.data?.json() ?? {};
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body, icon: data.icon, tag: data.tag,
      data: { url: data.url }, actions: data.actions,
    })
  );
});

// Server: send via web-push library with VAPID credentials
import webpush from 'web-push';
webpush.setVapidDetails('mailto:admin@example.com', VAPID_PUBLIC, VAPID_PRIVATE);
await webpush.sendNotification(subscription, JSON.stringify({ title, body, url, tag }));
```

## Notification Types

| Type            | Channel            | Examples                              |
|-----------------|--------------------|---------------------------------------|
| Transactional   | Push + Email       | Order confirmation, password reset    |
| Social          | Push + In-app      | Mentions, replies, follows            |
| Marketing       | Email (opt-in)     | Newsletters, promotions               |
| System          | In-app + Banner    | Maintenance, policy changes           |

- Transactional notifications must always be delivered — never suppress
- Marketing requires explicit opt-in (CAN-SPAM, GDPR)
- System notifications bypass user preferences (except quiet hours)

## Notification Center UI

- Unread count badge in header; notification panel as dropdown or sidebar
- Group related notifications by `groupKey` (e.g., "3 comments on your PR")
- Mark as read on click; "mark all as read" bulk action
- Paginate or virtualize long lists; show relative timestamps

## User Preferences & Settings

- Allow per-category, per-channel toggles (e.g., social: push+email, marketing: email only)
- Support quiet hours (start/end time + timezone); queue non-urgent during quiet hours
- Offer email digest frequency: immediate, hourly, daily, weekly, never
- Provide one-click unsubscribe in every email (required by CAN-SPAM, GDPR)

## Batching & Digest

- Group notifications by `groupKey` within a time window (e.g., 5 minutes)
- For email: collect into periodic digests (hourly/daily) instead of per-event
- Show collapsed summary in notification center: "Alice and 4 others commented"
- Use a delayed job queue (Bull, SQS, Cloud Tasks) with configurable batch windows

## Real-Time Delivery & Cross-Device Sync

- Use WebSocket for instant in-app delivery; show toast if tab is active, push if background
- Store notification state server-side (read/unread, dismissed)
- Broadcast read-state changes to all connected devices via WebSocket
- Fetch missed notifications since last sync timestamp on reconnect

## Delivery Pipeline

- Route: Event -> Preference Check -> Quiet Hours -> Channel Dispatch -> Provider -> Device
- Implement per-user rate limits to prevent notification fatigue
- Retry failed deliveries with exponential backoff; dead-letter after N attempts
- Log delivery status for each notification (sent, delivered, opened, failed)

## Common Pitfalls

- Sending too many notifications — users disable all notifications permanently
- Not batching — 20 separate emails for 20 comments in 5 minutes
- Missing unsubscribe mechanism — legal violation (CAN-SPAM, GDPR)
- Ignoring quiet hours — 3am push notifications destroy user trust
- Client-only read state — loses sync across devices
- No delivery tracking — impossible to debug "I never got the notification"
