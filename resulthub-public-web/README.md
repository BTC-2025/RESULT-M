# ResultHub Web Frontend

This repository contains the web-based frontend application for the ResultHub platform. It is a modern, responsive web application designed for high performance and excellent user experience.

## 🚀 Technology Stack

- **Framework:** Next.js (App Router)
- **Library:** React
- **Styling:** Tailwind CSS
- **Language:** TypeScript
- **Bundler:** Turbopack (for local development speed)

## 📋 Prerequisites

Before you begin, ensure you have met the following requirements:
* **Node.js** (v18 or higher) installed.
* **npm** or **yarn** installed.

## 🛠️ Getting Started

Follow these steps to set up the web frontend locally:

### 1. Install Dependencies

Install the required Node.js packages:
```bash
npm install
```

### 2. Environment Setup

Create a local environment file (`.env.local`) based on the project requirements to securely store your API keys and configuration variables:
```bash
# Example .env.local variables
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1
# Add any required secret keys (e.g. SPORTSRC_V2_KEY)
```
*Never commit `.env.local` to the repository.*

### 3. Run the Development Server

Start the local development server with Turbopack for ultra-fast compilation:
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser to see the application.

## 📁 Repository Structure

* `src/app/` - Contains the Next.js App Router pages and API routes.
* `src/components/` - Contains reusable React UI components.
* `src/context/` - Contains React context providers (e.g., AuthContext).
* `public/` - Contains static assets like images and icons.

## 📦 Building for Production

To create an optimized production build, run:
```bash
npm run build
npm start
```

## 🤝 Contributing

When contributing, please follow the established code style, ensure there are no TypeScript errors (`npm run build` will catch these), and submit a Pull Request.
