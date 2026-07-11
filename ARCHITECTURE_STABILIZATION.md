# ResultHub Stabilization Plan

## Current Decision

ResultHub is a two-sided product:

- Consumer side: social feed, live result campaigns, polls, complaints, discussions, search, profile.
- Publisher side: organization onboarding, result publishing, live result entry, dataset upload, moderation, analytics.

The app must not grow by adding one-off pages for every idea. New work should reuse shared domain models, shared feed cards, shared result campaign renderers, and role-based routing.

## Immediate Rules

- Mock data belongs only in `lib/dev/` or behind explicit environment flags.
- API services must not silently return fake data when the backend fails.
- User-facing routes must not contain hardcoded sample result payloads.
- Large screens should be split once they exceed a maintainable boundary.
- Consumer and publisher flows must remain visually and architecturally separate.

## Environment Flags

- `USE_MOCK_FEED=true`: show local home feed fixture for UI review.
- `USE_MOCK_FEED=false`: start Home from real provider state.
- `USE_OFFLINE_API_FALLBACKS=true`: allow old offline API samples for demos only.
- `USE_OFFLINE_API_FALLBACKS=false`: fail honestly when backend/API is broken.
- `ENABLE_REALTIME=true`: reserved for websocket/SSE/live updates.
- `ENABLE_ANALYTICS=true`: reserved for analytics events.

## UI / UX

Keep:
- Bottom nav: Home, Results, Explore, Profile.
- Home as social feed with post, poll, complaint, result campaign cards.
- Live circles only for active result/live campaigns.
- Dense result pages for domain-specific data.

Remove or avoid:
- Marketing-style pages inside the app.
- Decorative screens that do not perform real user workflows.
- Fake sports/result cards mixed into feed unless they are explicit mock fixtures.
- Duplicate search/navigation experiences.

Next:
- Split `home_screen.dart` into smaller widgets.
- Create a unified empty/loading/error state system.
- Define one design language for feed, result hubs, admin, and forms.

## Frontend

Keep:
- Riverpod for state.
- GoRouter shell for app navigation.
- Shared feed models and reusable cards.

Fix:
- Split large screens:
  - `home_screen.dart`
  - `results_hub_screen.dart`
  - `feed_post_widgets.dart`
- Remove route-level fake data.
- Move all mock fixtures into `lib/dev/`.
- Make feature folders: `feed`, `results`, `complaints`, `polls`, `publisher`, `profile`.

## Backend

Required APIs:
- Auth/session.
- Feed timeline.
- Post create/read/update/delete.
- Poll create/vote/results.
- Complaint create/vote/comment/status.
- Result campaign create/publish/list/detail.
- Dataset upload/search/record lookup.
- Organization/workspace management.

Rules:
- API failures must surface as errors.
- No fake fallback data in production service methods.
- Backend contracts must be documented before UI expands.

## Data & Storage

Core entities:
- User
- Organization
- Workspace
- FeedItem
- Post
- Poll
- Complaint
- ResultCampaign
- Dataset
- ResultRecord
- Notification

Storage:
- Secure tokens in secure storage.
- Cache read-only feed/results later, but do not fake server truth.
- Media upload should use backend-issued upload URLs or multipart endpoint.

## Real-Time

Use realtime only where it matters:
- Live sports scores.
- Election counting.
- Poll vote counts.
- Complaint status updates.
- Result campaign publishing alerts.

Preferred path:
- Start with polling refresh.
- Add SSE or WebSocket after backend contracts are stable.
- Keep realtime isolated in a `RealtimeService`.

## Security

Must have:
- Role-based access: user, publisher, moderator, admin.
- Publisher-only result publishing.
- Complaint abuse controls and moderation.
- Token refresh and logout handling.
- Protected admin routes.
- Server-side validation for all writes.

Avoid:
- Trusting client role flags.
- Letting anonymous complaint creation bypass abuse checks.
- Storing sensitive data in shared preferences.

## Infra & DevOps

Needed:
- `.env` or dart-define strategy for API base URL and flags.
- Separate dev/staging/prod configs.
- Backend health endpoint.
- Reproducible backend start command.
- CI checks: Flutter analyze, backend tests, build.

Short-term:
- Keep `flutter analyze` green after every cleanup.
- Remove generated build reports from source control.
- Stop committing local IDE/build artifacts.

## Growth & Analytics

Track later, not before core flows work:
- Feed impression.
- Post create.
- Poll vote.
- Complaint raise.
- Result campaign open.
- Search query.
- Publisher follow.
- Share action.

Do not add analytics until:
- Event names are defined.
- Privacy rules are defined.
- User consent/legal text is ready.

## Cleanup Sequence

1. Remove unused old screens and generated helper files.
2. Isolate mock data behind environment flags.
3. Disable silent API sample fallbacks by default.
4. Split large UI files.
5. Remove route-level hardcoded result payloads.
6. Stabilize one vertical slice: create poll -> feed -> vote -> backend -> refresh.
7. Stabilize result campaign flow: create campaign -> publish -> show live circle -> detail page.
8. Add realtime only after backend contracts work.
