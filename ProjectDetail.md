# ResultHub – Complete Architecture & Technical Specification (v1.1)

This document is the authoritative, up-to-date technical, product, and architectural specification for the ResultHub full-stack platform. It details the Flutter frontend, the Spring Boot backend, the generic PostgreSQL JSONB database architecture, security strategy, dynamic rendering policy, state management, and the complete file-by-file module mapping as of **June 2026**.

---

## 1. System Architecture Overview

ResultHub is a highly scalable, multi-tenant, multi-domain data publishing platform with three distinct pillars:

| Pillar | Description |
|---|---|
| **A – Results Space** | Live score & exam results publishing via generic JSONB datasets |
| **B – Complaint Box** | Reddit-style public complaint feed with media uploads, voting, comments, and admin moderation |
| **C – Voting Hub** | Public/Private/Password-protected polls with real-time results, fingerprint-based anti-spam, and embeddable widgets |

### Technical Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter SDK 3.44.0, Material 3, Google Fonts (Inter), Riverpod 3.x (Notifier / AsyncNotifier), Dio 5.9, go_router 16 (StatefulShellRoute) |
| **Backend** | Spring Boot 3.5, Java 21, Maven 3.9 |
| **Database** | PostgreSQL 16+ — GIN-indexed JSONB, declarative partitioning, Full-Text Search, optimistic locking (`@Version`) |
| **Security** | Stateless JWT (1-day access / 7-day refresh), Google OAuth2, Bucket4j IP rate limiting, Workspace token filter |
| **Async Reliability** | Transactional Outbox Pattern (`write_outbox_events`) for guaranteed event delivery |
| **Migrations** | Flyway (V1 → V10) |
| **Testing** | JUnit 5 + Testcontainers (PostgreSQL 16 Singleton pattern) |
| **PDF Import** | Apache PDFBox multipart upload pipeline |
| **Media Storage** | Local filesystem via `ComplaintMediaService` (configurable path) |

---

## 2. Complete File-by-File Module Directory

### 2.1 Backend Modules (`backend/src/main/java/com/resulthub/api/`)

#### 📂 Root
- **ResultHubApplication.java** — Spring Boot bootstrap entry point.

---

#### 📂 `com.resulthub.api.analytics`
- **AnalyticsController.java** — REST endpoints for global and workspace-specific telemetry aggregation.
- **AnalyticsEvent.java** *(entity)* — Maps the month-partitioned `analytics_events` table; uses `@JdbcTypeCode(SqlTypes.NAMED_ENUM)` and `@JdbcTypeCode(SqlTypes.JSON)`.
- **EventType.java** *(enum)* — `DATASET_VIEW`, `SEARCH`, `WORKSPACE_VIEW`, etc.
- **ChartDataPoint.java** *(dto)* — Single time-series chart datum (label, value).
- **GlobalAnalyticsResponse.java** *(dto)* — Platform-wide aggregated metrics.
- **WorkspaceAnalyticsResponse.java** *(dto)* — Per-workspace visit and popularity metrics.
- **AnalyticsEventRepository.java** — CRUD + native aggregation SQL queries.
- **AnalyticsTrackingService.java** — Asynchronous `@Async` event ingestion.
- **WorkspaceAnalyticsService.java** — Business logic for chart aggregation.

---

#### 📂 `com.resulthub.api.auth`
- **AuthController.java** — Register, login, logout, refresh-token endpoints.
- **AuthService.java** — BCrypt password hashing, JWT generation, user validation, Google OAuth2 user provisioning.
- **AuthRequest.java** *(dto)* — Login payload (email, password).
- **AuthResponse.java** *(dto)* — JWT credentials + user metadata response.
- **RegisterRequest.java** *(dto)* — Registration payload (name, email, password).

---

#### 📂 `com.resulthub.api.common.exception`
- **ErrorResponse.java** — Standardized error JSON model (timestamp, status, error, message, path).
- **GlobalExceptionHandler.java** — `@ControllerAdvice` handling all exceptions without leaking stack traces. Covers: `EntityNotFoundException`, `AccessDeniedException`, `MethodArgumentNotValidException`, `ConstraintViolationException`, `DataIntegrityViolationException`, `ObjectOptimisticLockingFailureException`, `RateLimitExceededException`, `PayloadTooLargeException`, `UnsupportedMediaTypeException`, and generic `RuntimeException`.
- **RateLimitExceededException.java** — Thrown when Bucket4j throttle is crossed (→ HTTP 429).
- **PayloadTooLargeException.java** — Thrown when upload exceeds size limits (→ HTTP 413).
- **UnsupportedMediaTypeException.java** — Thrown for invalid file MIME types (→ HTTP 415).

