# ResultHub – Complete Architecture & Technical Specification

This document serves as the complete technical, product, and architectural specification for the ResultHub full-stack platform. It details the Flutter frontend, the Spring Boot backend, the generic PostgreSQL JSONB database architecture, security strategies, dynamic rendering policies, and the complete file-by-file module mapping.

---

## 1. System Architecture Overview

ResultHub is a highly scalable, multi-tenant, multi-domain data publishing platform. Unlike traditional applications that use rigid schemas for different data types (e.g., a `cricket_scores` table vs. an `exam_results` table), ResultHub relies on a **Generic JSONB Publishing Engine** supporting multiple visibility modes and role-based access control.

### Technical Stack:
*   **Frontend:** Flutter SDK 3.44.0 (Material 3, Google Fonts Inter text theme) with Riverpod (State Management) and Dio (HTTP client with caching, interceptors, and error handlers).
*   **Backend:** Spring Boot 3.5 (Java 21) running on a native JVM.
*   **Database:** PostgreSQL 16+ utilizing GIN-indexed `JSONB` columns, declarative month-based partitioning for analytics logging, and native Full-Text Search.
*   **Security:** Stateless JWT Authentication, Google OAuth2, CORS configuration, and Bucket4j IP-based rate limiting interceptor.
*   **Database Migrations:** Flyway Migrations (Versions `V1` to `V6`).
*   **Testing:** JUnit 5 integration tests powered by Dockerized PostgreSQL 16 Testcontainers utilizing a Singleton Container Pattern.

---

## 2. Complete File-by-File Module Directory

The physical codebase consists of two distinct subsystems: the Java REST API backend and the Dart/Flutter client frontend.

### 2.1 Backend Modules (`backend/src/main/java/com/resulthub/api/`)

