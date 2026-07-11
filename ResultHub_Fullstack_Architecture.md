# ResultHub Fullstack Architecture

## 🖥️ Frontend Web Organization Structure (Next.js App Router)

The frontend is a premium, enterprise-grade Next.js application designed with Framer Motion, Tailwind CSS, and Lucide Icons. It employs a highly scalable routing architecture split between public marketing pages, a social feed ecosystem, and a completely isolated enterprise dashboard.

### 1. Route Architecture & Layouts

- **`(social)` Group:** The core social ecosystem for standard users.
  - **Layout:** `src/app/(social)/layout.tsx` includes a global `LeftSidebar` (for navigation) and a `RightSidebar` (for suggestions and trends). The Top Navbar and Footer were removed for a highly immersive, app-like experience.
  - **Routes:** 
    - `/` (Home/Feed)
    - `/search` (Global Search with interactive overlay)
    - `/bookmarks` (Personal Knowledge Library with timeline and collections)
    - `/analytics`, `/community`, `/support`, `/guidelines`

- **`dashboard` Ecosystem:** A completely isolated environment for Enterprise Organizations to manage their presence.
  - **Layout:** `src/app/dashboard/layout.tsx` features a collapsible Enterprise Sidebar (Linear/Stripe style) and a Top Action Navbar.
  - **Routes:**
    - `/dashboard` (The main Enterprise Command Center with 10+ KPI cards, Animated Gauges, Charts, Team Members, API usage, AI Assistant).
    - `/dashboard/workspaces` *(Planned: Workspace Management Grid, Templates, Health Gauges)*.

- **Public & Marketing Pages:**
  - `/organizations` (Premium Framer-style landing page with Ecosystem Maps and Vaults).
  - `/contact` (Enterprise Sales contact form).
  - `/login`, `/signup`, `/organizations/create`.

### 2. Design System & Theming
- **Primary Aesthetic:** "Premium SaaS" mimicking Apple, Linear, Stripe, and Framer.
- **Colors:** Deep purple (`#635BFF`) acting as the primary accent on pristine white cards and light-gray backgrounds (`#FAFAFA`), alongside a highly polished dark mode palette (`zinc-900`).
- **Typography:** `Inter` font, heavily relying on whitespace and precise hierarchy.
- **Motion:** Extensive usage of `framer-motion` for stagger children reveals, spring layout transitions, glassmorphism hover lifts, layout morphing, and animated data counters.

---

## 🚀 API Controllers & Endpoints

### AdminController

**Base Path:** `/api/v1/admin`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/admin/users` | `searchUsers` |
| PUT | `/api/v1/admin/users/{userId}/suspend` | `suspendUser` |
| PUT | `/api/v1/admin/users/{userId}/quota` | `updateUserQuota` |
| POST | `/api/v1/admin/users/{userId}/reset-password` | `resetUserPassword` |
| GET | `/api/v1/admin/system/health` | `getSystemHealth` |

### AnalyticsController

**Base Path:** `/api/v1/analytics`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/analytics/workspace/{workspaceId}` | `getWorkspaceAnalytics` |
| GET | `/api/v1/analytics/global` | `getGlobalAnalytics` |

### AuthController