---

#### 📂 `com.resulthub.api.complaint`

**Pillar B: Complaint Box** — Full Reddit-style complaint board.

- **ComplaintController.java** *(controller)* — REST endpoints:
  - `GET /api/v1/complaints` — Public feed with `?sort=trending|top|new`, category and status filters, pagination.
  - `GET /api/v1/complaints/{id}` — Single complaint with comments and vote counts.
  - `POST /api/v1/complaints` — JWT-required; multipart form data with optional images.
  - `POST /api/v1/complaints/{id}/vote` — Up/down vote with toggle support.
  - `POST /api/v1/complaints/{id}/comments` — JWT-required; add a comment.
  - `PATCH /api/v1/complaints/{id}/status` — Admin-only status change (`OPEN` → `UNDER_REVIEW` → `RESOLVED`).
  - `POST /api/v1/complaints/{id}/flag` — Flag for moderation.
- **Complaint.java** *(entity)* — Maps `complaints` table. Fields: `id`, `creatorId`, `category`, `title`, `description`, `mediaUrls` (TEXT[]), `latitude`, `longitude`, `locationName`, `status`, `isAnonymous`, `flagCount`, `upvotes`, `downvotes`, `netScore`.
- **ComplaintVote.java** *(entity)* — Maps `complaint_votes` with `VoteType` enum (`UP`, `DOWN`). Unique constraint on (complaint_id, voter_id).
- **ComplaintComment.java** *(entity)* — Maps `complaint_comments` with `creatorId`, `content`, `isAnonymous`.
- **ComplaintRepository.java** — JPA + native paginated queries with trending/top/new sort modes.
- **ComplaintVoteRepository.java** — Finds existing votes per user per complaint.
- **ComplaintCommentRepository.java** — Finds comments by complaint ID.
- **ComplaintService.java** — Core business logic: vote toggle, optimistic update, status management, flagging.
- **ComplaintMediaService.java** — Handles multipart image upload to local filesystem; enforces `PayloadTooLargeException` and `UnsupportedMediaTypeException` guards.
- **CreateComplaintRequest.java** *(dto)* — Multipart complaint creation payload.
- **CastVoteRequest.java** *(dto)* — `{ voteType: UP|DOWN }`.
- **ComplaintResponse.java** *(dto)* — Full complaint API response including vote counts, user vote state, and media URLs.
- **ComplaintCommentResponse.java** *(dto)* — Comment list item response.

---

#### 📂 `com.resulthub.api.config`
- **ApplicationConfig.java** — BCrypt encoder, `UserDetailsService`, Jackson `ObjectMapper` bean.
- **WebConfig.java** — CORS configuration, Bucket4j rate limit interceptor registration, MVC configuration.

---

#### 📂 `com.resulthub.api.csv`
- **CsvImportController.java** — Multipart CSV upload endpoint; spawns async import jobs.
- **ImportJob.java** *(entity)* — Tracks job status and error summary.
- **UploadedFile.java** *(entity)* — Tracks filename, size, and storage path.
- **ImportStatus.java** *(enum)* — `QUEUED`, `PROCESSING`, `COMPLETED`, `FAILED`.
- **ImportJobResponse.java** / **ImportSummary.java** / **UploadResponse.java** *(dto)* — Job tracking payloads.
- **ImportJobRepository.java** / **UploadedFileRepository.java** — JPA repositories.
- **CsvImportService.java** — Apache Commons CSV stream parsing with 1,000-row batch inserts.

---