#### 📂 Package: `com.resulthub.api`
*   [ResultHubApplication.java](file:///backend/src/main/java/com/resulthub/api/ResultHubApplication.java): The Spring Boot bootstrap class that launches the application server.

#### 📂 Package: `com.resulthub.api.analytics`
*   [AnalyticsController.java](file:///backend/src/main/java/com/resulthub/api/analytics/AnalyticsController.java): REST controller exposing analytical and telemetry data aggregation endpoints for global dashboard metrics and workspace-specific metrics.
*   [AnalyticsEvent.java](file:///backend/src/main/java/com/resulthub/api/analytics/entity/AnalyticsEvent.java): Entity mapping the partitioned `analytics_events` table. Uses `@JdbcTypeCode(SqlTypes.NAMED_ENUM)` for the custom event type mapping, and `@JdbcTypeCode(SqlTypes.JSON)` for the metadata column.
*   [EventType.java](file:///backend/src/main/java/com/resulthub/api/analytics/enums/EventType.java): Enumeration defining analytics events (`DATASET_VIEW`, `SEARCH`, `WORKSPACE_VIEW`, etc.).
*   [ChartDataPoint.java](file:///backend/src/main/java/com/resulthub/api/analytics/dto/ChartDataPoint.java): DTO holding a single time-series charting data point (label, value).
*   [GlobalAnalyticsResponse.java](file:///backend/src/main/java/com/resulthub/api/analytics/dto/GlobalAnalyticsResponse.java): DTO carrying global analytics metrics including total views, active workspaces, and aggregated trend lines.
*   [WorkspaceAnalyticsResponse.java](file:///backend/src/main/java/com/resulthub/api/analytics/dto/WorkspaceAnalyticsResponse.java): DTO returning metrics specific to a single workspace (e.g. dataset popularity, daily visits).
*   [AnalyticsEventRepository.java](file:///backend/src/main/java/com/resulthub/api/analytics/repository/AnalyticsEventRepository.java): Interface for CRUD database operations and customized aggregation native SQL queries.
*   [AnalyticsTrackingService.java](file:///backend/src/main/java/com/resulthub/api/analytics/service/AnalyticsTrackingService.java): Service processing asynchronous telemetry events via `@Async` annotation.
*   [WorkspaceAnalyticsService.java](file:///backend/src/main/java/com/resulthub/api/analytics/service/WorkspaceAnalyticsService.java): Business logic service performing aggregation queries mapped to chart data structures.

#### 📂 Package: `com.resulthub.api.auth`
*   [AuthController.java](file:///backend/src/main/java/com/resulthub/api/auth/AuthController.java): REST endpoints for client onboarding, registration, login token generation, and refresh token rotation.
*   [AuthService.java](file:///backend/src/main/java/com/resulthub/api/auth/AuthService.java): Core service that handles password registration using BCrypt hashing, JWT generation, and User validation.
*   [AuthRequest.java](file:///backend/src/main/java/com/resulthub/api/auth/dto/AuthRequest.java): Request payload DTO for user login (email, password).
*   [AuthResponse.java](file:///backend/src/main/java/com/resulthub/api/auth/dto/AuthResponse.java): Response payload DTO returning JWT credentials (accessToken, refreshToken, and basic user metadata).
*   [RegisterRequest.java](file:///backend/src/main/java/com/resulthub/api/auth/dto/RegisterRequest.java): Payload validation class for user registrations (name, email, password).

#### 📂 Package: `com.resulthub.api.common.exception`
*   [ErrorResponse.java](file:///backend/src/main/java/com/resulthub/api/common/exception/ErrorResponse.java): Standardized error JSON response model (timestamp, status code, error, message, request path) mapping all API errors.
*   [GlobalExceptionHandler.java](file:///backend/src/main/java/com/resulthub/api/common/exception/GlobalExceptionHandler.java): Production-grade centralized `@ControllerAdvice` handling all standard exceptions without leaking JVM stack traces or SQL logs to clients.
*   [RateLimitExceededException.java](file:///backend/src/main/java/com/resulthub/api/common/exception/RateLimitExceededException.java): Custom RuntimeException thrown when rate limiting thresholds are crossed.

#### 📂 Package: `com.resulthub.api.config`
*   [ApplicationConfig.java](file:///backend/src/main/java/com/resulthub/api/config/ApplicationConfig.java): Instantiates the BCrypt password encoder, the Spring Security UserDetailsService, and the custom Jackson ObjectMapper.
*   [WebConfig.java](file:///backend/src/main/java/com/resulthub/api/config/WebConfig.java): Global configuration enabling cross-origin requests (CORS) and registering the Bucket4j rate limiting interceptor across the application endpoints.

#### 📂 Package: `com.resulthub.api.csv`
*   [CsvImportController.java](file:///backend/src/main/java/com/resulthub/api/csv/CsvImportController.java): Multipart upload endpoint accepting CSV streams, validating the client role, and immediately spawning async jobs.
*   [ImportJob.java](file:///backend/src/main/java/com/resulthub/api/csv/entity/ImportJob.java): Entity mapping the status and validation error summary log paths for background CSV tasks.
*   [UploadedFile.java](file:///backend/src/main/java/com/resulthub/api/csv/entity/UploadedFile.java): Tracks binary size, original filename, and location details of uploaded files.
*   [ImportStatus.java](file:///backend/src/main/java/com/resulthub/api/csv/enums/ImportStatus.java): State enum mapping jobs (`QUEUED`, `PROCESSING`, `COMPLETED`, `FAILED`).
*   [ImportJobResponse.java](file:///backend/src/main/java/com/resulthub/api/csv/dto/ImportJobResponse.java): API DTO for job progress checking.
*   [ImportSummary.java](file:///backend/src/main/java/com/resulthub/api/csv/dto/ImportSummary.java): Details successful rows vs. failed rows on complete import runs.
*   [UploadResponse.java](file:///backend/src/main/java/com/resulthub/api/csv/dto/UploadResponse.java): Acknowledges files immediately upon multipart upload.
*   [ImportJobRepository.java](file:///backend/src/main/java/com/resulthub/api/csv/repository/ImportJobRepository.java): Database access interface for `import_jobs`.
*   [UploadedFileRepository.java](file:///backend/src/main/java/com/resulthub/api/csv/repository/UploadedFileRepository.java): Database access interface for `uploaded_files`.
*   [CsvImportService.java](file:///backend/src/main/java/com/resulthub/api/csv/service/CsvImportService.java): Heavy lifting parser implementing Apache Commons CSV stream processing and database-level batch inserts.

#### 📂 Package: `com.resulthub.api.dataset`
*   [DatasetController.java](file:///backend/src/main/java/com/resulthub/api/dataset/DatasetController.java): CRUD controller to manage workspaces' datasets.
*   [DatasetRecordController.java](file:///backend/src/main/java/com/resulthub/api/dataset/DatasetRecordController.java): REST endpoints to insert, edit, retrieve, and paginate individual record documents inside a dataset.
*   [Dataset.java](file:///backend/src/main/java/com/resulthub/api/dataset/entity/Dataset.java): Mapped entity matching the `datasets` table, capturing properties like status and domain type with custom enums.
*   [DatasetSchema.java](file:///backend/src/main/java/com/resulthub/api/dataset/entity/DatasetSchema.java): Contains raw JSON schema definitions used to structurally govern unstructured record payloads.
*   [DatasetRecord.java](file:///backend/src/main/java/com/resulthub/api/dataset/entity/DatasetRecord.java): Generic data sink mapping postgres `JSONB` to a Java `Map<String, Object>` through `@JdbcTypeCode(SqlTypes.JSON)`.
*   [DatasetStatus.java](file:///backend/src/main/java/com/resulthub/api/dataset/enums/DatasetStatus.java): Status enum (`DRAFT`, `PUBLISHED`, `ARCHIVED`).
*   [DomainType.java](file:///backend/src/main/java/com/resulthub/api/dataset/enums/DomainType.java): Enum identifying publishing verticals (e.g. `ACADEMIC`, `SPORT`, `FINANCE`).
*   [DatasetRequest.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/DatasetRequest.java): DTO mapping dataset creation parameters.
*   [DatasetResponse.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/DatasetResponse.java): Standard output payload representing datasets.
*   [DatasetSchemaRequest.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/DatasetSchemaRequest.java): DTO carrying structural Draft-7 JSON schema input definitions.
*   [DatasetSchemaResponse.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/DatasetSchemaResponse.java): Response payload for schemas.
*   [RecordRequest.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/RecordRequest.java): Input payload encapsulating generic map data and identifier keys.
*   [RecordResponse.java](file:///backend/src/main/java/com/resulthub/api/dataset/dto/RecordResponse.java): Output payload encapsulating generic map data.
*   [DatasetRepository.java](file:///backend/src/main/java/com/resulthub/api/dataset/repository/DatasetRepository.java): JPA repository for database lookup on datasets.
*   [DatasetRecordRepository.java](file:///backend/src/main/java/com/resulthub/api/dataset/repository/DatasetRecordRepository.java): JPA repository for database lookup on dataset records.
*   [DatasetSchemaRepository.java](file:///backend/src/main/java/com/resulthub/api/dataset/repository/DatasetSchemaRepository.java): JPA repository for schemas.
*   [DatasetService.java](file:///backend/src/main/java/com/resulthub/api/dataset/service/DatasetService.java): Enforces access governance and manages CRUD logic on dataset contexts.
*   [DatasetSchemaService.java](file:///backend/src/main/java/com/resulthub/api/dataset/service/DatasetSchemaService.java): Associates JSON validation schemas to datasets.
*   [DatasetRecordService.java](file:///backend/src/main/java/com/resulthub/api/dataset/service/DatasetRecordService.java): Inserts records, executes validation checks, and updates text vectors.
*   [SchemaValidationService.java](file:///backend/src/main/java/com/resulthub/api/dataset/service/SchemaValidationService.java): Evaluates structured inputs using standard Draft-7 `com.networknt.schema` json validators.

#### 📂 Package: `com.resulthub.api.search`
*   [SearchController.java](file:///backend/src/main/java/com/resulthub/api/search/SearchController.java): Endpoint for global public queries, offering real-time suggestions and filtered results.
*   [SearchAnalytics.java](file:///backend/src/main/java/com/resulthub/api/search/entity/SearchAnalytics.java): Stores anonymous query logs for analytics.
*   [SearchResult.java](file:///backend/src/main/java/com/resulthub/api/search/dto/SearchResult.java): Unified search result payload matching workspaces, datasets, or records.
*   [SearchSuggestion.java](file:///backend/src/main/java/com/resulthub/api/search/dto/SearchSuggestion.java): Captures key phrases to autocomplete query parameters.
*   [PaginatedSearchResponse.java](file:///backend/src/main/java/com/resulthub/api/search/dto/PaginatedSearchResponse.java): Standard pagination container matching the FTS results.
*   [SearchAnalyticsRepository.java](file:///backend/src/main/java/com/resulthub/api/search/repository/SearchAnalyticsRepository.java): JPA repository for query analytics.
*   [SearchRepository.java](file:///backend/src/main/java/com/resulthub/api/search/repository/SearchRepository.java): Performs complex native SQL full-text search `UNION ALL` queries with visibility joins.
*   [SearchService.java](file:///backend/src/main/java/com/resulthub/api/search/service/SearchService.java): Performs logic routing and processes suggestions asynchronously.

#### 📂 Package: `com.resulthub.api.security`
*   [JwtAuthenticationFilter.java](file:///backend/src/main/java/com/resulthub/api/security/JwtAuthenticationFilter.java): Intercepts requests, extracts JWTs, and registers valid users on the Spring Security context.
*   [JwtService.java](file:///backend/src/main/java/com/resulthub/api/security/JwtService.java): Signs, parses, and validates stateless authentication tokens.
*   [RateLimitInterceptor.java](file:///backend/src/main/java/com/resulthub/api/security/RateLimitInterceptor.java): Restricts execution speed dynamically based on client IP addresses.
*   [RateLimitService.java](file:///backend/src/main/java/com/resulthub/api/security/RateLimitService.java): Configures Bucket4j token bucket structures.
*   [SecurityConfig.java](file:///backend/src/main/java/com/resulthub/api/security/SecurityConfig.java): Registers filters, disables CSRF, configures OAuth2 Google Login, and sets path protection policies.

#### 📂 Package: `com.resulthub.api.user`
*   [User.java](file:///backend/src/main/java/com/resulthub/api/user/User.java): Identity model mapped to PostgreSQL table mapping credentials and roles.
*   [UserRole.java](file:///backend/src/main/java/com/resulthub/api/user/UserRole.java): Roles mapping system administrators (`ADMIN`, `USER`).
*   [UserRepository.java](file:///backend/src/main/java/com/resulthub/api/user/UserRepository.java): Handles database persistence for `users`.

#### 📂 Package: `com.resulthub.api.workspace`
*   [WorkspaceController.java](file:///backend/src/main/java/com/resulthub/api/workspace/WorkspaceController.java): REST controller managing workspace registration, visibility overrides, and detail fetching.
*   [MemberController.java](file:///backend/src/main/java/com/resulthub/api/workspace/MemberController.java): Manages workspace member invites and status changes.
*   [Workspace.java](file:///backend/src/main/java/com/resulthub/api/workspace/entity/Workspace.java): Main workspace entity defining name, slug, access visibility, and owner mapping.
*   [WorkspaceMember.java](file:///backend/src/main/java/com/resulthub/api/workspace/entity/WorkspaceMember.java): Relational join entity mapping a user to a workspace, tracking membership joined timestamp and roles.
*   [WorkspaceInvitation.java](file:///backend/src/main/java/com/resulthub/api/workspace/entity/WorkspaceInvitation.java): Details pending invitations sent out via tokens.
*   [VisibilityMode.java](file:///backend/src/main/java/com/resulthub/api/workspace/enums/VisibilityMode.java): Defines access configuration (`PUBLIC`, `PASSWORD_PROTECTED`, `PRIVATE`).
*   [WorkspaceRole.java](file:///backend/src/main/java/com/resulthub/api/workspace/enums/WorkspaceRole.java): Enforces the workspace RBAC permission scope (`OWNER`, `ADMIN`, `EDITOR`, `VIEWER`).
*   [CreateWorkspaceRequest.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/CreateWorkspaceRequest.java): Payload containing metadata for new workspace initialization.
*   [WorkspaceResponse.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/WorkspaceResponse.java): Response payload representing workspaces.
*   [UpdateWorkspaceRequest.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/UpdateWorkspaceRequest.java): Payload mapping workspace modifications.
*   [InviteMemberRequest.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/InviteMemberRequest.java): Payload specifying the email and role of invitees.
*   [InvitationResponse.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/InvitationResponse.java): Response payload mapping active invitation tokens.
*   [MemberResponse.java](file:///backend/src/main/java/com/resulthub/api/workspace/dto/MemberResponse.java): Response payload mapping active workspace members.
*   [WorkspaceRepository.java](file:///backend/src/main/java/com/resulthub/api/workspace/repository/WorkspaceRepository.java): Access repository for workspaces.
*   [WorkspaceMemberRepository.java](file:///backend/src/main/java/com/resulthub/api/workspace/repository/WorkspaceMemberRepository.java): Access repository for member joins.
*   [WorkspaceInvitationRepository.java](file:///backend/src/main/java/com/resulthub/api/workspace/repository/WorkspaceInvitationRepository.java): Access repository for invitations.
*   [WorkspaceService.java](file:///backend/src/main/java/com/resulthub/api/workspace/service/WorkspaceService.java): Performs visibility checks, assigns owners, and generates access codes.
*   [WorkspaceMemberService.java](file:///backend/src/main/java/com/resulthub/api/workspace/service/WorkspaceMemberService.java): Enforces member-level access modifications.
*   [WorkspaceInvitationService.java](file:///backend/src/main/java/com/resulthub/api/workspace/service/WorkspaceInvitationService.java): Generates secure invitations and processes registration tokens.

---

### 2.2 Frontend Modules (`lib/`)

#### 📂 Core Files
*   [main.dart](file:///lib/main.dart): The application entry point initializes the widgets binding, bootstraps the Firebase instance synchronously, registers the global custom Light Theme, and boots into the `SplashScreen`.

#### 📂 Package: `core/`
*   [api_client.dart](file:///lib/core/network/api_client.dart): Main Dio networking singleton. Configured with interceptors that dynamically read authorization JWTs from secure storage, inject `Authorization: Bearer <token>` headers, and capture connection timeout errors gracefully.
*   [secure_storage.dart](file:///lib/core/storage/secure_storage.dart): Wrapper utilizing the `flutter_secure_storage` package to persist JWT credentials locally.

#### 📂 Package: `models/`
*   [domain_model.dart](file:///lib/models/domain_model.dart): Holds enum types for the core vertical channels (`DomainType`: academic, sport, government, politics, finance, entertainment, tech, law, hyperLocal), visibility states, status variables, subcategory mapping, and initial mock data catalogs.
*   [result_model.dart](file:///lib/models/result_model.dart): Model detailing academic result records (student name, roll number, grades, credits, GPA, subjects).
*   [govt_model.dart](file:///lib/models/govt_model.dart): Model detailing government results (roll number, candidate name, marks, rank, selection status).

#### 📂 Package: `services/`
*   [api_service.dart](file:///lib/services/api_service.dart): Connects the UI to Spring Boot REST endpoints, fetching public workspaces, dataset records, and transmitting multipart CSV files via `FormData`. Also hosts mock fallbacks to prevent crashes on offline staging servers.
*   [auth_service.dart](file:///lib/services/auth_service.dart): Connects to Firebase Authentication, and features a Google Sign-In helper fully migrated to modern `GoogleSignIn.instance` (v7+) API patterns.

#### 📂 Package: `screens/`
*   [splash_screen.dart](file:///lib/screens/splash_screen.dart):Tactile startup screen executing entry animations before navigating into interests selection.
*   [onboarding_screen.dart](file:///lib/screens/onboarding_screen.dart): Captures the user's category interests (UPSC, SSC, Engineering, etc.) via animated chips, saving preferences before entering the home feed.
*   [main_scaffold.dart](file:///lib/screens/main_scaffold.dart): Primary container framing the bottom navigation menu (Home, Explore, Saved, Profile).
*   [home_screen.dart](file:///lib/screens/home_screen.dart): Dynamic primary dashboard rendering domain shortcut grids, live notifications, trending scorecards, and featured updates.
*   [search_screen.dart](file:///lib/screens/search_screen.dart): Offers a search field with real-time autocompletes, recent query history, and category navigation.
*   [search_results_screen.dart](file:///lib/screens/search_results_screen.dart): Pulls matching items from the full-text search backend and renders polymorphic cards based on the matching item type.
*   [bookmarks_screen.dart](file:///lib/screens/bookmarks_screen.dart): Lists records and datasets locally saved for offline reading.
*   [profile_screen.dart](file:///lib/screens/profile_screen.dart): Account screen showcasing user metadata, login state gates, and paths to preferences/settings screens.
*   [login_screen.dart](file:///lib/screens/login_screen.dart): Credential portal for email/password and Google Sign-in.
*   [signup_screen.dart](file:///lib/screens/signup_screen.dart): Identity registration page.
*   [forgot_password_screen.dart](file:///lib/screens/forgot_password_screen.dart): Sends recovery details.
*   [credential_screen.dart](file:///lib/screens/credential_screen.dart): The result lookup verification gate requiring inputs like Roll Number or Date of Birth before displaying records.
*   [result_detail_screen.dart](file:///lib/screens/result_detail_screen.dart): Elegant academic details scorecard detailing scores, grade distributions, and GPA.
*   [govt_detail_screen.dart](file:///lib/screens/govt_detail_screen.dart): Dashboard detailing state/national government list lookups and select status details.
*   [sports_feed_screen.dart](file:///lib/screens/sports_feed_screen.dart): Sports scorecard parsing matches, teams, status, and running event details.
*   [politics_screen.dart](file:///lib/screens/politics_screen.dart): Election dashboard compiling constituency results and vote shares via progress charts.
*   [finance_screen.dart](file:///lib/screens/finance_screen.dart): Market scoreboard listing prices, percent changes, and tickers.
*   [law_screen.dart](file:///lib/screens/law_screen.dart): Portal showcasing legal verdicts, CPWD bid catalogs, and tender announcements.
*   [entertainment_screen.dart](file:///lib/screens/entertainment_screen.dart): Lists box office numbers, music charts, and award winners.
*   [tech_screen.dart](file:///lib/screens/tech_screen.dart): Displays benchmark metrics, GPU reviews, and store listings.
*   [local_workspace_screen.dart](file:///lib/screens/local_workspace_screen.dart): Displays workspaces with subcategories and records.
*   [create_workspace_screen.dart](file:///lib/screens/create_workspace_screen.dart): Wizard form allowing administrators to establish new workspaces and choose visibility modes (Public, Protected, Private).
*   [subcategory_screen.dart](file:///lib/screens/subcategory_screen.dart): Details category list directories.

#### 📂 Package: `screens/admin/`
*   [admin_scaffold.dart](file:///lib/screens/admin/admin_scaffold.dart): Left navigation shell organizing administrative control views.
*   [admin_dashboard_screen.dart](file:///lib/screens/admin/admin_dashboard_screen.dart): Admin summary analytics dashboard detailing view trajectories and file statuses.
*   [upload_center_screen.dart](file:///lib/screens/admin/upload_center_screen.dart): Selects local CSV files, validates format columns, and runs background multipart imports to the Spring Boot server.
*   [manage_results_screen.dart](file:///lib/screens/admin/manage_results_screen.dart): Form allowing administrators to insert or edit records manually.
*   [manage_team_screen.dart](file:///lib/screens/admin/manage_team_screen.dart): Controls access roles (`EDITOR`, `ADMIN`, `VIEWER`) within a workspace.
*   [admin_settings_screen.dart](file:///lib/screens/admin/admin_settings_screen.dart): Adjusts system tolerances and credentials validation constraints.

#### 📂 Package: `screens/profile_pages/`
*   [personal_details_screen.dart](file:///lib/screens/profile_pages/personal_details_screen.dart): Form to change username or profile parameters.
*   [my_workspaces_screen.dart](file:///lib/screens/profile_pages/my_workspaces_screen.dart): Lists workspaces created or managed by the user.
*   [notifications_settings_screen.dart](file:///lib/screens/profile_pages/notifications_settings_screen.dart): Controls notification categories and triggers.
*   [recently_viewed_screen.dart](file:///lib/screens/profile_pages/recently_viewed_screen.dart): History tracking list.
*   [language_screen.dart](file:///lib/screens/profile_pages/language_screen.dart): Preference toggles.
*   [help_center_screen.dart](file:///lib/screens/profile_pages/help_center_screen.dart): User support repository.
*   [legal_screen.dart](file:///lib/screens/profile_pages/legal_screen.dart): License information, Terms, and Privacy Policies.

---

## 3. Database Architecture & Migrations

ResultHub manages unstructured records through a unified PostgreSQL relational-document layout. This avoids table bloating across various domains, maintaining maximum read speed.

### 3.1 Relational Schema and Triggers
*   **Generic JSONB Storage**: The `dataset_records` table holds data in a `data` `JSONB` column. 
*   **Real-time Indexing Trigger**: An automated database trigger listens to all `INSERT` and `UPDATE` calls on `workspaces`, `datasets`, and `dataset_records`. It merges title, description, tags, and JSON keys into the `search_vector` (`tsvector`) column automatically.
*   **GIN Wildcard Indexing**: A Generalized Inverted Index (`GIN`) is registered over the `search_vector` fields, allowing instantaneous prefix matches.
*   **Audit Logging**: The `audit_logs` table logs user actions, capturing `old_value` and `new_value` as JSON nodes to keep full history.
*   **Declarative Table Partitioning**: Due to the high volume of analytical metrics, `analytics_events` is partitioned dynamically by month on the `created_at` timestamp.

### 3.2 SQL Migrations Catalog (`db/migration/`)
*   `V1__init_users_table.sql`: Creates core `users` mapping identity details and roles.
*   `V2__init_workspace_tables.sql`: Establishes `workspaces`, roles enums, `workspace_members`, and secure pending invitation codes.
*   `V3__init_dataset_tables.sql`: Establishes `datasets`, validations `dataset_schemas` (Draft-7 models), and the unstructured `dataset_records` holding the document data payload.
*   `V4__init_csv_import_tables.sql`: Establishes tables tracing asynchronous multipart uploading progress.
*   `V5__init_search_and_analytics.sql`: Adds `search_vector` attributes, establishes full-text indexing triggers, and registers GIN index configurations.
*   `V6__init_analytics_tables.sql`: Builds the partitioned analytics events logging table.

---

## 4. Production Security & Exception Sanitization

The system runs with an active security envelope guarding private domains and preventing service abuse.

### 4.1 Stateless Access & Token Configuration
*   **JWT Implementation**: Short-lived Access Tokens (1-day) and secure Refresh Tokens (7-days) verify user authorization statelessly.
*   **CORS Policies**: Explicitly restricts browser-based cross-origin calls to the staging/production domain addresses.
*   **Workspace Visibility Gates**: Enforced at the service level, the API rejects dataset lookup queries for `PRIVATE` workspaces unless the user is a verified member, and prompts for code inputs on `PASSWORD_PROTECTED` channels.

### 4.2 Traffic Flow Control (Bucket4j Rate Limiting)
*   **Token Bucket Intercepting**: Public query endpoints are rate limited via `Bucket4j` to prevent automated scraping.
*   **Threshold Settings**: Public accesses are throttled at a ceiling of 100 requests per minute per IP address.
*   **Admin Bypass**: Authenticated system `ADMIN` roles are automatically excluded from throttling filters to avoid stalling high-volume CSV uploads.

### 4.3 Centralized Error Sanitization
*   **No Stack Trace Leakage**: Production profiles intercept all internal JVM exceptions (SQL issues, validation errors, null pointer checks) via `GlobalExceptionHandler`.
*   **Generic Response Format**: All failures return a clean JSON error response, returning generic HTTP statuses like `400 Bad Request` or `500 Internal Server Error` without revealing database schemas or raw error context to consumers.

---

## 5. UI Rendering & Client Networking

The Flutter frontend maintains UI speed and dynamic rendering across generic datasets.

### 5.1 Polymorphic Widget Generation (`RecordCardFactory`)
Because records are returned as generic `JSONB` schemas, the Flutter frontend uses a dynamic rendering pattern:
*   Rather than hardcoding hundreds of custom widgets, the UI evaluates the dataset's `DomainType` (e.g. `academic`, `sport`, `politics`) and the properties present in the JSON keys.
*   The system dynamically renders tabular lists for education metrics, side-by-side comparison tables for sports events, and colored progress trackers for election datasets.

### 5.2 Resilient Client Networking
*   **Token Refresh Interceptors**: The Dio `ApiClient` is configured with interceptors to handle token rotation. Upon receiving a `401 Unauthorized` response, it pauses pending calls, initiates a refresh query, updates secure storage, and retries the failed requests seamlessly.
*   **Fallback Mock Systems**: FutureBuilders include custom mockup generators to return rich, readable data if server services are unreachable.

---

## 6. Staging & SRE Testing Protocols

### 6.1 Dockerized Testcontainers Quality Assurance
The codebase enforces automated checks using **Testcontainers JUnit 5** test suites:
*   **Environment Mirroring**: Spin up real PostgreSQL 16 container instances dynamically.
*   **Triggers Testing**: Ensures full-text search triggers, validation schemas, and analytical partitions perform exactly as they would in production.
*   **Singleton Pattern Optimization**: Employs a shared singleton container context to launch PostgreSQL once per JVM lifecycle, avoiding Hikari connection pool timeouts.

### 6.2 CI/CD Pipeline & Delivery
*   **Automated Verification**: GitHub actions trigger compile checks and Testcontainers validation on every push to main.
*   **Rollout Strategy**: Successful builds compile into multi-stage Alpine Docker images and deploy to VPS clusters. Flutter builds bundle to statically served web files deployed via global CDNs for fast public edge delivery.