**Base Path:** `/api/v1/auth`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/auth/register` | `verifySignupOtp` |
| POST | `/api/v1/auth/register/verify` | `verifySignupOtp` |
| POST | `/api/v1/auth/register/organization` | `registerOrganization` |
| POST | `/api/v1/auth/login` | `authenticate` |
| POST | `/api/v1/auth/refresh` | `refresh` |
| POST | `/api/v1/auth/login/mfa` | `verifyMfa` |
| POST | `/api/v1/auth/logout` | `unknown` |
| POST | `/api/v1/auth/forgot-password` | `unknown` |
| POST | `/api/v1/auth/verify-otp` | `unknown` |
| POST | `/api/v1/auth/reset-password` | `unknown` |
| POST | `/api/v1/auth/change-password` | `unknown` |

### ComplaintController

**Base Path:** `/api/v1/complaints`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/complaints` | `getComplaints` |
| GET | `/api/v1/complaints/{id}` | `getComplaintById` |
| POST | `/api/v1/complaints` | `createComplaint` |
| PATCH | `/api/v1/complaints/{id}/status` | `updateStatus` |
| POST | `/api/v1/complaints/{id}/vote` | `castVote` |
| POST | `/api/v1/complaints/{id}/flag` | `flagComplaint` |
| POST | `/api/v1/complaints/{id}/bookmark` | `bookmarkComplaint` |
| DELETE | `/api/v1/complaints/{id}/bookmark` | `removeComplaintBookmark` |
| GET | `/api/v1/complaints/{id}/comments` | `getComments` |
| POST | `/api/v1/complaints/{id}/comments` | `addComment` |
| POST | `/api/v1/complaints/comments/{commentId}/like` | `likeComment` |
| DELETE | `/api/v1/complaints/comments/{commentId}/like` | `unlikeComment` |
| GET | `/api/v1/complaints/media/{complaintId}/{filename:.+}` | `serveMediaFile` |

### CsvImportController

**Base Path:** `/api/v1`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/datasets/{datasetId}/upload-csv` | `uploadCsv` |

### CategoryController

**Base Path:** `/api/v1/categories`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/categories/domain/{domainType}` | `getRootCategoriesByDomain` |
| GET | `/api/v1/categories/{parentId}/subcategories` | `getSubCategories` |
| POST | `/api/v1/categories` | `createCategory` |

### DatasetController

**Base Path:** `/api/v1`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/workspaces/{workspaceId}/datasets` | `createDataset` |
| GET | `/api/v1/workspaces/{workspaceId}/datasets` | `getDatasetsByWorkspace` |
| GET | `/api/v1/datasets/{id}` | `getDataset` |
| PUT | `/api/v1/datasets/{id}` | `updateDataset` |
| POST | `/api/v1/datasets/{id}/publish` | `publishDataset` |
| POST | `/api/v1/datasets/{id}/archive` | `archiveDataset` |
| DELETE | `/api/v1/datasets/{id}` | `deleteDataset` |
| PUT | `/api/v1/datasets/{id}/schema` | `createOrUpdateSchema` |
| GET | `/api/v1/datasets/{id}/schema` | `getSchema` |

### DatasetRecordController

**Base Path:** `/api/v1`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/datasets/{datasetId}/records` | `createRecord` |
| GET | `/api/v1/datasets/{datasetId}/records` | `getRecords` |
| GET | `/api/v1/datasets/{datasetId}/records/stream` | `streamRecords` |
| GET | `/api/v1/records/{recordId}` | `getRecord` |
| PUT | `/api/v1/records/{recordId}` | `updateRecord` |
| DELETE | `/api/v1/records/{recordId}` | `deleteRecord` |
| GET | `/api/v1/datasets/{datasetId}/records/lookup` | `lookupRecord` |

### FeedController

**Base Path:** `/api/v1/feed`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/feed` | `getFeed` |
| GET | `/api/v1/feed/saved` | `getSavedItems` |
| GET | `/api/v1/feed/user/{userId}` | `getUserFeed` |

### MessageController

**Base Path:** `/api/v1/messages`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/messages/inbox` | `getInbox` |
| GET | `/api/v1/messages/unread-count` | `getGlobalUnreadCount` |
| GET | `/api/v1/messages/{userId}` | `getConversationHistory` |
| POST | `/api/v1/messages/{userId}` | `sendMessage` |

### NotificationController

**Base Path:** `/api/v1/notifications`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/notifications` | `getMyNotifications` |
| PUT | `/api/v1/notifications/{id}/read` | `markAsRead` |
| PUT | `/api/v1/notifications/read-all` | `markAllAsRead` |

### PdfImportController

**Base Path:** `/api/v1`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/pdf/import` | `uploadPdf` |
| GET | `/api/v1/pdf/import/{jobId}` | `getJobStatus` |

### FeedPostController