#### 📂 `com.resulthub.api.dataset`
- **DatasetController.java** — CRUD for workspace datasets (create, update, publish, archive).
- **DatasetRecordController.java** — Insert, edit, retrieve, and paginate individual JSONB records.
- **Dataset.java** *(entity)* — Maps `datasets` table; uses `@JdbcTypeCode(SqlTypes.NAMED_ENUM)` for `status` and `domainType`.
- **DatasetSchema.java** *(entity)* — JSON Draft-7 schema definition for record validation.
- **DatasetRecord.java** *(entity)* — Generic data store; maps PostgreSQL `JSONB` to `Map<String, Object>` via `@JdbcTypeCode(SqlTypes.JSON)`. Includes `@Version` field for optimistic locking (added in V9 migration).
- **DatasetStatus.java** *(enum)* — `DRAFT`, `PUBLISHED`, `ARCHIVED`.
- **DomainType.java** *(enum)* — `ACADEMIC`, `SPORT`, `FINANCE`, `POLITICS`, `LAW`, `ENTERTAINMENT`, `TECH`, `GOVERNMENT`, `HYPERLOCAL`.
- **DatasetRequest.java** / **DatasetResponse.java** / **RecordRequest.java** / **RecordResponse.java** / **DatasetSchemaRequest.java** / **DatasetSchemaResponse.java** *(dto)* — CRUD payload models.
- **DatasetRepository.java** / **DatasetRecordRepository.java** / **DatasetSchemaRepository.java** — JPA repositories.
- **DatasetService.java** — Access governance, CRUD logic, visibility enforcement.
- **DatasetRecordService.java** — Insert/update records, trigger text-search vector updates.
- **DatasetSchemaService.java** — Associates JSON schemas to datasets.
- **SchemaValidationService.java** — Validates records against Draft-7 schemas using `com.networknt.schema`.

---

#### 📂 `com.resulthub.api.outbox`

**Transactional Outbox Pattern** — Guarantees reliable event delivery even in crash scenarios.

- **WriteOutboxEvent.java** *(entity)* — Maps `write_outbox_events` table; holds `aggregateType`, `aggregateId`, `eventType`, and `payload` (JSON).
- **WriteOutboxEventRepository.java** — JPA repository for outbox events.
- **WriteOutboxPublisher.java** — Scheduled publisher that reads unprocessed outbox events and dispatches them.

---

#### 📂 `com.resulthub.api.pdf`
- **PdfImportController.java** — Multipart PDF upload endpoint; delegates to `PdfImportService`.
- **PdfImportService.java** *(service)* — Apache PDFBox text extraction pipeline, creating dataset records from parsed PDF content.

---

#### 📂 `com.resulthub.api.search`
- **SearchController.java** — Global search with suggestions and full-text results.
- **SearchAnalytics.java** *(entity)* — Stores anonymous query logs.
- **SearchResult.java** / **SearchSuggestion.java** / **PaginatedSearchResponse.java** *(dto)* — Search response payloads.
- **SearchRepository.java** — Native SQL `UNION ALL` full-text search with visibility joins.
- **SearchAnalyticsRepository.java** — Query log repository.
- **SearchService.java** — Routes queries and processes suggestions asynchronously.

---

#### 📂 `com.resulthub.api.security`
- **JwtAuthenticationFilter.java** — Extracts and validates JWTs; registers user on Spring Security context.
- **JwtService.java** — Signs, parses, and validates stateless JWT tokens.
- **RateLimitInterceptor.java** — Bucket4j IP-based interceptor; bypasses `ADMIN` users.
- **RateLimitService.java** — Configures token bucket structures (100 req/min per IP default).
- **SecurityConfig.java** — Registers filters, disables CSRF, configures Google OAuth2, sets path protection policies.

---

#### 📂 `com.resulthub.api.user`
- **User.java** — Identity model mapped to `users` table; credentials, roles, Google OAuth fields.
- **UserRole.java** *(enum)* — `ADMIN`, `USER`.
- **UserRepository.java** — CRUD for `users`.

---

#### 📂 `com.resulthub.api.voting`

**Pillar C: Voting Hub** — Public/private/password-protected polls.

- **VoteBoxController.java** *(controller)* — REST endpoints:
  - `GET /api/v1/votes` — Public vote box feed (paginated).
  - `GET /api/v1/votes/{id}` — Detail; respects `PUBLIC` / `PASSWORD_PROTECTED` / `PRIVATE` visibility.
  - `POST /api/v1/votes` — JWT-required; create vote box with options.
  - `POST /api/v1/votes/{id}/cast` — Cast a vote; public boxes allow anonymous (IP/fingerprint 24h anti-spam), private requires JWT.
  - `GET /api/v1/votes/{id}/results` — Option counts and percentages.
  - `POST /api/v1/votes/{id}/unlock` — Unlock password-protected box; returns `Workspace <token>`.
