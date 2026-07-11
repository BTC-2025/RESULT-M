Act as a Senior Product Designer, Data Discovery UX Architect, Dashboard Specialist, Mobile App Designer, and Flutter UI Expert with 30+ years of experience.

Design the main Results Home Page of ResultHub.

This is the central discovery page where users browse, search, and explore results from all domains.

The page is not a social feed.

The page is not a detail page.

The page acts as a global result discovery engine.

Purpose
Allow users to quickly discover:

Latest Results

Live Results

Trending Results

Popular Results

Recently Published Results

Category-specific Results

Local Results

Organization Results

The page should feel like a combination of:

Google Discover

ESPN

Bloomberg

Government Result Portal

Data Dashboard

while maintaining its own identity.

Supported Categories
Academic

Government

Recruitment

Sports

Politics

Finance

Entertainment

Technology

Law

Healthcare

Business

Hyper Local

Primary User Goals
Users should immediately be able to:

Search for a result

Discover new results

Access live information

Explore categories

View trending data

Find recent publications

Navigate to organizations

Information Hierarchy
Global Search
The most important feature.

Supports:

Result Search

Organization Search

Dataset Search

Category Search

Search should be immediately accessible.

Featured Results
Highlights important publications.

Examples:

National Exam Results

Election Results

Championship Finals

Major Financial Reports

High visibility section.

Live Now
Dedicated area for live data.

Examples:

Cricket Matches

Football Matches

Elections

Market Updates

Should communicate urgency and real-time activity.

Categories Section
Provides access to all domains.

Examples:

Academic

Sports

Finance

Politics

Government

Law

Entertainment

Technology

Healthcare

Business

Hyper Local

Trending Results
Most viewed and most searched results.

Displays:

Ranking

Category

Views

Popularity

Recent Publications
Recently published results from organizations.

Displays:

Organization

Result Title

Publish Time

Category

Quick Access Results
Frequently accessed result types.

Examples:

Exam Results

Recruitment Results

Sports Results

Election Results

Court Judgements

Market Reports

Organization Highlights
Featured publishers on the platform.

Displays:

Organization Logo

Organization Name

Category

Published Dataset Count

Popular Datasets
Most accessed datasets across the platform.

Examples:

State Board Results

Recruitment Lists

Election Results

League Tables

Statistics Overview
Platform level metrics.

Examples:

Total Organizations

Total Results

Live Events

Published Datasets

User Experience Goals
Users should feel:

Informed

Confident

Curious

Engaged

The page should encourage exploration.

Visual Personality
The page should feel:

Professional

Trustworthy

Modern

Premium

Data Driven

Enterprise Grade

Not like a social media feed.

Not like a government website.

Not like a news website.

A unique result discovery platform.

Technical Context
The page must support:

Thousands of organizations

Millions of records

Dynamic categories

Real-time updates

Static results

Global scalability

The page should act as the homepage of the entire ResultHub ecosystem and be optimized for discovering results from any category.


DD / MM / YYYY
 Check My Result →
247
Merit Rank
Karthik Murugan
Reg: 2024TN0087231 · OBC Category
SELECTED
Document Verification Pending
Written Score
187.25 / 300
Oral Test
38 / 50
Total Score
225.25
Category Rank
OBC — 89
Post Allotted
Assistant Section Officer
Document Date
20 Jun 2026


First Listen  , For example, in the result page, the triplet live or efron live, football live, cricket, every sports should be on live. I don't know how to implement, like, there will be if we click on that, for example, if we click on the cricket, it has to be show the players names, the players tools, and then in down, uh, loss control goals, history. And we can... if we scroll and it will show the previous goals, and, um, it will show the models and then economy. Um, like that, um, for a football, everything, like, um, what are the, um, what are the goals, um, in which we're in the goals or took place, and then the lineup. Um, after that, in the f one, uh, how many laps are finished, what other dial... drivers are doing, what is the military is going on, who got the penalty, and everything on... you know, like, in every sports, we can implement. But I don't know how to implement it and how will... for example, he also wants, for example, school, colleges, and eleven categories, which she... sorry, which he has mentioned in the file for me and given to me to build this. I don't know it's possible or not, but I don't even know how will I implement the data. For example, the course will have a different type of different type of mocks, UI, mocks category, Interview and everything, like, mocks you... mock... the mocks will be different. Uh, the category will be different. The input will be different. How will we manage in... at mind panel? How will an organization select this and put that data in it? How other organization whom, uh, for example, if a school wanted, uh, to join, uh, to join in our app and want to publish their results in our page, how we are going to take that and It's a product based company. So, uh, how, uh, for example, the eleven categories, there are different different types of data. There have different different types of resource and how we we are going to manage that data. It will be a big question for me to implement, uh, using AI because I'm just a white poodle, and I don't know anything, um, about Strata or... I mean, why bookshorter? Why product? Okay. I'm just in... I use AI for coding, and, um, I don't know anything about, uh, possibility with Flutter or Java and etcetera.

Show less
Jun 9
This is a great and very honest question. Let me break this down clearly — two separate problems you're describing.

Problem 1: Live Sports — Different UI per Sport
You're right that cricket, football, and F1 all have completely different data shapes. Here's the solution:

One universal data container. Different display widgets.

Think of it like this:

LiveMatch (universal)
    ├── matchId
    ├── sport: "CRICKET" | "FOOTBALL" | "F1"
    ├── status: LIVE / UPCOMING / FINISHED
    └── data: { ...sport-specific JSONB... }
The data field is different for every sport. Your Flutter page reads the sport field and routes to the correct widget:

dart
switch (match.sport) {
  case 'CRICKET'  → CricketLiveScreen(data)
  case 'FOOTBALL' → FootballLiveScreen(data)
  case 'F1'       → F1LiveScreen(data)
}
Here's what each sport's screen looks like:



Where does the live data come from? You don't collect it yourself. You use free/paid sports data APIs:

Cricket → Cricbuzz API, CricAPI, SportMonks
Football → Football-Data.org (free), API-Football
F1 → Ergast API (free), OpenF1 API (completely free)
Your Spring Boot backend calls these APIs every 10–15 seconds and pushes updates to Flutter via WebSocket. You never store match data permanently — you just relay it.

Problem 2: 11 Categories with Different Data Types — How to Manage It
This is the harder question and you asked it exactly right. Here's the honest answer:

You don't build 11 different admin panels. You build ONE generic panel.

The insight from your own requirements file is this:

Organization → Workspace → Dataset → Records (JSONB)
The admin panel never asks "what sport is this?" or "what exam is this?" It only asks:

"What are the column names for your data?"

Then the organization fills in their own data in those columns. Here's how it works in practice:



Your Real Question: "I use AI for coding. Is this possible for me to build?"
Yes — but you need to be honest with yourself about what to build first vs later. Here's a realistic build order:

Build first (Months 1–3):

Workspace creation + dataset schema definition (admin panel)
CSV upload → JSONB records storage
Dynamic search form for the public result page
Password gate
Build second (Months 4–6):

Public listing mode (tables, rankings)
Vote box + complaint modules
Build later / with a team (Month 7+):

Live sports (WebSocket + third-party API integration)
F1, Cricket, Football live screens
11-category hero widgets
Live sports is the most technically complex part. It requires WebSockets, third-party API subscriptions, and real-time state management. Build it last, after the core platform is working.

The single most important thing to understand: You don't need to build 11 different systems. You build one generic engine and the organizations bring their own data into it. A school, an IPL team, and a court — they all use the same 4-step admin panel. The data just looks different because they configured the columns differently.