**Base Path:** `/api/v1/posts`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/posts` | `createPost` |
| GET | `/api/v1/posts/media/{postId}/{filename:.+}` | `serveMediaFile` |
| GET | `/api/v1/posts/{postId}/interactions` | `getInteractionStatus` |
| POST | `/api/v1/posts/{postId}/like` | `likePost` |
| DELETE | `/api/v1/posts/{postId}/like` | `unlikePost` |
| POST | `/api/v1/posts/{postId}/bookmark` | `bookmarkPost` |
| DELETE | `/api/v1/posts/{postId}/bookmark` | `removeBookmark` |
| GET | `/api/v1/posts/{postId}/comments` | `getComments` |
| POST | `/api/v1/posts/{postId}/comments` | `addComment` |
| POST | `/api/v1/posts/comments/{commentId}/like` | `likeComment` |
| DELETE | `/api/v1/posts/comments/{commentId}/like` | `unlikeComment` |

### SearchController

**Base Path:** `/api/v1/search`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/search` | `globalSearch` |

### UserController

**Base Path:** `/api/v1/users`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/users/me` | `getMyProfile` |
| PUT | `/api/v1/users/me` | `updateMyProfile` |
| DELETE | `/api/v1/users/me` | `deleteMyAccount` |
| GET | `/api/v1/users/{userId}/profile` | `followUser` |
| POST | `/api/v1/users/{userId}/follow` | `followUser` |
| DELETE | `/api/v1/users/{userId}/follow` | `unfollowUser` |
| DELETE | `/api/v1/users/followers/{followerId}` | `removeFollower` |
| POST | `/api/v1/users/{userId}/block` | `blockUser` |
| DELETE | `/api/v1/users/{userId}/block` | `unblockUser` |
| GET | `/api/v1/users/{userId}/followers` | `unknown` |
| GET | `/api/v1/users/{userId}/following` | `unknown` |
| GET | `/api/v1/users/search` | `unknown` |

### VoteBoxController

**Base Path:** `/api/v1/votes`

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/v1/votes` | `getAllPublicVoteBoxes` |
| GET | `/api/v1/votes/{id}` | `getVoteBox` |
| POST | `/api/v1/votes` | `createVoteBox` |
| POST | `/api/v1/votes/{id}/cast` | `castVote` |
| GET | `/api/v1/votes/{id}/results` | `getResults` |
| POST | `/api/v1/votes/{id}/unlock` | `unlockVoteBox` |
| DELETE | `/api/v1/votes/{id}` | `deleteVoteBox` |

### MemberController

**Base Path:** `/api/v1`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/workspaces/{id}/invite` | `inviteMember` |
| POST | `/api/v1/invitations/{token}/accept` | `acceptInvitation` |
| GET | `/api/v1/workspaces/{id}/members` | `getMembers` |
| PATCH | `/api/v1/members/{id}/role` | `changeRole` |
| DELETE | `/api/v1/members/{id}` | `removeMember` |

### WorkspaceController

**Base Path:** `/api/v1/workspaces`

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/v1/workspaces` | `createWorkspace` |
| GET | `/api/v1/workspaces/{id}` | `getWorkspace` |
| GET | `/api/v1/workspaces/slug/{slug}` | `getWorkspaceBySlug` |
| POST | `/api/v1/workspaces/{id}/unlock` | `unknown` |
| GET | `/api/v1/workspaces/my` | `getMyWorkspaces` |
| GET | `/api/v1/workspaces/public` | `getPublicWorkspaces` |
| PUT | `/api/v1/workspaces/{id}` | `updateWorkspace` |
| DELETE | `/api/v1/workspaces/{id}` | `deleteWorkspace` |
| GET | `/api/v1/workspaces/{id}/share-link` | `unknown` |
| POST | `/api/v1/workspaces/{id}/regenerate-code` | `unknown` |

## 🗄️ Database Entities

### AnalyticsEvent

- `id` (UUID), `eventType` (EventType), `workspaceId` (UUID), `datasetId` (UUID), `recordId` (UUID), `userId` (UUID), `anonymousSessionId` (String), `createdAt` (LocalDateTime)

### PasswordResetToken

- `id` (UUID), `user` (User), `otp` (String), `expiryDate` (LocalDateTime)