- **VoteBox.java** *(entity)* — Maps `vote_boxes`; includes `visibility`, `accessCodeHash`, `endsAt`, `creatorId`.
- **VoteOption.java** *(entity)* — Individual option within a vote box.
- **VoteResponse.java** *(entity)* — Stores a single cast vote; tracks `voterId` (nullable for anonymous), `ipAddress`, and `deviceFingerprint`.
- **VoteBoxRepository.java** / **VoteOptionRepository.java** / **VoteResponseRepository.java** — JPA repositories.
- **VoteBoxService.java** — Voting logic: expiry check (→ 410 Gone), visibility access, anti-spam duplicate detection, result aggregation.
- **CastVoteRequest.java** *(dto)* — `{ optionId, deviceFingerprint }`.
- **CreateVoteBoxRequest.java** *(dto)* — Vote box creation with list of option texts, visibility, end date.
- **UnlockVoteBoxRequest.java** *(dto)* — `{ accessCode }`.
- **VoteBoxResponse.java** *(dto)* — Full poll response including options, vote counts, user's selection state.
- **VoteResultsResponse.java** *(dto)* — Per-option result with count and percentage.
- **TokenResponse.java** *(dto)* — `{ token }` returned on successful unlock.

---

#### 📂 `com.resulthub.api.workspace`
- **WorkspaceController.java** — CRUD for workspace registration, visibility overrides, member management, slug-based lookup, and workspace token unlock.
- **MemberController.java** — Workspace member invitations and role changes.
- **Workspace.java** *(entity)* — Name, slug, `VisibilityMode`, `accessCodeHash`, owner, `domainType`.
- **WorkspaceMember.java** *(entity)* — Join table mapping user ↔ workspace with `WorkspaceRole`.
- **WorkspaceInvitation.java** *(entity)* — Pending invitation with secure token.
- **VisibilityMode.java** *(enum)* — `PUBLIC`, `PASSWORD_PROTECTED`, `PRIVATE`.
- **WorkspaceRole.java** *(enum)* — `OWNER`, `ADMIN`, `EDITOR`, `VIEWER`.
- **CreateWorkspaceRequest.java** / **UpdateWorkspaceRequest.java** / **WorkspaceResponse.java** / **InviteMemberRequest.java** / **InvitationResponse.java** / **MemberResponse.java** *(dto)* — Workspace API payloads.
- **WorkspaceRepository.java** / **WorkspaceMemberRepository.java** / **WorkspaceInvitationRepository.java** — JPA repositories.
- **WorkspaceService.java** — Visibility enforcement, slug generation, access code BCrypt hashing, workspace-token issuance.
- **WorkspaceMemberService.java** — Member role management.
- **WorkspaceInvitationService.java** — Secure invitation generation and redemption.

---

### 2.2 Frontend Modules (`lib/`)

#### 📂 `main.dart`
Application entry point: initializes `WidgetsBinding`, bootstraps Firebase, applies `AppTheme`, and mounts `ProviderScope` with `go_router`.

---

#### 📂 `core/`

| File | Purpose |
|---|---|
| `core/network/api_client.dart` | Dio singleton with interceptors: JWT injection from secure storage, 401-triggered token refresh, timeout handling. |
| `core/storage/secure_storage.dart` | `flutter_secure_storage` wrapper for JWT and workspace tokens. |
| `core/routing/app_router.dart` | `GoRouter` with `StatefulShellRoute.indexedStack` for 4 independent bottom-nav stacks. Deep links: `/w/:slug`, `/workspace/:id`, `/complaints/:id`, `/votes/:id`. Auth routes: `/login`, `/signup`. |
| `core/providers/workspace_unlock_provider.dart` | `Notifier<WorkspaceUnlockStateData>` managing workspace password-unlock flow state. |
| `core/auth/auth_guard.dart` | Route guard redirecting unauthenticated users to `/login`. |
| `core/theme/app_theme.dart` | Material 3 `ThemeData` with Google Fonts Inter, custom color scheme, and component overrides. |

---

#### 📂 `models/`

