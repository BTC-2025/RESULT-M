# Home Functional Roadmap

This Home screen should be treated as the consumer command center: live result pills at the top, a personalized social feed below, and composer actions that create real server-side objects.

## Keep

- Live result pills for sports, elections, academics, finance, tech, and local dashboards.
- Unified timeline for updates, complaints, polls, image posts, and result announcements.
- Separate Results area for full structured result dashboards.
- Login optional for browsing and basic posting where policy allows it.

## Remove Or Avoid

- Full sports scorecards inside the Home feed.
- Hardcoded demo payloads in active routes.
- Silent fake API fallbacks in production.
- One giant Home file where UI, ranking, media rules, and composer logic are mixed.
- Client-only security decisions. The client can validate, but the backend must enforce.

## Build Order

1. Split Home presentation into smaller widgets without changing behavior.
2. Add a real feed contract: `GET /feed`, `POST /posts`, `POST /complaints`, `POST /polls`, `POST /posts/{id}/media`.
3. Add cursor pagination per tab so For You, Complaints, Polls, Trending, and Following each keep position and cache independently.
4. Add media upload pipeline: validate, compress, upload to object storage, then attach media IDs to posts.
5. Add interaction APIs: like, upvote, downvote, bookmark, share event, report, comment.
6. Add live pill source: WebSocket/SSE for live workspaces with HTTP fallback.
7. Add personalization from onboarding interests, followed publishers, language, location, and interaction history.
8. Add moderation and safety: rate limits, anonymous complaint rules, report queue, duplicate detection, blocked words, media scanning.
9. Add analytics events behind `ENABLE_ANALYTICS`, with no PII in event names or raw payloads.
10. Add offline/cache behavior: cached feed first, background refresh, retry queue for failed posts.

## Home API-Ready Boundaries

- `lib/features/home/domain`: enums and pure models.
- `lib/features/home/application`: ranking, filtering, upload policy, pagination state, composer validation.
- `lib/features/home/data`: API DTOs, repositories, local cache.
- `lib/features/home/presentation`: widgets only.

## Security Requirements

- Auth token stored only in secure storage.
- Anonymous complaint still gets abuse controls server-side.
- File uploads must use signed URLs, content-type checks, size limits, and virus/moderation scanning.
- Feed write APIs require CSRF-safe/mobile-safe token validation, rate limiting, and device/session abuse checks.
- Poll votes require idempotency keys and server-side duplicate prevention.

## First Functional Milestone

Home is considered functional when:

- It loads feed data from a repository, with mock mode controlled only by `USE_MOCK_FEED`.
- Posting an update, complaint, and poll creates local optimistic UI state and can later call the API.
- Tab filtering/ranking is tested.
- Media selection rejects unsafe files before upload.
- No Home UI code knows raw API JSON shapes.