### SignupOtp

- `id` (UUID), `email` (String), `name` (String), `passwordHash` (String), `phoneNumber` (String), `otp` (String), `expiryDate` (LocalDateTime)

### Complaint

- `id` (UUID), `creator` (User), `category` (String), `title` (String), `description` (String), `mediaUrls` (String[]), `latitude` (BigDecimal), `longitude` (BigDecimal), `locationName` (String), `netScore` (Integer), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime)

### ComplaintBookmark

- `id` (UUID), `complaint` (Complaint), `user` (User), `createdAt` (LocalDateTime)

### ComplaintComment

- `id` (UUID), `complaint` (Complaint), `creator` (User), `parentComment` (ComplaintComment), `content` (String), `createdAt` (LocalDateTime)

### ComplaintCommentLike

- `id` (UUID), `comment` (ComplaintComment), `user` (User), `createdAt` (LocalDateTime)

### ComplaintVote

- `id` (UUID), `complaint` (Complaint), `user` (User), `voteType` (VoteType), `createdAt` (LocalDateTime)

### ImportJob

- `id` (UUID), `dataset` (Dataset), `uploadedBy` (User), `filename` (String), `errorFilePath` (String), `startedAt` (LocalDateTime), `completedAt` (LocalDateTime), `createdAt` (LocalDateTime)

### UploadedFile

- `id` (UUID), `workspace` (Workspace), `dataset` (Dataset), `originalFilename` (String), `storedFilename` (String), `filePath` (String), `mimeType` (String), `fileSize` (Long), `uploadedBy` (User), `uploadedAt` (LocalDateTime)

### Category

- `id` (UUID), `name` (String), `slug` (String), `domainType` (DomainType), `parent` (Category), `workspace` (Workspace), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime)

### Dataset

- `id` (UUID), `workspace` (Workspace), `category` (Category), `name` (String), `slug` (String), `description` (String), `createdBy` (User), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime)

### DatasetRecord

- `id` (UUID), `version` (Long), `dataset` (Dataset), `recordKey` (String), `recordTitle` (String), `tags` (List<String>), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime)

### DatasetSchema

- `id` (UUID), `dataset` (Dataset), `schemaName` (String), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime)

### Message

- `id` (UUID), `sender` (User), `receiver` (User), `content` (String), `createdAt` (LocalDateTime)

### AppNotification

- `id` (UUID), `user` (User), `type` (NotificationType), `title` (String), `body` (String), `linkedId` (String), `createdAt` (LocalDateTime)

### WriteOutboxEvent

- `id` (UUID), `aggregateType` (String), `aggregateId` (UUID), `eventType` (String), `idempotencyKey` (String), `nextAttemptAt` (LocalDateTime), `processedAt` (LocalDateTime), `createdAt` (LocalDateTime)

### FeedPost

- `id` (UUID), `creator` (User), `text` (String), `category` (String), `locationName` (String), `mediaUrls` (String[]), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime)

### FeedPostBookmark

- `id` (UUID), `post` (FeedPost), `user` (User), `createdAt` (LocalDateTime)

### FeedPostComment

- `id` (UUID), `post` (FeedPost), `creator` (User), `parentComment` (FeedPostComment), `content` (String), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime)

### FeedPostCommentLike

- `id` (UUID), `comment` (FeedPostComment), `user` (User), `createdAt` (LocalDateTime)

### FeedPostLike

- `id` (UUID), `post` (FeedPost), `user` (User), `createdAt` (LocalDateTime)

### SearchAnalytics

- `id` (UUID), `searchQuery` (String), `resultCount` (Integer), `anonymousSessionId` (String), `user` (User), `createdAt` (LocalDateTime)

### RevokedToken

- `token` (String), `revokedAt` (LocalDateTime)

### User

- `id` (UUID), `email` (String), `name` (String), `passwordHash` (String), `oauthProvider` (String), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime), `deletedBy` (UUID), `phoneNumber` (String), `organizationType` (String), `bio` (String), `website` (String), `city` (String), `profilePictureBase64` (String), `mfaSecret` (String)

