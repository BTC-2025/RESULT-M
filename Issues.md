# Client Requirements Fulfillment Audit

Date: 2026-06-04

Sources reviewed:
- `ClientRequirements.md`
- Pasted "RESULTS & SOCIAL DISCOURSE ECOSYSTEM" requirements
- Flutter app under `lib/`
- Spring Boot backend under `backend/src/main/java/`
- Existing tests under `test/` and `backend/src/test/java/`

## Overall Verdict

The client requirements are not completely fulfilled yet.

Current project state is a strong scaffold with several real backend modules, but important user-facing workflows are still mocked, partially wired, or missing production-grade security/scaling behavior.

Estimated completion: 50-60%.

## Verification Performed

- `flutter analyze`: passed previously with no issues.
- `flutter build web`: passed previously.
- `flutter test`: passed, but only one smoke test exists.
- Backend Maven tests originally could not run because Java/JDK was not installed or `JAVA_HOME` was not configured on this machine.

Latest P0 pass:
- `flutter analyze`: passed with no issues after P0 fixes.
- JDK 21 was installed and Docker Desktop was started for Testcontainers.
- `backend`: `mvn clean test` passed after backend compile, Flyway, and search SQL fixes.

## Priority Legend

- P0: Must fix before client acceptance / core requirement broken.
- P1: Required for MVP completion.
- P2: Important but can follow after MVP.
- P3: Production hardening / scaling / polish.

---

## P0 Issues

### 1. Create Result Dashboard is mocked, not backend-backed

Status: Completed in P0 pass.

Requirement:
- Authenticated users must create result dashboards/workspaces with public, password-protected, and private visibility.

Evidence:
- `lib/screens/create_workspace_screen.dart` uses `Future.delayed` and locally generates a fake share link.
- It does not call `POST /api/v1/workspaces`.
- It does not persist category/domain, slug, access code, owner, or visibility through the API.

Impact:
- Users cannot actually create a real workspace/dashboard from the app.

Completed:
- Convert `CreateWorkspaceScreen` to `ConsumerStatefulWidget`.
- Add `ApiService.createWorkspace`.
- Send `name`, `slug`, `description`, `visibility`, and `accessCode`.
- Route to the created workspace after success.

Remaining follow-up:
- Optionally call the backend `share-link` endpoint instead of building the public link client-side.

Acceptance:
- Creating a workspace from Flutter creates a row in backend DB.
- Generated public/protected/private links resolve through `/w/:slug`.
- Password-protected workspaces require unlock before result access.

### 2. Admin upload center uses dummy files and dummy dataset id

Status: Completed in P0 pass.

Requirement:
- Support CSV/PDF result ingestion for education, local sports, corporate, tenders, etc.

Evidence:
- `lib/screens/admin/upload_center_screen.dart` creates dummy CSV/PDF bytes.
- It uses dataset id `00000000-0000-0000-0000-000000000000`.
- It marks upload success with `success || true`.
- File picker is not actually used for selecting a real file.

Impact:
- Admins cannot reliably upload real result files into the selected workspace/dataset.

Completed:
- Use `file_picker` to pick actual CSV/PDF files.
- Pass a real `workspaceId` and `datasetId`.
- Remove simulated fallback success.
- Add dataset selection before upload.
- Show backend import job result, failed rows, and validation errors.

Adjustment:
- XLSX is not currently offered in the updated upload UI because backend XLSX support is not implemented.

Acceptance:
- Uploading a real CSV creates records.
- Uploading a real PDF creates an import job and records or returns a clear failure.
- Failed backend upload does not show success.

### 3. Local workspace/result screen is mostly mock data

Status: Completed in P0 pass for real backend workspaces.

Requirement:
- Public and private result dashboards must show real scorecards, tables, rankings, and live updates.

Evidence:
- `lib/screens/local_workspace_screen.dart` uses a dummy dataset id.
- `_isEditor = true` is hardcoded.
- Quick update uses fake record ids such as `record-alpha-id-001`.
- Empty data falls back to mock cricket teams.

Impact:
- Users see simulated result dashboards instead of actual workspace datasets/records.
- Any user may see editor controls in UI.

Completed:
- Fetch real workspace details by id/slug.
- Fetch datasets for the workspace.
- Fetch records for the selected dataset.
- Remove hardcoded fallback scoreboard from production path.

Remaining follow-up:
- Determine editor role from backend membership response instead of showing quick update whenever records exist.