Want me to now produce the detailed plan for just the Admin Panel (how an organization creates a dataset and uploads data), or the Live Sports WebSocket architecture? Tell me which one to go deep on first.

Yeah, Explain Me Like a how a diferent domain like school results and court results have a single panel but shows different UI and different data displayed

Jun 9
Great question. This is the core architecture concept. Let me explain it with a real example so it clicks completely.

The Mental Model: A Restaurant Kitchen
Think of it like this. A restaurant has one kitchen. But it makes pizza, pasta, and sushi — all completely different dishes. The kitchen doesn't change. Only the ingredients and the plate presentation change.

ResultHub is the kitchen. Schools, courts, cricket leagues — they're just different dishes.

How It Actually Works — Step by Step


Now here's the part most people miss. The UI looks different automatically — not because you coded a separate school page and a separate court page. It's because of one smart widget called FieldRenderer.



Now let me show you the complete journey — from an organization signing up to a student seeing their result — in one single flow:



The Three Things to Remember
1. One admin panel. Every organization — school, court, cricket league, hospital — uses the same 4-step form. They just type different field names.

2. One database table. Every record from every organization goes into the same records table as JSONB. The database never knows if it's a student mark or a court verdict.

3. One Flutter result page. The same Flutter code renders all of them. It looks different because the field names, values, and workspace branding are different — not because you wrote different pages.

The analogy that makes it stick: think of it like a business card printing shop. The shop has one machine. A doctor gives their details and gets a doctor's card. A lawyer gives their details and gets a lawyer's card. The machine doesn't change. Only the input changes. And the output looks completely different.

Want me to now go deep on how the admin panel UI is built — the actual screens an organization sees when they sign up and create their dataset?

What about the Different Categories , Can You List Out The 11 Categories which Client Wants

Jun 9
Based on your client's requirements file, here are all 11 categories with everything inside them:



Now here is the most important thing to understand about these 11 categories — they collapse into just 3 data behaviors:



What This Means for Your Build Order
This is the honest reality of your project:

Build Group B first. That is 6 out of 11 categories — Academic, Government, Law, Healthcare, Entertainment, Tech. One admin panel, one CSV upload, one search form, one result card. This alone covers the majority of your client's requirements and is something you can ship in 3 months using AI-assisted coding.

Build Group C second. That is just Group B with a password gate added. Two extra screens — password entry and access management. One more week of work on top of Group B.

Build Group A last. Live sports, live markets, live elections. This needs WebSockets, third-party API subscriptions, and real-time state. It is a separate technical challenge. Plan it for after the core platform is working.

The 11 categories sound overwhelming. But they are really just one system built three times — once without a gate, once with a password gate, and once with a live data feed.

Want me to now draw out the Admin Panel screens — exactly what an organization sees step by step when they sign up and create their first dataset?

Lets Plan Group B, But I want the theme of the result page according to that particular domain. Awards have different UI type and Academic have different , In Academic we have to input some credentials and in Awards Its a Public

Jun 9
Good thinking. This is exactly the right way to plan it. Same engine underneath, but the presentation layer changes per domain.

Let me first establish the rule system, then show every domain's UI:



Now let me show every single domain's actual UI mockup — one by one:



Academic: Deep navy blue. Institutional and trustworthy. Credential form first, result locked behind it. Subject marks show as progress bars. Grade circle as the hero element.


🎓
1. Academic & Education
Batch / Seasonal
Board Exams (CBSE, State)
Entrance Exams (JEE, NEET, CLAT)
Global Tests (GRE, GMAT, IELTS)
University Semester Results
School Internal Assessments
Coaching Mock Tests
Research & University Rankings
Scholarship Lists
Data format: CSV / PDF · Search by: Roll No + DOB · Output: Marks, Grade, Pass/Fail
🏆
2. Sports, Gaming & Athletics
Real-time / Live
Cricket (IPL, International)
Football (EPL, ISL)
Formula 1
Basketball, Kabaddi, Badminton
Olympics Medal Tallies
Esports (BGMI, Valorant)
Hyper-Local: Gully Cricket, Turf Leagues
School & College Sports Days
Data format: Live JSON Streams · Update: Every 10–30 sec · Output: Scores, Tables, Player Stats
🗳️
3. Politics, Governance & Elections
Event-Driven
Live Election Results (Seats, Vote %)
Constituency-wise Leads
Parliamentary Bill Outcomes
Government Approval Ratings
Exit Poll Analytics
Global Development Indexes (HDI, CPI)
Voter Turnout Data
Data format: Dynamic Graphs + Tables · Update: Live on election day · Output: Seat counts, Swing data
🏛️
4. Government & Civil Services
Batch Processing
UPSC, TNPSC, SSC Results
Railway Recruitment (RRB)
Police, Defence Recruitment
Merit Lists & Waiting Lists
Physical / Medical Test Results
Document Verification Status
Government Tender Awards
Public Contract Bid Results
Data format: Large CSV / PDF · Search by: Register No + DOB · Output: Merit rank, Status, Selection
📈
5. Finance, Economics & Markets
Real-time / Daily
NSE / BSE Index (Nifty, Sensex)
Corporate Earnings Reports
Cryptocurrency Prices
GDP, Inflation (CPI/WPI) Data
RBI Interest Rate Decisions
Commodity Valuations
Credit Ratings (AAA, BBB)
Top Gainers / Losers
Data format: Live JSON / Webhooks · Update: Real-time · Output: Price, % change, Volume, EPS
⚖️
6. Law & Judiciary
Event-Driven
Supreme & High Court Verdicts
Landmark Case Dispositions
District Court Final Rulings
Case Status & Next Hearing
Legal Precedent Registrations
Consumer Court Orders
Data format: Manual Entry / PDF · Search by: Case No · Output: Verdict, Judge, Date, Next Hearing
🎬
7. Entertainment, Media & Awards
Event-Driven
Box Office Collections (Weekly)
Award Show Winners (Oscars, Filmfare)
Streaming Charts (Netflix, Prime)
Music Charts (Top 100 Tracks)
Album Sales & Radio Airplay
Reality Show Voting Results
Bestseller Book Lists
Data format: CDN-cached tables · Update: Weekly / Event day · Output: Rank, Revenue, Winner, Votes
💻
8. Technology & Digital
Periodic Updates
AI / LLM Leaderboards (MMLU, HumanEval)
GPU / CPU Benchmark Scores
App Store / Play Store Rankings
Web Traffic & SEO Rankings
Domain Authority Scores
Cloud Compute Performance
Hackathon & Innovation Scores
Data format: Structured JSON · Update: Daily / Per release · Output: Score, Rank, Version, Delta
🏥
9. Healthcare & Medical
Batch / Protected
Medical Entrance Results (NEET PG)
Hospital Performance Rankings
Medical Council Exam Results
Clinical Trial Outcomes
Patient Report Summaries (Private)
Health Index Rankings by District
Data format: CSV / Manual · Always Password-Protected · Output: Score, Rank, Qualifying status
💼
10. Business, Jobs & Corporate
Batch / Private
Campus Placement Results
Internal Sales Leaderboards
Job Application Status Lists
Corporate Hackathon Scores
Employee Performance Rankings
Branch Performance %
Team Building & Retreat Scores
Data format: CSV / Manual · Often Private or Password-Protected · Output: Rank, Score, Status, %
📍
11. Hyper-Local & Community
Manual / Real-time
Gully Cricket & Local Leagues
Inter-Village Tournaments
School & College Fests
Drawing & Debate Competitions
Tuition Center Mock Tests (Private)
Gym PR Leaderboards
Private Esports Rooms (BGMI, FF)
Peer Bets & Friend Challenges
Data format: Manual mobile entry · Often Password-Protected · Output: Score, Rank, Winner, Points


