Role

You are a Principal Product Designer, Staff UX Architect, Senior Full Stack Engineer, Enterprise SaaS Architect, and Design System Lead with experience building products comparable to GitHub Enterprise, Notion, Atlassian, Stripe Dashboard, Supabase Studio, Vercel, Linear, Airtable, Microsoft 365 Admin Center, Google Workspace Admin, and Salesforce.

Your mission is to design and build the complete Organization Portal for ResultHub, a world-class enterprise SaaS platform.

This portal is exclusively for organizations.

It is NOT the public website.

It is NOT the mobile application.

It is the command center where organizations securely manage their complete ecosystem.

About ResultHub

ResultHub is a secure multi-tenant data publishing platform consisting of four major ecosystems.

1. Results Space

Organizations publish structured datasets.

Examples

Universities
Schools
Government Departments
Sports Federations
Hospitals
Banks
Companies
NGOs
Election Bodies
Financial Institutions

Users search and retrieve their own records.

2. Complaint Box

Community engagement platform.

Organizations receive

complaints
suggestions
reports
civic issues

Moderators manage discussions.

3. Voting Hub

Organizations create

public polls
private polls
password protected polls

View real-time analytics.

4. Organization Portal

A secure enterprise dashboard used by organizations.

This portal manages everything.

Existing Backend

DO NOT redesign backend.

Use existing Spring Boot APIs.

Backend

Java 21

Spring Boot 3.5

JWT Authentication

PostgreSQL 16

JSONB Generic Database

GIN Search

Analytics

Flyway

Bucket4j

Docker

Testcontainers

Everything should be API ready.

Design Philosophy

The portal should feel like

GitHub Enterprise

Supabase

Stripe

Vercel

Notion

Linear

Atlassian

Google Workspace

Microsoft 365

Framer

Apple

Never look like

Bootstrap Admin

AdminLTE

Metronic

Generic CRUD Dashboard

WordPress Admin

Design Language

Premium SaaS

Minimal

Elegant

Large whitespace

Rounded corners

Smooth animations

Modern gradients

Premium typography

Professional icons

Soft glassmorphism

Dark Mode

Light Mode

Responsive

Accessible

Keyboard friendly

Portal Architecture
Organization Portal

├── Landing Dashboard

├── Workspace Management

├── Dataset Management

├── Dataset Builder

├── Dataset Records

├── CSV Import Center

├── Search Center

├── Complaint Center

├── Poll Center

├── Team Management

├── Organization Analytics

├── Notifications

├── Activity Logs

├── Organization Profile

├── Security Center

├── API & Integrations

├── Billing (Future)

└── Settings
Dashboard

The dashboard should immediately answer

What is happening today?

What requires attention?

How is the organization performing?

Include

Welcome Header

Organization Switcher

Workspace Switcher

Global Search

Quick Actions

Notifications

Recent Activity

Today's Summary

Storage

Health Status

API Status

Recent Imports

Top Datasets

Top Complaints

Recent Polls

Live Visitors

Analytics Cards

Charts

Timeline

Tasks

Announcements

Workspace Module

Organizations can own multiple workspaces.

Examples

Admissions

Examinations

HR

Finance

Hospital

Library

Sports

Training

Recruitment

Departments

Features

Create Workspace

Delete Workspace

Transfer Ownership

Visibility

Members

Permissions

Logo

Banner

Description

Slug

Settings

Analytics

Dataset Management

This is the heart of ResultHub.

Organizations create

Academic Results

Government Results

Sports Statistics

Finance Reports

Hospital Data

Election Data

Recruitment Lists

Tender Results

Scholarships

Merit Lists

Attendance

Rank Lists

Certificates

Placements

and any future dataset.

Features

Create Dataset

Duplicate

Archive

Publish

Draft

Schedule

Import

Export

Analytics

Sharing

Preview

Version History

Dataset Builder

A no-code builder.

Organization should never write SQL.

Features

Dataset Name

Description

Category

Tags

Visibility

Password Protection

Field Builder

Validation Rules

Searchable Fields

Filterable Fields

Sorting

Relationships

JSON Preview

Schema Preview

Live Validation

Dataset Records

Professional spreadsheet interface.

Like Airtable.

Features

Search

Filter

Bulk Edit

Bulk Delete

Import

Export

Undo

Redo

Pagination