Acceptance:
- Workspace page renders real datasets and records.
- Editor controls appear only for OWNER/ADMIN/EDITOR.
- Empty datasets show an empty state, not fake data.

### 4. Frontend API response parsing mismatches Spring Page responses

Status: Completed in P0 pass.

Requirement:
- Frontend must correctly consume backend APIs.

Evidence:
- Several methods in `lib/services/api_service.dart` cast `response.data` directly to `List<dynamic>`.
- Backend endpoints such as `/workspaces/public`, `/workspaces/{id}/datasets`, and `/datasets/{id}/records` return Spring `Page` objects with a `content` array.

Impact:
- Runtime cast errors are likely when public workspaces, datasets, and records are loaded.

Completed:
- Normalize paginated responses in `ApiService`.
- Use `response.data['content']` for Spring Page endpoints.
- Add helper `_extractList`.

Acceptance:
- Workspace list, dataset list, and record list load without cast errors.

### 5. Dataset and record read access does not fully enforce workspace privacy

Status: Completed in P0 pass for dataset and record read endpoints.

Requirement:
- Object-level security: private/password-protected dashboards must not expose JSON data without valid user/member/token.

Evidence:
- `DatasetService.getDatasetsByWorkspace` comments that visibility checks are assumed elsewhere.
- `DatasetRecordService.getRecords` comments that viewer access is assumed.
- `GET /datasets/{id}` and `GET /records/{recordId}` are permitted by broad GET rules and do not validate workspace visibility.
- Lookup has token checks, but general record/list/detail reads do not consistently enforce them.

Impact:
- Private or password-protected data may be readable through direct dataset/record endpoints.

Completed:
- Add a shared `WorkspaceAccessService`.
- Enforce access for:
  - workspace datasets
  - dataset detail
  - record list
  - record detail
- Require valid member JWT or workspace token where appropriate.

Remaining follow-up:
- Apply the same access rules to search result visibility.

Acceptance:
- Direct API calls cannot read private/protected dataset records without authorization.

### 6. Vote-box password unlock token is not stored or reused by Flutter

Status: Completed in P0 pass.

Requirement:
- Password-protected private vote boxes must be accessible via shared link + access code.

Evidence:
- `ApiService.unlockVoteBox` returns a token.
- `VoteBoxDetailScreen` ignores/punts token persistence and comments say "pretend it was saved".
- `ApiClient` only auto-attaches workspace tokens based on workspace path matching, not vote-box tokens.

Impact:
- Unlock may appear successful, but the next fetch/vote can still be unauthorized.

Completed:
- Add vote-box token storage in `SecureStorage`.
- Store token after unlock.
- Attach `Authorization: Workspace <token>` or a clearer `VoteBox <token>` header for `/votes/{id}` paths.

Acceptance:
- Password-protected vote detail loads after unlock.
- Results and cast vote succeed after unlock without requiring login.

### 7. Public vote listing returns all vote boxes

Status: Completed in P0 pass.

Requirement:
- Public Voting Hub should show active public vote boxes only.

Evidence:
- `VoteBoxService.getPublicVoteBoxes` calls `voteBoxRepository.findAll(pageable)`.

Impact:
- Private/password-protected vote boxes may appear in public feed.

Completed:
- Add repository query for `visibility = PUBLIC AND isActive = true`.
- Exclude closed or deleted boxes as needed.

Acceptance:
- `/api/v1/votes` never returns private/password-protected vote boxes.

### 8. Private vote boxes only require any JWT, not workspace membership

Status: Completed in P0 pass.

Requirement:
- Private/internal content must be viewable strictly by whitelisted users/team members.

Evidence:
- `VoteBoxController` comments say full workspace membership check is omitted.
- Private vote box checks only verify that a user is authenticated.

Impact:
- Any logged-in user may access a private vote box if they know the id.

Completed:
- If vote box is linked to workspace, require membership in that workspace or creator ownership.
- Add repository/service method to validate `WorkspaceMember`.

Acceptance:
- Non-member logged-in users receive 403 for private vote boxes.

---

## P1 Issues

### 9. Complaints require login for POST/vote/comment but UI does not clearly handle unauthenticated users

Status: Completed in P1 complaint auth pass.

Requirement:
- Complaint Box should support social accountability with authenticated actions.