Group A — Live & Real-Time
Data changes every few seconds. Needs WebSocket or polling.
Sports
Finance / Markets
Elections (on election day)
Hyper-Local live matches
Your Flutter app connects via WebSocket. Spring Boot polls the third-party API every 10–30 seconds and pushes updates. You build one LiveScreen widget per sport (Cricket, Football, F1). Finance uses a single ticker widget. This is the hardest group — build it last.
Group B — Batch Published & Searchable
Data uploaded once. Users search by ID to find their record.
Academic (Board, Entrance, University)
Government Jobs (UPSC, TNPSC, RRB)
Law (Court verdicts)
Healthcare (NEET PG, Medical boards)
Entertainment (Award lists, Charts)
Tech (Benchmark tables, App charts)
Admin uploads CSV once. Backend stores as JSONB. Flutter shows a search form → single result card. This is the core of your platform — 6 out of 11 categories live here. Build this first. It is the simplest and highest value.
Group C — Private, Manual & Access-Controlled
Small organizations. Data entered by hand. Hidden behind password.
Business (Sales boards, Placement results)
Hyper-Local (Tuition mocks, Gully cricket)
Corporate (Hackathons, Team events)
Healthcare (Patient reports)
School internal assessments
Same search form as Group B. Only difference: password gate sits in front. Admin enters data manually on mobile instead of CSV. Build this second — it reuses everything from Group B, you just add the password layer on top.



bash

cat > /mnt/user-data/outputs/ResultHub_Complete_Plan.md << 'ENDDOC'
# ResultHub — Complete Product & Architecture Plan
### Flutter + Spring Boot | Senior Architect Document

---

## TABLE OF CONTENTS