Virtual Scrolling

Column Resize

Column Freeze

Selection

History

Audit Trail

CSV Import Center

Enterprise uploader.

Drag Drop

Progress

Validation

Background Processing

History

Retry Failed Rows

Download Error CSV

Logs

Statistics

Import Queue

Search Center

Search Analytics

Popular Searches

No Result Searches

Trending Keywords

Search Suggestions

Search Logs

Performance

Complaint Center

Manage public complaints.

Dashboard

Categories

Status

Assigned Staff

Media

Priority

Comments

Escalation

Resolution Timeline

Analytics

Heatmap

Voting Center

Create Poll

Edit Poll

Schedule

Password Protected

Private

Public

Analytics

Results

Demographics

Participation Rate

Live Votes

Team Management

Invite Members

Departments

Roles

Permissions

RBAC Matrix

Pending Invitations

Last Active

Devices

Sessions

Remove Access

Transfer Ownership

Organization Analytics

Executive Dashboard.

Cards

Views

Visitors

Searches

Downloads

Dataset Views

Complaint Statistics

Poll Participation

Workspace Growth

Storage

Bandwidth

Imports

Exports

Charts

Daily

Weekly

Monthly

Yearly

Realtime

Heatmaps

Countries

Cities

Browsers

Devices

Operating Systems

Notifications

Invitations

Imports

Poll Results

Complaints

Dataset Published

Member Joined

API Alerts

Security Alerts

Activity Logs

Everything is logged.

Login

Logout

Import

Delete

Publish

Permission Changes

Role Changes

Dataset Changes

Security Changes

CSV Upload

Downloads

Search

Organization Profile

Logo

Banner

Description

Industry

Verification

Website

Address

Contact

Social Media

Certificates

Public Page

SEO

Brand Colors

Security Center

This is extremely important.

Show

Active Sessions

Trusted Devices

Recent Logins

2FA

Passkeys

API Tokens

JWT

IP Restrictions

Allowed Domains

Audit Logs

Security Score

Threat Detection

Login History

Failed Attempts

Session Management

Password Policy

Emergency Lockdown

API Center

Generate API Keys

Webhook Management

Usage

Rate Limits

Documentation

SDK

Logs

Future Billing

Subscription

Invoices

Usage

Plans

Payment Methods

Settings

General

Appearance

Notifications

Language

Timezone

Privacy

Backup

Exports

Danger Zone

Navigation

Left Sidebar

Top Navigation

Right Insights Panel

Breadcrumb

Search Everywhere

Command Palette

Quick Create

Floating Actions

Components

Buttons

Cards

Charts

Dialogs

Tables

Data Grid

Drawers

Forms

Tooltips

Skeleton

Tabs

Timeline

Calendar

Kanban

Progress

Status Badges

Charts

Heatmaps

Maps

Animations

Framer Motion quality

Smooth page transitions

Hover animations

Loading skeletons

Animated charts

Micro interactions

Glass hover

Floating cards

Counters

Staggered animations

Color Palette

Primary

Purple (#6D5DF6)

Success

Green

Danger

Red

Warning

Orange

Info

Blue

Neutral

Gray

Premium white backgrounds

Typography

Inter

Modern

Large headings

Readable tables

Consistent spacing

Responsiveness

Desktop

Laptop

Tablet

Mobile

Adaptive Sidebar

Collapsible Panels

Responsive Tables

Accessibility

WCAG AA

Keyboard Navigation

Focus States

Screen Readers

Color Contrast

Technical Constraints
Use the existing Spring Boot backend.
Do not modify authentication architecture.
Keep everything API-ready.
Build reusable components.
Support future scaling.
Multi-tenant by design.
Enterprise RBAC compatible.
Production-ready architecture.
Final Goal

Create an enterprise-grade Organization Portal that feels like the administrative operating system for modern organizations. It should combine the usability of Notion, the structured data management of Airtable, the developer experience of GitHub and Supabase, the polish of Stripe and Linear, and the scalability required for ResultHub's generic JSONB publishing engine.

The portal should allow organizations of any type—including educational institutions, government departments, healthcare providers, financial organizations, sports federations, NGOs, corporations, and media organizations—to manage workspaces, publish datasets, engage communities, run polls, analyze performance, and securely administer their entire digital ecosystem through a single, cohesive, premium interface.