| File | Purpose |
|---|---|
| `domain_model.dart` | `DomainType` enum (academic, sport, government, politics, finance, entertainment, tech, law, hyperLocal); subcategory and availability data catalog. |
| `result_model.dart` | Academic result record (student name, roll number, grades, GPA, subjects). |
| `govt_model.dart` | Government exam result (roll number, candidate, marks, rank, selection status). |
| `complaint_model.dart` | `ComplaintModel` PODO; `copyWith` supporting optimistic vote updates (`upvotes`, `downvotes`, `netScore`, `hasUserVoted`). |
| `complaint_comment_model.dart` | `ComplaintCommentModel` — comment display data. |
| `vote_box_model.dart` | `VoteBoxModel`, `VoteOptionModel`, `VoteResultsModel`; `copyWith` for optimistic vote casting. |

---

#### 📂 `services/`

| File | Purpose |
|---|---|
| `api_service.dart` | All REST calls to Spring Boot: workspaces, datasets, records, search, analytics, complaints (CRUD, vote, comment), vote boxes (CRUD, cast, results, unlock), media upload. Riverpod `Provider` exposed as `apiServiceProvider`. |
| `auth_service.dart` | Firebase email/password auth and Google Sign-In (v7 `GoogleSignIn.instance` API). |

---

#### 📂 `providers/`

All notifiers updated to **Riverpod 3.x** (`Notifier` / `AsyncNotifier` / `FamilyAsyncNotifier`):

| File | Class | Provider Type | Purpose |
|---|---|---|---|
| `badge_notifier.dart` | `BadgeNotifier` | `Notifier<BadgeState>` | Tracks unread complaint count (vs. last-visit timestamp in secure storage) and active-polls indicator. |
| `complaint_feed_notifier.dart` | `ComplaintFeedNotifier` | `Notifier<ComplaintFeedState>` (family: `String` sortType) | Paginated complaint feed per tab (trending/top/new); optimistic vote updates; filter by category/status. |
| `domain_feed_notifier.dart` | `DomainFeedNotifier` | `FamilyAsyncNotifier<List<DomainFeedItem>, DomainType>` | Fetches public workspaces by domain, then datasets and records; polls every 15s for sport/politics domains. |
| `live_dataset_notifier.dart` | `LiveDatasetNotifier` | `StateNotifier<AsyncValue<List>>` (family: `String` datasetId) | Live record polling with `WidgetsBindingObserver` for pause/resume lifecycle awareness. |
| `voting_hub_notifier.dart` | `VotingHubNotifier` | `Notifier<VotingHubState>` | Paginated public poll feed; optimistic vote casting with device fingerprint; `addVoteBoxOptimistic`. |
| `dynamic_domains_provider.dart` | — | `FutureProvider` | Fetches available domain types for the home feed grid. |

---

#### 📂 `screens/` — Core Navigation

| File | Purpose |
|---|---|
| `splash_screen.dart` | Animated entry screen (scale + opacity), navigates to `/onboarding` after 3 seconds. |
| `onboarding_screen.dart` | Category interest selection (animated chips); saves preferences to `SharedPreferences`. |
| `main_shell.dart` | `StatefulShellRoute` shell — `NavigationBar` with 4 tabs: Results, Complaints, Voting, Profile. Badge overlay on Complaints and Voting tabs driven by `badgeProvider`. |
| `home_screen.dart` | Primary results dashboard: domain shortcut grid, trending scorecards, live updates, featured workspaces. |
| `login_screen.dart` | Email/password + Google Sign-In portal. Uses `context.go()` for go_router navigation. |
| `signup_screen.dart` | Registration form with validation. |
| `forgot_password_screen.dart` | Password recovery via Firebase. |
| `search_screen.dart` | Search with real-time autocomplete and recent history. |
| `search_results_screen.dart` | Full-text search results with polymorphic card rendering. |
| `bookmarks_screen.dart` | Locally saved records via `SharedPreferences`. |
| `profile_screen.dart` | Account details, login state gates, navigation to sub-pages. |
| `credential_screen.dart` | Result lookup gate (Roll Number, DOB input) before showing records. |
| `result_detail_screen.dart` | Scorecard: `domainName`, `icon`, `recordData` (generic JSONB map), `datasetName`. Screenshot + share. |
| `govt_detail_screen.dart` | Government exam result detail view. |
| `local_workspace_screen.dart` | Workspace detail view: subcategory list, published datasets, record browser. |
| `workspace_resolver_screen.dart` | Slug-based workspace resolver handling Public / Password / Private routing. |
| `password_unlock_screen.dart` | Password entry screen for `PASSWORD_PROTECTED` workspaces. Accepts optional `initialCode`. |
| `subcategory_screen.dart` | Category subcategory directory with tab-based navigation. Routes to domain-specific screens. |
| `create_workspace_screen.dart` | Wizard to create workspace (name, domain, visibility, optional access code). |
| `notifications_screen.dart` | System notifications list. |