Evidence:
- Backend requires auth for POST complaints, votes, flags, comments.
- Flutter screens allow action attempts but do not consistently redirect to login or show auth-aware UI.

Impact:
- Anonymous users can hit errors instead of a clean login prompt.

Completed:
- Add reusable `AuthGuard.ensureBackendAuth` for protected UI actions.
- Gate complaint create, vote, comment, and flag actions before calling protected APIs.
- Add `/login` and `/signup` routes so protected-action prompts can route users to sign in.
- Update email login/signup to call Spring auth endpoints and persist the backend JWT used by API requests.
- Clear stored backend tokens on logout.

Remaining follow-up:
- Google sign-in still authenticates with Firebase only and does not yet exchange for a Spring JWT.

Acceptance:
- Logged-out users get a clear login prompt for protected actions.

### 10. Complaint media support lacks rich-text support and moderation controls in UI

Status: Completed in P1 complaint rich-text/moderation pass, with production category ownership still a P2 workflow.

Requirement:
- Media support includes rich text, geographical location tags, image/video uploads, and admin-managed status lifecycle.

Implemented:
- Image/video file upload exists.
- Latitude/longitude capture exists.
- Backend has status enum and admin status endpoint.
- Admin UI now has a complaint moderation tab.
- Admin can filter complaints by OPEN, UNDER_REVIEW, or RESOLVED.
- Admin can update complaint status through the backend `PATCH /complaints/{id}/status` endpoint.
- Complaint form now validates media before upload using backend-aligned limits: JPG, PNG, WEBP, MP4, max 5 files, 10MB each.
- Complaint media previews now show file size and per-file validation feedback.
- Complaint form now supports lightweight rich text formatting for bold, italic, code, bullets, and quotes.
- Complaint descriptions are JSON-encoded safely before multipart upload.
- Complaint feed, detail, and admin moderation views render formatted complaint text.
- Admin moderation can filter complaint queues by status and category together.
- Backend complaint listing supports combined category/status filtering.

Missing:
- Dedicated category-owner assignment model is not implemented.

Fix:
- Add assignable category owners if each category must have a named accountable admin/team.

Acceptance:
- Admin can move complaint through OPEN, UNDER_REVIEW, RESOLVED.

### 11. Voting widget is reusable but not fully embedded into result cards

Status: Completed in P1 voting embed/attachment pass.

Requirement:
- VoteBox component must be reusable in voting tab and embedded inside result pages/cards.

Implemented:
- `lib/widgets/embeddable_vote_box.dart` exists.
- Voting Hub tab exists.
- Result record cards now render embedded vote boxes when record JSON includes `voteBoxId`, `voteBoxIds`, `pollId`, or `pollIds`.
- Live workspace records now use `RecordCardFactory`, so domain cards and embedded polls render consistently from backend record data.
- Quick Update now has an Embedded Polls panel for attaching/removing vote box ids on a result record.
- Attached poll ids are saved into record JSON as `voteBoxIds`, which the existing result card renderer embeds.

Missing:
- Backend `vote_boxes` still links polls to workspaces, while record-level attachment is stored in record JSON.

Fix:
- Consider backend `linkedRecordId` if record-level poll ownership/querying/reporting is required.

Acceptance:
- A result dashboard can contain one or more embedded polls.

### 12. Search and global public listings are incomplete

Status: Completed in P1 search/domain pass, with remaining category/feed expansion as P2 scope.

Requirement:
- Public results must be globally searchable.

Implemented:
- Backend search controller/service exists.
- Flutter search screens exist.
- Public workspace listing supports optional dataset-domain filtering through `/api/v1/workspaces/public?domainType=...`.
- Flutter domain feed now calls the implemented public workspace endpoint.
- Scoped search validates workspace visibility before returning private/password-protected workspace results.

Risks/gaps:
- UI still uses many static category models.
- Broader official/global feed automation remains unimplemented.

Completed:
- Align frontend search/category endpoint with backend.
- Ensure global search only returns public results unless scoped workspace access is validated.
- Add domain filter support in backend based on published dataset domain.
- Add integration tests for:
  - public workspace domain filtering
  - public scoped search without login
  - private global-search non-leakage
  - private scoped search rejection for non-members
  - private scoped search access for members

Acceptance:
- Search for a public workspace/dataset/record works.
- Private results never appear to unauthorized users.

### 13. Workspace member/team admin flow is incomplete

Status: Completed in P1 workspace/team pass, with follow-up tests still recommended.