### UserBlock

- `id` (UserBlockId), `blocker` (User), `blocked` (User)

### UserFollow

- `id` (UserFollowId), `follower` (User), `followed` (User)

### VoteBox

- `id` (UUID), `creator` (User), `title` (String), `description` (String), `accessCode` (String), `endsAt` (LocalDateTime), `linkedWorkspace` (Workspace), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime)

### VoteOption

- `id` (UUID), `voteBox` (VoteBox), `optionText` (String)

### VoteResponse

- `id` (UUID), `voteBox` (VoteBox), `option` (VoteOption), `user` (User), `ipAddress` (String), `deviceFingerprint` (String), `createdAt` (LocalDateTime)

### Workspace

- `id` (UUID), `name` (String), `slug` (String), `description` (String), `accessCode` (String), `owner` (User), `createdAt` (LocalDateTime), `updatedAt` (LocalDateTime), `deletedAt` (LocalDateTime), `deletedBy` (UUID)

### WorkspaceInvitation

- `id` (UUID), `workspace` (Workspace), `email` (String), `role` (WorkspaceRole), `token` (String), `expiresAt` (LocalDateTime), `acceptedAt` (LocalDateTime), `createdAt` (LocalDateTime)

### WorkspaceMember

- `id` (UUID), `workspace` (Workspace), `user` (User), `role` (WorkspaceRole), `joinedAt` (LocalDateTime)

## ⚙️ Services

- **AdminService**
- **AnalyticsTrackingService**
- **WorkspaceAnalyticsService**
- **AuthService**
- **MfaService**
- **ComplaintMediaService**
- **ComplaintService**
- **CsvImportService**
- **CategoryService**
- **DatasetRecordEventService**
- **DatasetRecordService**
- **DatasetSchemaService**
- **DatasetService**
- **SchemaValidationService**
- **FeedService**
- **MessageService**
- **NotificationService**
- **PdfImportService**
- **FeedPostInteractionService**
- **FeedPostMediaService**
- **FeedPostService**
- **SearchService**
- **JwtService**
- **RateLimitService**
- **TokenRevocationService**
- **VoteBoxTokenService**
- **WorkspaceTokenService**
- **GuestUserService**
- **UserService**
- **VoteBoxService**
- **WorkspaceAccessService**
- **WorkspaceInvitationService**
- **WorkspaceMemberService**
- **WorkspaceService**





You are a Senior Product Designer, Senior UX Architect, and Staff Frontend Engineer with experience designing products like GitHub, Notion, Airtable, Supabase Studio, Vercel Dashboard, Stripe Dashboard, and Linear.

Design a premium, enterprise-grade Dataset Management Workspace for ResultHub, a multi-tenant data publishing platform where organizations create, manage, publish, and analyze datasets.

This is not a CRUD admin page. It should feel like a professional SaaS platform used by governments, universities, companies, schools, hospitals, sports organizations, election commissions, NGOs, financial institutions, and media organizations.

The interface should feel minimal, elegant, information-rich, highly interactive, and extremely intuitive while avoiding clutter.

Design Style

Create a modern SaaS experience inspired by:

GitHub
Supabase Studio
Notion
Airtable
Stripe Dashboard
Vercel
Linear
Framer

Design Language:

Glassmorphism only where valuable
Soft shadows
Rounded corners (14–18px)
Premium spacing
Clean typography
Smooth hover effects
Modern animations
Excellent whitespace usage
Enterprise aesthetics
Dark and Light Mode
Fully Responsive
Layout Structure
Left Sidebar
Top Navigation
Workspace Header
Statistics Cards

Quick Actions

Dataset Table
Filters
Activity Feed
Insights Panel
Left Sidebar
Include elegant icons with labels.

Dashboard
Workspaces
Datasets ⭐
Records
CSV Imports
Search Center
Analytics
Members
Notifications
Organization Profile
Settings

Bottom

Profile Card

Storage Usage

Workspace Plan

Top Navigation

Include

Workspace Switcher

Global Search

Notifications

Quick Create Button