---

#### 📂 `screens/complaints/` — Pillar B UI

| File | Purpose |
|---|---|
| `complaint_feed_screen.dart` | 3-tab feed (Trending / Top / New); category and status filter chips; infinite scroll; FAB → `CreateComplaintScreen`; pull-to-refresh. |
| `complaint_detail_screen.dart` | Full complaint view with up/down voting, comment thread, media gallery, status badge, report/flag action. |
| `create_complaint_screen.dart` | Multipart complaint creation: category, title, description, location picker (map), media upload, anonymous toggle. |

---

#### 📂 `screens/voting/` — Pillar C UI

| File | Purpose |
|---|---|
| `voting_hub_screen.dart` | 2-tab layout (Public Polls / My Polls); infinite scroll; FAB → `CreateVoteBoxScreen`; pull-to-refresh. |
| `vote_box_detail_screen.dart` | Poll detail: visibility badge, expiry countdown, option list (pre-vote), animated result bars (post-vote), share button. Handles password-protected unlock flow. |
| `create_vote_box_screen.dart` | Poll creation wizard: title, description, options list (add/remove), visibility, optional end date, optional access code. |

---

#### 📂 `screens/admin/` — Admin Pillar

| File | Purpose |
|---|---|
| `admin_scaffold.dart` | Left navigation shell for admin views. |
| `admin_dashboard_screen.dart` | Analytics dashboard with view trajectories, dataset status overview, and chart widgets. |
| `upload_center_screen.dart` | CSV and file upload: file picker, column validation preview, multipart import to backend. |
| `manage_results_screen.dart` | Full-form JSONB record editor for manual data entry/editing. |
| `quick_score_entry_screen.dart` | **Fast numeric-only entry screen** for live field use (cricket scorer, election volunteer). Fetches existing record, renders numeric fields with `+`/`-` step buttons and long-press acceleration. PATCH debounced to backend. |
| `manage_team_screen.dart` | Workspace member role management (EDITOR / ADMIN / VIEWER). |
| `admin_settings_screen.dart` | System settings: validation constraints, credential overrides, workspace sharing. |
| `complaint_moderation_screen.dart` | Admin complaint moderation: status transition controls (`OPEN` → `UNDER_REVIEW` → `RESOLVED`), flag review queue. |

---

#### 📂 `screens/profile_pages/`

| File | Purpose |
|---|---|
| `personal_details_screen.dart` | Edit username and profile parameters. |
| `my_workspaces_screen.dart` | Workspaces owned or managed by the user. |
| `notifications_settings_screen.dart` | Notification category toggles. |
| `recently_viewed_screen.dart` | Browsing history tracking. |
| `language_screen.dart` | Language preference selection. |
| `help_center_screen.dart` | User support and FAQ. |
| `legal_screen.dart` | Terms, Privacy Policy, open-source licenses. |

---

#### 📂 `widgets/`

| File | Purpose |
|---|---|
| `record_card_factory.dart` | **Polymorphic JSONB card renderer** — maps `DomainType` to domain-specific card layouts (sport score, finance ticker, politics vote bar, law verdict, entertainment rank, tech benchmark). Falls back to generic key-value card. |
| `complaint_card.dart` | Reusable complaint list item: title, category badge, location tag, description preview (3-line), media thumbnail strip, up/down vote buttons with optimistic update, comment count, status badge. |
| `vote_box_card.dart` | Reusable poll card: title, description, visibility badge, vote count, real-time countdown timer (`Timer`), expired "Closed" badge. |
| `embeddable_vote_box.dart` | Standalone embeddable poll widget (usable inside other screens): fetches its own data, shows voting or results inline, uses `votingHubProvider` for casting. |
| `rich_text_content.dart` | Markdown-aware text renderer for complaint descriptions. |

---

## 3. Navigation & Routing Architecture

ResultHub uses **go_router 16 with `StatefulShellRoute.indexedStack`** to maintain independent navigation stacks per tab.

### Bottom Navigation Tabs