Requirement:
- Private/internal dashboards must support whitelisted team members and encrypted/admin panels.

Implemented:
- Backend has workspace member/invitation entities/controllers/services.
- Admin/manage team screens exist.
- Manage Team now loads real backend members for the selected/owned workspace.
- Owners/admins can invite members, update roles, and remove members through backend APIs.
- Local workspace editor controls now use the current user's backend workspace role.

Missing:
- No evidence of encrypted admin panel beyond HTTPS/JWT assumptions.

Remaining follow-up:
- Add explicit workspace selection in admin shell instead of defaulting to first owned workspace.
- Add tests for OWNER/ADMIN/EDITOR/VIEWER access.

Acceptance:
- Owner can invite members and assign roles.
- Viewer cannot edit scores.

### 14. Auth refresh is simulated/not implemented in Flutter API client

Status: Completed in P1 auth refresh pass.

Evidence:
- `ApiClient._refreshToken` previously returned null with a comment saying it was simulated.

Completed:
- Added backend `POST /api/v1/auth/refresh`.
- Added `RefreshTokenRequest` DTO.
- Backend validates the refresh token, returns a fresh access token, and rotates the refresh token.
- Flutter `ApiClient` now calls `/auth/refresh` on bearer-token 401 responses.
- Refreshed access token, refresh token, and user id are persisted securely.
- Failed requests are retried after refresh.
- Added backend integration coverage for register, login, and refresh.

Remaining follow-up:
- Add token revocation/denylist if logout must invalidate refresh tokens server-side immediately.

Acceptance:
- Expired access token refreshes without losing queued requests.

### 15. Admin settings actions are mocked

Status: Completed in P1 admin settings pass.

Evidence:
- `lib/screens/admin/admin_settings_screen.dart` previously generated demo codes locally.

Completed:
- Admin settings now loads the current/first owned workspace from the backend.
- Regenerate code now calls `POST /api/v1/workspaces/{id}/regenerate-code`.
- The displayed share link and parsed access code refresh after regeneration.

Remaining follow-up:
- Add explicit workspace selection in admin settings when an admin owns multiple workspaces.

Acceptance:
- Regenerate code changes backend access code and old code stops working.

---

## P2 Issues

### 16. Category/domain data is mostly static

Status: Completed for backend-backed workspace/category discovery, with official feed automation still future scope.

Requirement:
- App should cover education, politics, sports, finance, entertainment, tech, law/government bids, local/private/corporate/gaming.

Implemented:
- Static domain/category screens and models exist.
- Home categories now merge backend public workspaces into the existing domain taxonomy.
- Backend-backed workspace entries appear as live subcategories and open the real workspace screen.
- Domain feed queries now use backend enum values such as `EDUCATION`, `SPORTS`, `FINANCE`, `POLITICS`, and `ENTERTAINMENT`.
- Upload-created datasets now map the selected admin category to a backend domain type instead of always using `CUSTOM`.

Missing:
- Real automated feeds for official/global categories.
- No scrapers/webhooks/import jobs for official feeds.

Remaining follow-up:
- Store editable category metadata in backend if admins need to create entirely new top-level categories.
- Add adapters/importers for official feeds as separate jobs.

Acceptance:
- Adding a category/dataset in backend appears in app without code changes.

### 17. Live updates are polling, not real-time streaming

Status: Completed with SSE plus polling fallback.

Requirement:
- Sports/markets/local scoreboards need real-time or streaming updates.

Implemented:
- Flutter polls every 15 seconds.
- Backend now exposes `GET /api/v1/datasets/{datasetId}/records/stream` as an SSE stream.
- Record create/update/delete publishes dataset-level events.
- Flutter live dataset provider subscribes to the SSE stream and refreshes records immediately on events.
- Existing polling remains as a fallback when the stream is unavailable or disconnected.

Missing:
- Dedicated integration test for SSE delivery.

Remaining follow-up:
- Add production heartbeat/reconnect tuning if long-lived stream infrastructure requires it.

Acceptance:
- Score update appears on another device without manual refresh or long polling delay.

### 18. PDF parsing is heuristic and needs production validation

Status: Completed for CSV preview/mapping; PDF review remains production follow-up.

Requirement:
- Large PDF and structured CSV handling for education/jobs.