Help

Organization Avatar

Dark Mode Toggle

Dataset Header

Large Title

Datasets

Subtitle

Create, organize, publish and analyze your organization's datasets.

Buttons

New Dataset

Import CSV

Bulk Import

Export

Refresh

Statistics Section

Beautiful animated cards.

Examples

Total Datasets

Published

Draft

Archived

Private

Public

Storage Used

Today's Views
Downloads
API Calls
Each card should include
Icon
Animated Counter

Tiny Sparkline

Percentage Change

Hover Animation

Quick Actions

Beautiful cards.

Create Dataset

Upload CSV

Manual Entry

Import Excel

JSON Upload

Generate Dataset

Invite Team

Create Workspace

Dataset Table

Professional data grid.

Columns

Dataset Name

Category

Organization

Visibility

Status

Records

Views

Downloads

Owner

Updated

Actions

Status

Draft

Published

Archived

Scheduled

Visibility

Public

Private

Password Protected

Actions

Preview

Edit

Duplicate

Publish

Archive

Delete

Analytics

Share

Search & Filters

Global Search

Category

Status

Visibility

Workspace

Created By

Date Range

Sort

Saved Filters

Reset Filters

Right Insights Panel

Today's Activity

Recent Uploads

Most Viewed Dataset

Top Performing Dataset

Storage Usage

Recent Comments

Latest Searches

Latest Imports

Live Visitors

Empty State

If there are no datasets

Show beautiful illustration

Headline

Create your first dataset

Description

Datasets power ResultHub.
Publish results, rankings, government lists,
sports statistics, financial data,
and much more.

Large CTA

Create Dataset

Dataset Cards (Optional Toggle)

Allow switching between

Grid View

Table View

Card contains

Thumbnail

Title

Description

Tags

Visibility Badge

Status Badge

Record Count

Views

Last Updated

Owner

Hover animation

Bulk Operations

Professional selection toolbar

Appears after selecting rows

Delete

Publish

Archive

Move

Export

Assign Owner

Change Visibility

Duplicate

Activity Timeline

Beautiful timeline

Dataset Created

CSV Uploaded

Published

Edited

Member Added

Import Completed

Export Generated

Micro Animations

Cards lift slightly

Smooth hover

Animated counters

Progress bars

Ripple effects

Page transitions

Loading skeletons

Glass hover

Floating buttons

Success animations

Color Palette

Primary

#6D5DF6

Success

#22C55E

Warning

#F59E0B

Danger

#EF4444

Info

#3B82F6

Background

Very light gray

Cards

White

Typography

Inter

Components

Use reusable design system

Buttons

Cards

Badges

Tags

Tables

Dialogs

Side Panels

Drawers

Tooltips

Dropdowns

Modals

Toast Notifications

Search Bars

Progress Indicators

Skeleton Loaders

Charts

Responsiveness

Desktop

Laptop

Tablet

Mobile

Adaptive sidebar

Collapsible filters

Responsive tables

Floating quick actions

Accessibility

WCAG AA

Keyboard Navigation

Screen Reader Friendly

Proper Focus States

High Contrast

Large Click Areas

User Experience Goals

The user should immediately understand:

How many datasets they own.
Which datasets need attention.
What has changed recently.
How to create a new dataset.
How to import data.
How to publish data.
Which datasets perform best.
Which datasets are private or public.
What actions they can perform.
Technical Constraints
Use the existing Spring Boot backend APIs.
Do not redesign authentication or backend architecture.
Keep all actions API-ready (CRUD, publish, archive, analytics, imports).
Design reusable components that can integrate with Flutter and React/Next.js.
Do not use dummy enterprise features that cannot be supported by the backend.
Final Goal

The final screen should feel like a premium enterprise data management platform that combines the best aspects of Supabase Studio, Airtable, GitHub, and Stripe Dashboard, while remaining uniquely tailored for ResultHub's generic JSONB-based publishing system. The interface should be clean, efficient, visually impressive, and scalable enough to support organizations managing everything from educational results and government lists to sports statistics, financial reports, healthcare records, and community datasets.