| Index | Tab | Root Path | Screen |
|---|---|---|---|
| 0 | Results | `/` | `HomeScreen` |
| 1 | Complaints | `/complaints` | `ComplaintFeedScreen` |
| 2 | Voting | `/votes` | `VotingHubScreen` |
| 3 | Profile | `/profile` | `ProfileScreen` |

### Deep Links (Root Navigator — preserves back stack)

| Path | Destination |
|---|---|
| `/splash` | `SplashScreen` |
| `/onboarding` | `OnboardingScreen` |
| `/login` | `LoginScreen` |
| `/signup` | `SignupScreen` |
| `/w/:slug?code=` | `WorkspaceResolverScreen` (slug + optional unlock code) |
| `/workspace/:id?name=` | `LocalWorkspaceScreen` |
| `/complaints/:id` | `ComplaintDetailScreen` |
| `/votes/:id` | `VoteBoxDetailScreen` |

### Badge System
`BadgeNotifier` tracks:
- **Complaints**: Counts new complaints since last visit (timestamp stored in `FlutterSecureStorage`). Cleared when Complaints tab is selected.
- **Voting**: Active polls indicator (`hasActivePolls` boolean). Shown as dot badge on Voting tab.

---

## 4. Database Architecture & Migrations

### 4.1 Relational-Document Layout

- **Generic JSONB Engine**: `dataset_records.data` stores arbitrary JSON, indexed via GIN.
- **Full-Text Search**: `search_vector` (`tsvector`) is auto-updated by a PostgreSQL trigger on INSERT/UPDATE of workspaces, datasets, and records.
- **GIN Wildcard Index**: Registered over `search_vector` for instant prefix matches.
- **Optimistic Locking**: `dataset_records` includes a `@Version` column; concurrent record edits resolve via `ObjectOptimisticLockingFailureException` (→ HTTP 409) without database-level locks.
- **Declarative Partitioning**: `analytics_events` partitioned by month on `created_at`.
- **Transactional Outbox**: `write_outbox_events` guarantees event delivery atomically within the same transaction as the business write.

### 4.2 Flyway Migrations Catalog

| Migration | Description |
|---|---|
| `V1__init_users_table.sql` | `users` table with credentials and roles. |
| `V2__init_workspace_tables.sql` | `workspaces`, `workspace_members`, `workspace_invitations`, visibility enums. |
| `V3__init_dataset_tables.sql` | `datasets`, `dataset_schemas`, `dataset_records` (JSONB). |
| `V4__init_csv_import_tables.sql` | `import_jobs`, `uploaded_files`. |
| `V5__init_search_and_analytics.sql` | `search_vector` column, GIN index, FTS trigger, `search_analytics`. |
| `V6__init_analytics_tables.sql` | Partitioned `analytics_events` table. |
| `V7__create_complaints_schema.sql` | `complaints`, `complaint_votes`, `complaint_comments`. |
| `V8__create_voting_schema.sql` | `vote_boxes`, `vote_options`, `vote_responses`. |
| `V9__add_version_to_dataset_records.sql` | Adds `version` column to `dataset_records` for optimistic locking. |
| `V10__create_write_outbox.sql` | `write_outbox_events` table for Transactional Outbox pattern. |

---

## 5. Security Architecture

### 5.1 Authentication & Authorization
- **JWT**: Short-lived access tokens (1-day) + refresh tokens (7-day). Refresh rotates on use.
- **RBAC**: System-level `ADMIN` / `USER` roles. Workspace-level `OWNER` / `ADMIN` / `EDITOR` / `VIEWER` roles.
- **Google OAuth2**: Integrated via Spring Security + Firebase Auth on the Flutter side.
- **CORS**: Restricted to configured staging/production origins.

### 5.2 Workspace Visibility Gates
| Mode | Access Rule |
|---|---|
| `PUBLIC` | Open to all; no token required. |
| `PASSWORD_PROTECTED` | Requires `Authorization: Workspace <token>` header; token obtained via `/unlock` endpoint. |
| `PRIVATE` | Requires JWT + verified workspace membership. |

### 5.3 Bucket4j Rate Limiting
- 100 requests/minute per IP (public endpoints).
- Authenticated `ADMIN` users bypass throttling.
- Violations → HTTP 429 via `RateLimitExceededException`.