1. [Product Vision & Philosophy](#1-product-vision--philosophy)
2. [The 11 Categories](#2-the-11-categories)
3. [Group B — Batch Published Domains (Deep Plan)](#3-group-b--batch-published-domains-deep-plan)
4. [Domain Themes & UI Rules](#4-domain-themes--ui-rules)
5. [Per-Domain Result Page Specification](#5-per-domain-result-page-specification)
6. [The Core Engine — How One Panel Serves All Domains](#6-the-core-engine--how-one-panel-serves-all-domains)
7. [Workspace & Multi-Tenancy Architecture](#7-workspace--multi-tenancy-architecture)
8. [Admin Panel Flow](#8-admin-panel-flow)
9. [Flutter Widget Architecture](#9-flutter-widget-architecture)
10. [State Management — Riverpod](#10-state-management--riverpod)
11. [Backend API Contract (Spring Boot BFF)](#11-backend-api-contract-spring-boot-bff)
12. [Database Architecture (PostgreSQL + JSONB)](#12-database-architecture-postgresql--jsonb)
13. [Access Control & Privacy Architecture](#13-access-control--privacy-architecture)
14. [FieldRenderer — Smart Display Logic](#14-fieldrenderer--smart-display-logic)
15. [Performance Architecture](#15-performance-architecture)
16. [Phase-by-Phase Build Roadmap](#16-phase-by-phase-build-roadmap)
17. [The Golden Rule](#17-the-golden-rule)

---

## 1. Product Vision & Philosophy

ResultHub is **not** a university results app. It is not a sports app. It is not a court orders app.

ResultHub is a **Generic Data Publishing Platform** — a single engine that any organization in the world can use to publish, manage, and share structured data results with the public or with private teams.

### What This Means

Instead of thinking:
```
❌ University → Exam Results
❌ Court → Case Verdicts
❌ IPL → Match Scores
```

Think:
```
✅ Organization → Workspace → Dataset → Records (JSONB) → Search → Analytics
```

The platform never knows what the data means. Whether an organization publishes exam marks, court rulings, sports standings, job lists, financial reports, or gym leaderboards — **the same engine powers all of them.**

### The Three Social Pillars

The application is split into three core pillars via a global Navigation Bar:

```
[ GLOBAL NAVIGATION BAR ]
         │
         ├──► 📊 RESULTS SPACE       (The One-Stop Data Portal)
         ├──► 📣 COMPLAINT BOX       (Reddit-Style Public Forum)
         └──► 🗳️ VOTING HUB         (Dynamic Opinion Engine)
```

This document focuses entirely on the **Results Space** — specifically Group B (Batch Published domains).

---

## 2. The 11 Categories

These are the 11 domain categories supported by ResultHub. Each is a label for display and routing — the backend engine treats them all identically.

| # | Category | Example Organizations | Update Type |
|---|---|---|---|
| 1 | Academic & Education | State Boards, Universities, Coaching Centers | Batch / Seasonal |
| 2 | Government & Civil Services | UPSC, TNPSC, SSC, RRB, Police Recruitment | Batch Processing |
| 3 | Sports, Gaming & Athletics | IPL, ISL, Olympics, Local Leagues | Real-time / Live |
| 4 | Politics & Elections | Election Commission, State Election Boards | Event-Driven |
| 5 | Finance & Markets | NSE, BSE, RBI, Stock Exchanges | Real-time / Daily |
| 6 | Law & Judiciary | High Courts, District Courts, Consumer Courts | Event-Driven |
| 7 | Entertainment & Awards | Film Bodies, Award Shows, Box Office | Event-Driven |
| 8 | Technology & Digital | AI Leaderboards, App Charts, Benchmarks | Periodic Updates |
| 9 | Healthcare & Medical | Medical Boards, Hospitals, NEET PG | Batch / Protected |
| 10 | Business & Jobs | Placement Cells, HR Departments, Job Portals | Batch / Private |
| 11 | Hyper-Local & Community | Local Leagues, Tuition Centers, Gully Cricket | Manual / Real-time |

### The 3 Behavioral Groups

All 11 categories collapse into exactly 3 data behaviors:

**Group A — Live & Real-Time**
Sports, Finance, Elections (on election day), Hyper-Local live matches.
Needs WebSocket / polling. Build this **last**.

**Group B — Batch Published & Searchable**
Academic, Government, Law, Healthcare, Entertainment, Technology.
Admin uploads CSV once. Users search by ID. Build this **first** — it covers 6 of 11 categories.

**Group C — Private, Manual & Access-Controlled**
Business, Hyper-Local private events, Tuition centers, Corporate internal.
Same as Group B + password gate. Build this **second**.

---

## 3. Group B — Batch Published Domains (Deep Plan)

Group B covers these 6 domains:

| Domain | Access Type | Input Method | Display Mode |
|---|---|---|---|
| 🎓 Academic | Credential Search | Roll No + DOB | Single record card |
| 🏛️ Government | Credential Search | Register No + DOB | Single record card |
| ⚖️ Law | Case Search | Case number only | Single record card |
| 🏥 Healthcare | Credential Search | Candidate ID + DOB | Single record card (always password-protected) |
| 🎬 Entertainment | Public Listing | No input — browse freely | Full ranked list |
| 💻 Technology | Public Listing | No input — browse freely | Full ranked list |

### Key Insight

Academic, Government, Law, Healthcare — these are **Credential Search** domains. The user must prove who they are before seeing any data.

Entertainment and Technology — these are **Public Listing** domains. Anyone can browse the full list without entering anything.

This means Group B actually needs only **two Flutter screen types**:
1. `CredentialSearchScreen` — used by Academic, Government, Law, Healthcare
2. `PublicListingScreen` — used by Entertainment, Technology

---

## 4. Domain Themes & UI Rules

Each domain has a distinct visual identity. This is achieved through a `DomainTheme` object — not by building separate pages.

```dart
class DomainTheme {
  final Color primaryColor;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final String heroIcon;
  final String fontStyle;       // 'serif' for Law, 'sans' for others
  final HeroWidgetType heroType; // GRADE_CIRCLE | RANK_BADGE | CASE_HEADER | SCORE_PANEL | AWARD_PODIUM | LEADERBOARD
}
```

### Theme Map Per Domain

| Domain | Primary Color | Header Feel | Hero Widget | Mood |
|---|---|---|---|---|
| 🎓 Academic | Deep Navy `#1A3A5C` | Dark blue gradient | Grade circle | Institutional, trustworthy |
| 🏛️ Government | Forest Green `#1B3A2F` | Dark green gradient | Merit rank badge | Official, serious |
| ⚖️ Law | Dark Charcoal `#2C2C2C` | Near-black gradient | Case disposition header | Formal, authoritative |
| 🏥 Healthcare | Deep Teal `#0F4C5C` | Teal gradient | Qualifying score panel | Clinical, clean |
| 🎬 Entertainment | Rich Crimson `#8B1A1A` | Deep red-to-gold | Award podium / poster grid | Glamorous, celebratory |
| 💻 Technology | Electric Indigo `#1A1A3E` | Dark purple gradient | Leaderboard rank table | Sharp, precise, modern |

---

## 5. Per-Domain Result Page Specification

---

### 5.1 🎓 Academic — Credential Search

**Theme:** Deep navy blue. Institutional. Serious.

**Access:** Locked. User must enter credentials to see any data.

**Header Components:**
- Organization logo + name (e.g. Tamil Nadu State Board)
- Dataset title (e.g. "Class 12 — March 2026 Results")
- `StatusPill`: DECLARED / UPCOMING / PROCESSING
- Stats bar: Total students, Published date

**Search Form (Credential Gate):**
```
[ Register Number    ]
[ Date of Birth      ]
       [ Get My Result → ]
```

**Result Card (shown after successful search):**
- Hero: Grade Circle (A+, B, C) centered on a dark blue gradient
- Student name + Register number + School name
- Subject-wise marks as horizontal progress bars (0–100)
- Total marks (e.g. 484 / 500)
- Result pill: green PASS / red FAIL
- Percentile rank
- Share button + Download Marksheet button

**Empty State:** "No record found. Double-check your Register Number and Date of Birth."

**Color Palette:**
```
Header:      #1A3A5C → #2D5F8E (gradient)
Pass pill:   #E8F5E9 background, #2E7D32 text
Fail pill:   #FFEBEE background, #C62828 text
Progress bar:#1A3A5C fill
```

---

### 5.2 🏛️ Government — Credential Search

**Theme:** Forest green. Official. Merit-focused.

**Access:** Locked. Register number + DOB required.

**Header Components:**
- Government emblem / logo
- Organization name (e.g. TNPSC, SSC, Railway Recruitment Board)
- Exam name + year
- Stats bar: Total selected, Total applied, Category breakdown

**Search Form:**
```
[ Register Number    ]
[ Date of Birth      ]
       [ Check My Result → ]
```

**Result Card:**
- Hero: Large merit rank badge (square badge, number inside)
- Candidate name + Register number + Category (OBC / Gen / SC / ST)
- Status chips: SELECTED / WAITLIST / NOT SELECTED
- Sub-status chip: Document Verification Pending / Medical Pending
- Score breakdown: Written + Interview + Total
- Category rank
- Post allotted
- Document verification date
- Important notice block (amber background) for next steps

**Color Palette:**
```
Header:      #1B3A2F → #2E6B4F (gradient)
Selected:    #E8F5E9 / #2E7D32
Waitlist:    #FFF8E1 / #F57F17
Rejected:    #FFEBEE / #C62828
Notice box:  #FFF3CD border + background
```

---

### 5.3 ⚖️ Law — Case Search

**Theme:** Dark charcoal / near-black. Formal. Authoritative.

**Access:** Semi-public. Case number only (no DOB required — case verdicts are public record).

**Header Components:**
- Court seal / logo
- Court name (e.g. Madras High Court, Supreme Court of India)
- Judgment dataset title (e.g. "July 2026 Disposed Cases")
- Stats: Total cases disposed, Date range

**Search Form:**
```
[ Case Number        ]
       [ Find Case → ]
```

**Result Card:**
- Header: Case title in serif font (State vs Defendant Name)
- Case number + Filing date
- Verdict chip: CONVICTED / ACQUITTED / DISMISSED / DISPOSED / ADJOURNED
- Judge name
- Bench composition (if multi-judge)
- Judgment date
- Next hearing date (if adjourned)
- Case summary (text block)
- Download Judgment PDF button (if uploaded by admin)

**Color Palette:**
```
Header:      #1C1C1C → #2C2C2C (near-black)
Convicted:   #FFEBEE / #C62828
Acquitted:   #E8F5E9 / #2E7D32
Adjourned:   #E3F2FD / #1565C0
Dismissed:   #F3E5F5 / #6A1B9A
Font:        Serif for case title, Sans for metadata
```

---

### 5.4 🏥 Healthcare — Credential Search (Always Protected)

**Theme:** Deep teal. Clinical. Clean.

**Access:** ALWAYS password-protected, even if workspace is set to public. Medical data requires extra layer.

**Access Flow:**
```
Password Gate → Unlock → Credential Form → Result
```

**Header Components:**
- Organization logo (Hospital / Medical Board)
- Exam name (e.g. NEET PG 2026, AIIMS Nursing Board)
- StatusPill: DECLARED / UPCOMING
- Minimal stats (no personal count shown publicly)

**Search Form (after password unlock):**
```
[ Candidate ID       ]
[ Date of Birth      ]
       [ Get Result → ]
```

**Result Card:**
- Score panel: Large numerical score centered
- Qualifying status: QUALIFIED / NOT QUALIFIED (large pill)
- Subject-wise breakdown (if applicable)
- All India Rank
- State Rank
- Category Rank
- Counselling eligibility status
- Important: NO personal medical details ever shown

**Color Palette:**
```
Header:      #0F4C5C → #1A7A8A (teal gradient)
Qualified:   #E0F2F1 / #00695C
Not Qualified:#FFEBEE / #C62828
Score text:  #FFFFFF on teal
```

---

### 5.5 🎬 Entertainment — Public Listing

**Theme:** Rich crimson to gold. Glamorous. Celebratory.

**Access:** Fully public. No credentials. No form. Just browse.

**Header Components:**
- Event logo / poster (large, visual)
- Event name (e.g. "98th Academy Awards", "Filmfare Awards 2026")
- Subtitle (e.g. "Winners Announced · March 2026")
- Category filter chips: All | Best Film | Best Actor | Best Actress | Technical | Music

**No Search Form** — replaced with:
```
Filter chips + Search bar (search within list)
```

**List Display:**
- Category section headers (e.g. "BEST PICTURE")
- Winner card: Large poster thumbnail + Film/Artist name + WIN badge
- Nominees list (collapsible) below winner
- Vote count (if voting was enabled)

**Special Widgets:**
- Award podium for Top 3 (visually elevated #1 position)
- Box Office: Revenue bars (horizontal bar chart per film)
- Music Charts: Track list with rank number + stream count + rank movement (↑ ↓ =)
- Reality Show: Elimination log with timestamps

**Color Palette:**
```
Header:      #8B1A1A → #C4960A (crimson to gold gradient)
WIN badge:   Gold #F5C518 background, dark text
Nominated:   Silver #C0C0C0
Background:  Deep warm dark (#1A0A0A) for premium feel
```

---

### 5.6 💻 Technology — Public Listing

**Theme:** Electric indigo / dark purple. Precise. Data-dense. Modern.

**Access:** Fully public. No credentials. No form. Just browse.

**Header Components:**
- Benchmark / leaderboard name (e.g. "AI Model Leaderboard — June 2026", "GPU Benchmark Rankings")
- Organization name (e.g. HuggingFace, NotebookLM)
- Last updated timestamp
- Filter chips: All | Category-specific filters

**No Search Form** — replaced with:
```
Filter chips + Column sort headers
```

**List Display:**
- Dense data table format (unlike Entertainment's visual cards)
- Rank | Model/Product Name | Score | Delta (↑↓) | Category | Publisher
- Sortable columns
- Row highlight for #1
- Delta chip: green ↑ (improved) / red ↓ (dropped) / gray = (no change)
- Benchmark score bar (relative, normalized 0–100)

**Special Widgets:**
- App Store Rankings: Icon + App name + Download count + Rating + Category rank movement
- AI Leaderboards: Benchmark score comparison bars, multi-metric table
- GPU Benchmarks: FPS numbers, compute score, price-performance ratio

**Color Palette:**
```
Header:      #1A1A3E → #2D2D6E (deep indigo gradient)
#1 row:      Subtle gold left border
Rank up:     #E8F5E9 / #2E7D32
Rank down:   #FFEBEE / #C62828
Table bg:    Alternating rows for readability
Font:        Monospace for scores and numbers
```

---

## 6. The Core Engine — How One Panel Serves All Domains

This is the most important architectural concept.

### The Restaurant Kitchen Analogy

One kitchen. Different dishes. The kitchen (ResultHub engine) doesn't change. Only the ingredients (field names) and plate presentation (DomainTheme) change.

### Step-by-Step: Same Engine, Different Output

**Step 1 — Admin defines fields (they type whatever column names make sense)**

| School | Court | AI Leaderboard |
|---|---|---|
| roll_number | case_number | model_name |
| student_name | case_title | benchmark_score |
| maths | verdict | category |
| result | judge_name | publisher |
| grade | next_hearing | rank |

**Step 2 — Database stores everything as JSONB (identical structure)**

```json
// School record
{ "roll_number": "2024IT001", "student_name": "Priya", "maths": 94, "result": "PASS" }

// Court record
{ "case_number": "HC/2024/441", "verdict": "ACQUITTED", "judge_name": "Justice Ravi" }

// AI Leaderboard record
{ "model_name": "GPT-5", "benchmark_score": 94.2, "category": "Reasoning", "rank": 1 }
```

**Step 3 — Flutter reads the domain category and applies the correct DomainTheme**

```dart
final theme = DomainThemeFactory.getTheme(workspace.category);
// Returns: colors, hero widget type, font style, layout mode
```

**Step 4 — FieldRenderer applies smart visual rules automatically**

```dart
"result": "PASS"   → green StatusPill
"maths": 94        → progress bar
"next_hearing": "2026-07-10" → formatted date "10 Jul 2026"
"rank": 1          → gold #1 badge
"benchmark_score": 94.2 → numeric bar
```

**Result:** School page looks like a school result. Court page looks like a court record. AI page looks like a tech leaderboard. **Zero category-specific code written.**

---

## 7. Workspace & Multi-Tenancy Architecture

### What is a Workspace?

A Workspace is a **digital organization account** on ResultHub. Every organization that joins gets one.

```
ResultHub (Platform)
    │
    ├─ [Workspace] Tamil Nadu State Board
    │       └─ [Dataset] Class 12 Results 2026
    │       └─ [Dataset] Class 10 Results 2026
    │
    ├─ [Workspace] TNPSC
    │       └─ [Dataset] Group II Final List 2026
    │       └─ [Dataset] Group IV Results 2026
    │
    ├─ [Workspace] Madras High Court
    │       └─ [Dataset] July 2026 Verdicts
    │
    ├─ [Workspace] Filmfare Awards
    │       └─ [Dataset] Filmfare 2026 Winners
    │
    └─ [Workspace] HuggingFace
            └─ [Dataset] Open LLM Leaderboard June 2026
```

### Multi-Tenancy Rules

- Every organization sees **only their own data** in the admin panel
- All organizations use the **exact same admin interface** — no special panels per category
- Data is isolated at the database level via `workspace_id` on every record
- A workspace admin cannot see or access another workspace's data

### Team Roles Per Workspace

| Role | Permissions |
|---|---|
| Owner | Full control — billing, delete workspace, all permissions |
| Admin | Manage datasets, team members, settings |
| Editor | Upload CSV, add/edit records, publish datasets |
| Viewer | Read-only access to admin dashboard and analytics |

---

## 8. Admin Panel Flow

Every organization — school, court, hospital, cricket league — follows this exact same 6-step flow.

### Step 1: Create Workspace

```
Organization Name    → [Text Input]
Organization Type    → [Dropdown: Educational / Government / Sports / Business /
                        Healthcare / Legal / Finance / Media / Technology / Community / Other]
Workspace Slug       → [Auto-generated: e.g. tnpsc, madras-high-court]
Visibility           → [Public / Private / Password-Protected]
Logo                 → [Image Upload]
Description          → [Text Area]
```

### Step 2: Admin Dashboard Opens

```
┌─────────────────────────────────────────┐
│  [Workspace Name] Dashboard             │
├─────────────────────────────────────────┤
│  Total Records  │ Searches Today        │
│  12,000         │ 4,281                 │
│  Datasets       │ Downloads             │
│  8              │ 1,200                 │
├─────────────────────────────────────────┤
│  Left Menu:                             │
│  Dashboard                              │
│  Datasets                               │
│  Records                                │
│  CSV Import                             │
│  Analytics                              │
│  Team                                   │
│  Settings                               │
└─────────────────────────────────────────┘
```

### Step 3: Create Dataset

```
Dataset Name    → [Text: e.g. "2026 Recruitment Results"]
Dataset Type    → [Searchable / Public Listing / Protected Lookup / Private Internal]
Category Tag    → [Academic / Government / Law / Entertainment / Technology / Healthcare]
Status          → [Draft / Active / Upcoming / Closed / Archived]
```

**Dataset Type Definitions:**

| Type | Who Sees It | Search Form Shown? |
|---|---|---|
| Searchable | Anyone — but data only shown after credential match | Yes |
| Public Listing | Anyone — all records visible immediately | No (browse mode) |
| Protected Lookup | Password gate + credential search | Password first, then form |
| Private Internal | Whitelisted users only | Admin-only |

### Step 4: Define Fields (Schema Builder)

Admin types their own column names. No predefined fields.

```
Field 1: [register_number]  Type: [Text]    ✦ Mark as Searchable
Field 2: [student_name]     Type: [Text]
Field 3: [dob]              Type: [Date]    ✦ Mark as Searchable
Field 4: [maths]            Type: [Number]
Field 5: [result]           Type: [Text]
Field 6: [grade]            Type: [Text]
                        [ + Add Field ]
```

Fields marked as **Searchable** become the input fields on the public search form automatically. No coding needed.

**Field Types:**

| Type | Flutter Widget Generated |
|---|---|
| Text | TextFormField |
| Number | TextFormField (numeric keyboard) |
| Date | DatePickerField |
| Dropdown | DropdownButtonFormField |
| Boolean | Switch / Toggle |

### Step 5: Upload Data

**Option 1 — CSV Upload (Best for large datasets)**
- Admin uploads `.csv` file
- System validates columns match the schema defined in Step 4
- System imports each row as one JSONB record
- System indexes the searchable fields
- System shows import summary (success count, error rows)
- Admin clicks **Publish**

**Option 2 — Manual Entry (Best for small/one-off records)**
- Admin fills a form generated from the dataset schema
- One form submission = one JSONB record
- Useful for court orders, announcements, notices

**Option 3 — API Import (Future Feature)**
- External system pushes records via API key

### Step 6: Publish

```
Visibility:  Public / Password-Protected / Private
Access Code: [Optional — for Password-Protected datasets]
Status:      Set to ACTIVE

[ Publish Dataset ]
```

Once published, the result page is live at:
```
resulthub.app/workspace/[slug]/dataset/[id]
```

---

## 9. Flutter Widget Architecture

### File Structure

```
lib/
├── features/
│   └── result_page/
│       │
│       ├── screens/
│       │   ├── credential_search_screen.dart   ← Academic, Gov, Law, Healthcare
│       │   ├── public_listing_screen.dart       ← Entertainment, Technology
│       │   └── record_detail_screen.dart        ← Single record deep-link view
│       │
│       ├── widgets/
│       │   ├── workspace_header.dart            ← Logo, name, category chip, verified badge
│       │   ├── dataset_header.dart              ← Title, StatusPill, LiveBadge, timestamp
│       │   │
│       │   ├── access_control/
│       │   │   ├── password_gate.dart           ← Password barrier widget
│       │   │   ├── private_blocked.dart         ← Private access denied screen
│       │   │   └── access_granted_banner.dart   ← "Access granted" confirmation
│       │   │
│       │   ├── search/
│       │   │   ├── dynamic_search_form.dart     ← Generates form from List<SearchField>
│       │   │   ├── search_field_factory.dart    ← Returns correct widget per FieldType
│       │   │   └── result_output_card.dart      ← Displays JSONB result after search
│       │   │
│       │   ├── listing/
│       │   │   ├── filter_bar.dart              ← Horizontal scroll chips
│       │   │   ├── dynamic_record_tile.dart     ← RecordTileFactory: domain-specific tile
│       │   │   └── listing_stats_bar.dart       ← Total records, last updated
│       │   │
│       │   ├── hero_widgets/
│       │   │   ├── hero_section_factory.dart    ← Returns correct hero per domain
│       │   │   ├── grade_circle_hero.dart       ← Academic
│       │   │   ├── merit_rank_badge_hero.dart   ← Government
│       │   │   ├── case_disposition_hero.dart   ← Law
│       │   │   ├── qualifying_score_hero.dart   ← Healthcare
│       │   │   ├── award_podium_hero.dart       ← Entertainment
│       │   │   └── leaderboard_rank_hero.dart   ← Technology
│       │   │
│       │   ├── engagement/
│       │   │   ├── vote_box_widget.dart         ← Reusable, injectable anywhere
│       │   │   ├── complaint_shortcut.dart      ← "Report an issue" shortcut
│       │   │   └── engagement_footer.dart       ← Wraps both for result pages
│       │   │
│       │   └── shared/
│       │       ├── status_pill.dart             ← DECLARED / PASS / SELECTED etc.
│       │       ├── metric_chip.dart             ← Small data chips
│       │       ├── full_record_panel.dart       ← JSONB key-value renderer
│       │       └── field_renderer.dart          ← Smart per-field display logic
│       │
│       ├── models/
│       │   ├── dataset_meta.dart
│       │   ├── result_record.dart
│       │   ├── search_field.dart
│       │   ├── domain_theme.dart
│       │   └── listing_state.dart
│       │
│       └── providers/
│           ├── dataset_meta_provider.dart
│           ├── access_state_provider.dart
│           ├── search_state_provider.dart
│           ├── listing_provider.dart
│           └── vote_state_provider.dart
```

### The DomainThemeFactory

```dart
class DomainThemeFactory {
  static DomainTheme getTheme(WorkspaceCategory category) {
    switch (category) {
      case WorkspaceCategory.academic:
        return DomainTheme(
          primaryColor: Color(0xFF1A3A5C),
          gradientStart: Color(0xFF1A3A5C),
          gradientEnd: Color(0xFF2D5F8E),
          heroType: HeroWidgetType.gradeCircle,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.government:
        return DomainTheme(
          primaryColor: Color(0xFF1B3A2F),
          gradientStart: Color(0xFF1B3A2F),
          gradientEnd: Color(0xFF2E6B4F),
          heroType: HeroWidgetType.meritRankBadge,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.law:
        return DomainTheme(
          primaryColor: Color(0xFF1C1C1C),
          gradientStart: Color(0xFF1C1C1C),
          gradientEnd: Color(0xFF2C2C2C),
          heroType: HeroWidgetType.caseDisposition,
          fontStyle: FontStyle.italic, // serif for law
        );
      case WorkspaceCategory.healthcare:
        return DomainTheme(
          primaryColor: Color(0xFF0F4C5C),
          gradientStart: Color(0xFF0F4C5C),
          gradientEnd: Color(0xFF1A7A8A),
          heroType: HeroWidgetType.qualifyingScore,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.entertainment:
        return DomainTheme(
          primaryColor: Color(0xFF8B1A1A),
          gradientStart: Color(0xFF8B1A1A),
          gradientEnd: Color(0xFFC4960A),
          heroType: HeroWidgetType.awardPodium,
          fontStyle: FontStyle.normal,
        );
      case WorkspaceCategory.technology:
        return DomainTheme(
          primaryColor: Color(0xFF1A1A3E),
          gradientStart: Color(0xFF1A1A3E),
          gradientEnd: Color(0xFF2D2D6E),
          heroType: HeroWidgetType.leaderboardRank,
          fontStyle: FontStyle.normal,
        );
      default:
        return DomainTheme.generic();
    }
  }
}
```

### HeroSectionFactory

```dart
class HeroSectionFactory {
  static Widget build(HeroWidgetType type, Map<String, dynamic> record) {
    switch (type) {
      case HeroWidgetType.gradeCircle:
        return GradeCircleHero(grade: record['grade'], total: record['total']);
      case HeroWidgetType.meritRankBadge:
        return MeritRankBadgeHero(rank: record['merit_rank'], status: record['status']);
      case HeroWidgetType.caseDisposition:
        return CaseDispositionHero(verdict: record['verdict'], caseTitle: record['case_title']);
      case HeroWidgetType.qualifyingScore:
        return QualifyingScoreHero(score: record['score'], qualified: record['status']);
      case HeroWidgetType.awardPodium:
        return AwardPodiumHero(winner: record['winner'], category: record['category']);
      case HeroWidgetType.leaderboardRank:
        return LeaderboardRankHero(rank: record['rank'], score: record['score']);
      default:
        return GenericDataHero(record: record);
    }
  }
}
```

---

## 10. State Management — Riverpod

### Provider Definitions

```dart
// 1. Dataset metadata — cached per datasetId
final datasetMetaProvider = FutureProvider.family<DatasetMeta, String>(
  (ref, datasetId) => ref.read(resultApiRepo).fetchDatasetMeta(datasetId),
);

// 2. Access control state
final accessStateProvider = StateNotifierProvider<AccessNotifier, AccessState>(
  (ref) => AccessNotifier(),
);
// AccessState: { isPasswordProtected, isUnlocked, isPrivateBlocked, accessToken }

// 3. Search state (Credential Search domains)
final searchStateProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref.read(resultApiRepo)),
);
// SearchState: { formValues, isLoading, result?, error? }

// 4. Listing state (Public Listing domains)
final listingProvider = StateNotifierProvider<ListingNotifier, ListingState>(
  (ref) => ListingNotifier(ref.read(resultApiRepo)),
);
// ListingState: { records, activeFilters, sortBy, cursor, isLoadingMore, hasMore }

// 5. Vote state — injectable per context
final voteStateProvider = StateNotifierProvider.family<VoteNotifier, VoteState, String>(
  (ref, contextId) => VoteNotifier(ref.read(voteApiRepo), contextId),
);
```

### State Flow for Credential Search

```
User opens result page
        ↓
datasetMetaProvider fetches metadata
        ↓
accessStateProvider checks:
  ├── PRIVATE → show PrivateBlockedView (stop)
  ├── PASSWORD_PROTECTED → show PasswordGate
  │       └── User enters code → POST /auth/dataset-access
  │               └── Returns JWT → accessState.isUnlocked = true
  └── PUBLIC → show DynamicSearchForm directly
        ↓
User fills form → searchNotifier.search(formValues)
        ↓
POST /search → returns ResultRecord
        ↓
searchState.result = record → show ResultOutputCard
```

### State Flow for Public Listing

```
User opens result page
        ↓
datasetMetaProvider fetches metadata
        ↓
listingProvider.fetchFirstPage()
        ↓
SliverList renders DynamicRecordTiles
        ↓
User scrolls → listingProvider.fetchNextPage() [cursor-based]
        ↓
User taps filter chip → listingProvider.applyFilter(filter)
```

---

## 11. Backend API Contract (Spring Boot BFF)

### Endpoint 1 — Dataset Metadata

```
GET /api/v1/workspace/{slug}/dataset/{id}/meta

Response 200:
{
  "dataset_id": "uuid",
  "workspace": {
    "name": "Tamil Nadu State Board",
    "slug": "tn-state-board",
    "logo_url": "https://cdn.resulthub.app/logos/tn-board.png",
    "category": "ACADEMIC",
    "is_verified": true
  },
  "dataset_name": "Class 12 March 2026 Results",
  "dataset_type": "SEARCHABLE",
  "status": "DECLARED",
  "is_live": false,
  "search_fields": [
    { "key": "register_number", "label": "Register Number", "type": "TEXT", "required": true },
    { "key": "dob", "label": "Date of Birth", "type": "DATE", "required": true }
  ],
  "display_fields": ["student_name", "school", "department", "maths", "science", "total", "result", "grade"],
  "filter_fields": [],
  "total_records": 842000,
  "last_updated": "2026-06-12T06:00:00Z"
}
```

### Endpoint 2 — Credential Search

```
POST /api/v1/workspace/{slug}/dataset/{id}/search
Headers: X-Access-Token: <jwt_if_protected>
Body: { "register_number": "2022010234", "dob": "2004-05-12" }

Response 200:
{
  "found": true,
  "record": {
    "record_id": "uuid",
    "data": {
      "student_name": "Priya Sundaram",
      "school": "St. Mary's HSS, Chennai",
      "maths": 100,
      "science": 97,
      "total": 484,
      "result": "PASS",
      "grade": "A+"
    }
  }
}

Response 404:
{
  "found": false,
  "message": "No record found for the provided credentials."
}
```

### Endpoint 3 — Public Listing (Paginated)

```
GET /api/v1/workspace/{slug}/dataset/{id}/records
  ?cursor=<cursor_token>
  &limit=20
  &filter_category=Best+Film
  &sort_by=rank
  &sort_dir=asc

Response 200:
{
  "records": [
    { "record_id": "uuid", "data": { "winner": "Oppenheimer", "category": "Best Picture", "rank": 1 } },
    ...
  ],
  "next_cursor": "<cursor_token>",
  "total": 128,
  "has_more": true
}
```

### Endpoint 4 — Password Access

```
POST /api/v1/auth/dataset-access
Body: { "dataset_id": "uuid", "access_code": "RESULTS2026" }

Response 200:
{
  "access_token": "<short_lived_jwt>",
  "expires_in": 3600
}

Response 401:
{
  "error": "INVALID_ACCESS_CODE"
}
```

---

## 12. Database Architecture (PostgreSQL + JSONB)

### Core Tables

```sql
-- Organizations / Tenants
CREATE TABLE workspaces (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    slug            VARCHAR(100) UNIQUE NOT NULL,
    category        VARCHAR(50) NOT NULL,  -- ACADEMIC, GOVERNMENT, LAW, etc.
    visibility      VARCHAR(20) DEFAULT 'PUBLIC',
    logo_url        TEXT,
    is_verified     BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Dataset definitions (schema lives here)
CREATE TABLE datasets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    dataset_type    VARCHAR(30) NOT NULL,  -- SEARCHABLE, PUBLIC_LISTING, PROTECTED_LOOKUP, PRIVATE_INTERNAL
    status          VARCHAR(20) DEFAULT 'DRAFT',
    search_fields   JSONB,   -- [{ key, label, type, required }]
    display_fields  JSONB,   -- ["field1", "field2", ...]
    filter_fields   JSONB,
    total_records   BIGINT DEFAULT 0,
    published_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- All records from all organizations — JSONB
CREATE TABLE records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID REFERENCES workspaces(id),
    dataset_id      UUID REFERENCES datasets(id) ON DELETE CASCADE,
    data            JSONB NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- GIN index for fast JSONB search
CREATE INDEX idx_records_data ON records USING GIN (data);
CREATE INDEX idx_records_dataset ON records (dataset_id);
CREATE INDEX idx_records_workspace ON records (workspace_id);
```

### How JSONB Search Works

```sql
-- Search query: find student by register number and DOB
SELECT * FROM records
WHERE dataset_id = 'uuid'
  AND data->>'register_number' = '2022010234'
  AND data->>'dob' = '2004-05-12'
LIMIT 1;
-- Returns in < 50ms with GIN index on 45 million records
```

---

## 13. Access Control & Privacy Architecture

### Decision Tree

```
User opens Result Page URL
          │
          ▼
Fetch DatasetMeta (always public, no auth needed)
          │
          ├── dataset_type == PRIVATE_INTERNAL?
          │         └──► Show PrivateBlockedView
          │               "Restricted to authorized members only."
          │
          ├── dataset_type == PROTECTED_LOOKUP?
          │         └──► Show PasswordGate
          │               User enters access code
          │               POST /auth/dataset-access
          │               Returns short-lived JWT
          │               Store in SecureStorage
          │               → Unlock search form
          │
          └── dataset_type == SEARCHABLE / PUBLIC_LISTING?
                    └──► Show page directly
```

### Healthcare Special Rule

Healthcare datasets are **always** treated as PROTECTED_LOOKUP — even if the admin accidentally sets visibility to Public. This is enforced at the backend level, not the Flutter level.

```java
// Spring Boot — DatasetMetaService
if (workspace.getCategory() == Category.HEALTHCARE) {
    meta.setDatasetType(DatasetType.PROTECTED_LOOKUP);
}
```

### Security Principles

1. The password gate is **server-side enforced** — the JWT from `/auth/dataset-access` must be validated on every record fetch. The Flutter client never bypasses this.
2. Record data is **never** in the API response without a valid access token for protected datasets.
3. Access tokens are **short-lived** (1 hour) and **dataset-scoped** — a token for Dataset A cannot access Dataset B.
4. The number of password attempts is rate-limited server-side (5 attempts per 15 minutes per IP).

---

## 14. FieldRenderer — Smart Display Logic

This is the widget that makes all domains look different automatically.

```dart
class FieldRenderer {
  static Widget render(String key, dynamic value) {

    // 1. Known status keywords → StatusPill (color-coded)
    if (_isStatusValue(value)) {
      return StatusPill(value: value.toString());
    }

    // 2. Field key suggests a score / marks / percentage → ProgressBar
    if (_isScoreKey(key) && value is num) {
      return ScoreBarWidget(value: value.toDouble(), max: _inferMax(key));
    }

    // 3. Value looks like an ISO date string → FormattedDate
    if (_isDateString(value)) {
      return FormattedDateWidget(isoString: value.toString());
    }

    // 4. Value is a number → Right-aligned bold number
    if (value is num) {
      return NumericValueWidget(value: value);
    }

    // 5. Value is a rank (key contains 'rank') → RankBadge
    if (key.toLowerCase().contains('rank') && value is num) {
      return RankBadgeWidget(rank: value.toInt());
    }

    // 6. Everything else → Plain key-value row
    return DefaultKeyValueRow(key: key, value: value.toString());
  }

  // ─── Helpers ───────────────────────────────────────────────────

  static bool _isStatusValue(dynamic value) {
    const statusKeywords = [
      'PASS', 'FAIL', 'SELECTED', 'NOT SELECTED', 'QUALIFIED',
      'NOT QUALIFIED', 'WAITLIST', 'DECLARED', 'ACQUITTED',
      'CONVICTED', 'DISMISSED', 'ADJOURNED', 'DISPOSED', 'WIN'
    ];
    return statusKeywords.contains(value.toString().toUpperCase());
  }

  static bool _isScoreKey(String key) {
    const scoreKeys = ['marks', 'score', 'percentage', 'cgpa', 'total', 'points'];
    return scoreKeys.any((k) => key.toLowerCase().contains(k));
  }

  static bool _isDateString(dynamic value) {
    if (value is! String) return false;
    return RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value);
  }

  static double _inferMax(String key) {
    if (key.contains('cgpa')) return 10.0;
    if (key.contains('percentage')) return 100.0;
    return 100.0; // default
  }
}
```

### StatusPill Color Rules

| Value | Background | Text Color |
|---|---|---|
| PASS, SELECTED, QUALIFIED, WIN, ACQUITTED | `#E8F5E9` | `#2E7D32` |
| FAIL, NOT SELECTED, NOT QUALIFIED, CONVICTED | `#FFEBEE` | `#C62828` |
| WAITLIST, PENDING, ADJOURNED | `#FFF8E1` | `#F57F17` |
| DECLARED, LIVE, DISPOSED | `#E3F2FD` | `#1565C0` |
| UPCOMING, DRAFT | `#F3E5F5` | `#6A1B9A` |

---

## 15. Performance Architecture

| Challenge | Solution |
|---|---|
| 45M+ records — search speed | PostgreSQL JSONB GIN indexes on all searchable fields |
| Peak traffic on result day (exam boards, election night) | Redis cache: dataset metadata cached 5 min; individual found records cached 1 hour |
| Large CSV imports (100K+ rows) | Spring Boot `@Async` background job; FCM push notification to admin when import completes |
| Concurrent search requests | Connection pooling (HikariCP); read replicas for search queries |
| Public listing of large datasets | Cursor-based pagination (not page numbers); CDN cache for first page |
| Image-heavy workspace logos | `cached_network_image` with memory + disk cache; initials avatar fallback |
| Concurrent vote updates | Write-queue buffer: votes batched every 500ms before DB write |

---

## 16. Phase-by-Phase Build Roadmap

### Phase 1 — Core Engine (Weeks 1–4)
**Goal: A working result search for any Academic / Government dataset**

- [ ] Workspace creation + dataset schema builder (Admin Panel)
- [ ] CSV upload → JSONB record storage pipeline
- [ ] `DatasetMeta` BFF API endpoint
- [ ] `WorkspaceHeader` + `DatasetHeader` Flutter widgets
- [ ] `DynamicSearchForm` (text + date fields)
- [ ] `FullRecordPanel` (basic key-value display, no type-smart rendering yet)
- [ ] `SearchNotifier` + `AccessNotifier` Riverpod providers
- [ ] Academic domain theme (navy blue)
- [ ] Government domain theme (forest green)

**Deliverable:** A school or government body can upload CSV and students can search by roll number + DOB.

---

### Phase 2 — Domain Themes + Hero Widgets (Weeks 5–7)
**Goal: Each domain looks visually distinct**

- [ ] `DomainThemeFactory` implementation
- [ ] `HeroSectionFactory` + all 6 hero widgets
- [ ] `FieldRenderer` with type-smart display logic
- [ ] Law domain theme + `CaseDispositionHero`
- [ ] Healthcare domain theme + password gate enforcement
- [ ] `StatusPill` with full color rule set

**Deliverable:** Academic page looks institutional, Government page looks official, Law page looks formal — from the same codebase.

---

### Phase 3 — Public Listing Domains (Weeks 8–10)
**Goal: Entertainment and Technology listing pages working**

- [ ] `PublicListingScreen` with `FilterBar` + `SliverList`
- [ ] `DynamicRecordTile` with `RecordTileFactory`
- [ ] Cursor-based pagination + infinite scroll
- [ ] Entertainment theme (crimson-gold) + `AwardPodiumHero`
- [ ] Technology theme (dark indigo) + `LeaderboardRankHero`
- [ ] Column-sortable table mode for Tech leaderboards
- [ ] `ListingNotifier` Riverpod provider

**Deliverable:** Award show winners and AI leaderboards render as full browsable public lists.

---

### Phase 4 — Engagement + Access Control (Weeks 11–13)
**Goal: VoteBox, Complaints shortcut, and all privacy modes working**

- [ ] `PasswordGate` widget + `/auth/dataset-access` endpoint
- [ ] `PrivateBlockedView`
- [ ] `VoteBoxWidget` (reusable, context-aware, injectable anywhere)
- [ ] `ComplaintShortcut` widget
- [ ] `EngagementFooter` (wraps both for result pages)
- [ ] Deep-link routing (`/workspace/:slug/dataset/:id/record/:recordId`)
- [ ] Share result card + Download PDF functionality

**Deliverable:** Password-protected datasets work. VoteBox can be dropped into any result page footer.

---

### Phase 5 — Admin Polish + Super Admin Dashboard (Weeks 14–16)
**Goal: Platform is ready for real organizations to onboard**

- [ ] Team management (Owner / Admin / Editor / Viewer roles)
- [ ] Manual record entry form
- [ ] Analytics dashboard (searches, views, downloads per dataset)
- [ ] Super Admin panel (platform-level organization management)
- [ ] FCM notifications (notify admin when CSV import completes; notify subscribers when result declared)
- [ ] Redis caching layer
- [ ] Organization hierarchy (University → Department → Dataset) — enterprise feature

---

## 17. The Golden Rule

> **ResultHub should never be built around any specific category.**

The platform only understands:

```
Organization
     ↓
Workspace
     ↓
Dataset
     ↓
Records (JSONB)
     ↓
Search
     ↓
Analytics
```

Whether the organization publishes exam results, sports scores, recruitment lists, financial data, legal notices, or healthcare reports becomes **irrelevant** — the same engine powers all of them.

The only things that change per domain are:
1. **DomainTheme** — colors, gradients, fonts
2. **HeroWidget** — the visual hero section of the result card
3. **AccessType** — credential search vs public listing vs protected

Everything else — the admin panel, the database schema, the search engine, the JSONB storage, the FieldRenderer — is **identical** for all 11 categories.

This is what makes the architecture scalable, maintainable, and attractive to every type of organization.

---

*Document prepared for ResultHub Flutter + Spring Boot development team.*
*Version 1.0 — June 2026*
ENDDOC
echo "Done. Lines: $(wc -l < /mnt/user-data/outputs/ResultHub_Complete_Plan.md)"
Output

Done. Lines: 1265
Done