Implemented:
- PDFBox service exists.
- CSV import service exists.
- Upload Center now previews CSV headers and sample rows before upload.
- Admins can choose the record-key column before importing CSV.
- Flutter sends the selected `recordKeyColumn` to the CSV upload API.
- Backend CSV import uses the selected record-key column, then falls back to common columns like `rollNumber`, `id`, or `studentId`.
- Backend sets record titles from common title/name columns when available.

Risks:
- PDF extraction appears heuristic.
- PDF preview/table mapping is not implemented.
- Failed-row/ambiguous-table handling is still basic.

Remaining follow-up:
- Add PDF parsed-row preview/mapping screen.
- Add import validation report.
- Add rollback or draft import mode.

Acceptance:
- Admin can review CSV rows before publish.

### 19. XLSX is advertised but not supported

Status: Completed by scope correction.

Evidence:
- Current upload UI no longer advertises XLSX.
- Backend has Commons CSV, no Apache POI/XLSX endpoint observed.

Completed:
- XLSX is not offered in the production upload UI until backend ingestion exists.

Acceptance:
- XLSX either works or is not offered.

### 20. Analytics dashboard is mostly static in Flutter admin

Status: Completed for top-level analytics metrics.

Requirement:
- Results space needs heavy read dashboards and analytics.

Evidence:
- Admin dashboard previously displayed hardcoded metrics like "124K" and "2.4M".

Completed:
- Added Flutter API helper for `GET /api/v1/analytics/global`.
- Admin dashboard now loads total views, uploads, records, workspaces, and searches from backend analytics.
- Pull-to-refresh reloads backend analytics.
- Dashboard shows a retryable error state if analytics loading fails.

Remaining follow-up:
- Live dataset shortcuts are still static and should be wired to real workspace/dataset lists.

Acceptance:
- Dashboard metrics reflect real events/lookups/uploads.

### 21. Complaint trending implementation loads all complaints in memory

Status: Completed in complaint feed scaling pass.

Evidence:
- `ComplaintService.getTrendingComplaints` previously used `complaintRepository.findAll()` and sorted in memory.

Completed:
- Added repository-level paged trending query.
- Moved top, newest, category, status, and category+status complaint feeds to paged repository queries.
- Removed Java-side list slicing for complaint feed pagination.

Remaining follow-up:
- Consider a materialized trending score table if complaint volume becomes very large.

Acceptance:
- Trending complaints query stays fast with large datasets.

---

## P3 Issues

### 22. Redis/CDN caching requirement is not implemented

Status: Completed for backend Redis cache readiness; CDN edge/media configuration remains deployment follow-up.

Requirement:
- Heavy read operations need Redis caching and CDN-heavy cache layers.

Evidence:
- Redis dependency/config is now present for production profile.
- Rate limit service explicitly uses in-memory map and comments about migrating to Redis later.

Completed:
- Enabled Spring caching.
- Cached hot public workspace listing queries by domain/page.
- Added cache eviction when workspaces or dataset publication/domain metadata changes.
- Added public HTTP cache headers for `/api/v1/workspaces/public`.
- Added Redis cache dependencies for production deployments.
- Added `application-prod.yml` with Redis host/port/password/SSL, cache TTL, and key-prefix settings.
- Kept local/test default cache as `simple` so development does not require a Redis server.
- Made public HTTP cache TTL/stale-while-revalidate configurable by environment.

Remaining follow-up:
- Add CDN strategy for media and public result JSON.

Acceptance:
- Public result APIs are cached and invalidate correctly after updates.

### 23. Voting/complaint write queue buffering is not implemented

Status: Completed for durable database outbox foundation; external worker/batch aggregation remains production scaling follow-up.

Requirement:
- Complaints/voting need write queues/asynchronous update loops for high concurrent writes.

Implemented:
- Complaint vote and flag counters now use atomic database update queries instead of read-modify-write entity saves.
- Vote toggles and vote changes increment/decrement only the affected counter columns.
- Complaint flag threshold transition to `UNDER_REVIEW` is guarded by a database-side conditional update.
- Vote options already use atomic vote-count increments.
- Added `write_outbox_events` table with pending/processing/processed/failed states, retry metadata, JSON payloads, aggregate indexes, and unique idempotency keys.
- Complaint vote, vote toggle, vote change, complaint flag, and vote-box cast paths now write transactional outbox events beside the counter update.
- Integration tests assert outbox rows are created for complaint voting/flagging and vote-box voting flows.
- Some `@Async` exists for imports/search analytics.