### 5.4 Anti-Spam Voting
- **Authenticated users**: Checked against `vote_responses` by `voterId`.
- **Anonymous users**: Checked by IP address + device fingerprint within 24-hour window.
- **Expired polls**: Return HTTP 410 Gone.

### 5.5 Error Sanitization
- All exceptions handled by `GlobalExceptionHandler`.
- Zero stack trace leakage to clients in production.
- Generic HTTP status codes with clean JSON responses.

---

## 6. Flutter Dependencies (`pubspec.yaml`)

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.3.1 | State management (Notifier / AsyncNotifier) |
| `dio` | ^5.9.0 | HTTP client with interceptors |
| `go_router` | ^16.0.0 | Declarative routing + `StatefulShellRoute` |
| `flutter_secure_storage` | ^10.0.0-beta | JWT + workspace token persistence |
| `google_fonts` | ^8.1.0 | Inter font family |
| `shared_preferences` | ^2.5.5 | Bookmarks and user preferences |
| `file_picker` | ^10.3.2 | CSV and file selection |
| `share_plus` | 12.0.2 | Native share sheet |
| `screenshot` | ^3.0.0 | Result card screenshot capture |
| `url_launcher` | ^6.3.2 | External link opening |
| `firebase_core` | ^4.9.0 | Firebase initialization |
| `firebase_auth` | ^6.5.1 | Firebase authentication |
| `google_sign_in` | ^7.2.0 | Google OAuth (v7 API) |
| `path_provider` | ^2.1.5 | Local filesystem paths |
| `flutter_map` | ^8.3.0 | OpenStreetMap location picker |
| `latlong2` | ^0.9.1 | Geo coordinates |
| `geolocator` | ^14.0.2 | Device GPS |
| `video_player` | ^2.11.1 | Media playback for complaint attachments |
| `device_info_plus` | ^12.4.0 | Device fingerprint for anti-spam voting |
| `crypto` | ^3.0.7 | MD5 fingerprint hashing |
| `carousel_slider` | ^5.1.2 | Image carousel for complaint media |
| `marquee` | ^2.3.0 | Scrolling ticker text |

---

## 7. Staging & SRE Testing Protocols

### 7.1 Testcontainers Integration Tests
- Dockerized **PostgreSQL 16** spun up per JVM lifecycle (Singleton container pattern).
- Tests cover: Flyway migrations, FTS triggers, JSONB validation, partitioning, CSV batch imports, complaint/voting flows.

### 7.2 CI/CD Pipeline
- **GitHub Actions**: Compile + Testcontainer validation on every push to `main`.
- **Docker Build**: Multi-stage Alpine image for the Spring Boot JAR.
- **Flutter Web**: Static bundle deployed to CDN for public edge delivery.
- **Git Remotes**: Dual-push configured — `origin` (Faiz-7716/ResultPublisher) and `company` (BTC-2025/RESULT-M).

---

## 8. API Surface Summary

| Category | Endpoints |
|---|---|
| **Auth** | `POST /register`, `POST /login`, `POST /logout`, `POST /refresh` |
| **Workspace** | `GET/POST/PUT/DELETE /workspaces`, `POST /workspaces/{id}/unlock`, `GET /workspaces/slug/:slug` |
| **Members** | `POST /workspaces/{id}/invite`, `GET/PATCH /workspaces/{id}/members` |
| **Dataset** | `GET/POST/PUT/DELETE /datasets/{id}`, `POST /datasets/{id}/publish`, `POST /datasets/{id}/archive` |
| **Records** | `GET/POST/PUT/PATCH /datasets/{id}/records`, `GET /datasets/{id}/records/{recordId}` |
| **CSV Import** | `POST /csv/upload`, `GET /csv/import-jobs/{id}` |
| **PDF Import** | `POST /pdf/import` |
| **Search** | `GET /search?q=&type=&page=`, `GET /search/suggestions` |
| **Analytics** | `GET /analytics/workspace/{id}`, `GET /analytics/global` |
| **Complaints** | `GET/POST /complaints`, `GET /complaints/{id}`, `POST /complaints/{id}/vote`, `POST /complaints/{id}/comments`, `PATCH /complaints/{id}/status`, `POST /complaints/{id}/flag` |
| **Voting** | `GET/POST /votes`, `GET /votes/{id}`, `POST /votes/{id}/cast`, `GET /votes/{id}/results`, `POST /votes/{id}/unlock` |