Remaining follow-up:
- Add a scheduled/background outbox worker to batch or ship pending events into Redis, analytics, or an external broker.
- Add client-supplied idempotency keys if duplicate HTTP request protection is required beyond durable event uniqueness.
- Consider Kafka/Rabbit/SQS only if database outbox throughput is not enough in production.

Fix:
- Durable database outbox is in place for complaint and voting writes.
- Add batch worker processing before large-scale production traffic.

Acceptance:
- High-volume voting does not lock hot rows or lose votes.

### 24. React web console is not implemented

Status: Resolved by stack decision: Flutter web is the active web console; React remains optional if the client mandates it.

Requirement:
- Recommended stack includes React.js web console for high-volume visualization dashboards.

Current:
- Flutter app exists for mobile/web.
- Flutter web build is verified with `flutter build web`.
- No separate React console is required by the current repo scope.

Follow-up only if client changes scope:
- Scaffold a separate React visualization console and share the Spring Boot API contracts.

### 25. Backend test coverage is incomplete for new complaint/voting/privacy flows

Status: Completed for requested backend coverage expansion.

Evidence:
- Existing backend tests cover auth/workspace/dataset/csv/search/analytics basics.
- Complaint service integration tests now cover vote toggle/change counter consistency and flag threshold review transition.
- Complaint service integration tests now cover complaint creation with media persistence, anonymous comments, comment counts, and status updates.
- Vote box service integration tests now cover authenticated duplicate vote rejection and anonymous IP/device duplicate throttling.
- Vote box controller integration tests now cover password unlock token access and private creator/workspace-member access.
- Vote box controller token handling was fixed to read `VoteBoxAuthToken` from the active `Authentication`.
- Workspace integration tests now cover private workspace membership enforcement and password-protected access-code/member access.
- Dataset integration tests now cover private dataset read authorization and viewer-vs-admin dataset mutation rules.
- Dataset read service methods were fixed with read-only transactions so permission checks do not fail on lazy workspace loading.
- Global exception handling now preserves `ResponseStatusException` HTTP statuses instead of converting authorization failures to 500s.
- Backend tests now run locally with JDK 21 and Docker Desktop/Testcontainers.

Acceptance:
- `mvn test` passes locally/CI.

### 26. Android development environment is incomplete

Status: Completed.

Evidence:
- Android SDK cmdline-tools package is now installed.
- Flutter Doctor now recognizes platform android-36.1 and build-tools 36.1.0.
- Android SDK licenses are accepted.
- `flutter doctor -v` shows the Android toolchain green.

Fix:
- Accepted Android SDK licenses using Android Studio JDK and the configured SDK path.

Acceptance:
- `flutter doctor` shows Android toolchain green.

### 27. Windows desktop run environment is incomplete

Status: Environment issue.

Evidence:
- Flutter Doctor reports Visual Studio is not installed.
- Chrome web target is available and `flutter build web` passes.

Fix:
- Install Visual Studio Desktop development with C++ workload, or use Chrome/Android targets only.

Acceptance:
- `flutter run -d windows` works if Windows target is required.

---

## Recommended Execution Order

1. Fix frontend API response parsing for Spring Page objects.
2. Wire Create Workspace to backend.
3. Replace upload center dummy flow with real file picker + real dataset selection.
4. Replace local workspace dummy dataset/records with real workspace datasets.
5. Enforce dataset/record workspace access on backend.
6. Fix vote-box token storage and request headers.
7. Fix public vote box filtering and private membership checks.
8. Wire admin/team roles to real backend permissions.
9. Add complaint/voting/private-access integration tests.
10. Add live update transport or keep polling as explicit MVP fallback.
11. Add caching/queue/scaling architecture.
12. Decide React console vs Flutter web console scope.

## MVP Completion Definition

The client requirements can be considered MVP-complete when:

- A user can register/login.
- A user can create a real result workspace.
- A user can create a dataset/schema and upload real CSV/PDF data.
- Public results are searchable and viewable.
- Password-protected results require a valid code/token.
- Private results require membership.
- Admin/editor can update scores.
- Viewer cannot edit scores.
- Complaint feed supports create/media/location/vote/comment/status.
- Voting hub supports public/password/private polls with duplicate-vote protection.
- No mock/dummy paths are used in production flows.
- `flutter analyze`, `flutter test`, `flutter build web`, and backend `mvn test` pass.
