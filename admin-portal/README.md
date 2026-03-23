# PawPal Admin Portal

A professional Next.js 14 admin dashboard for the PawPal pet care application.

## Features

- **Dashboard** - KPI stats cards + weekly post activity chart + recent signups
- **Users** - Browse all registered users with search
- **Posts** - Moderate community posts with category filters; delete posts
- **Events** - View all events with capacity fill bars and status badges
- **Vets** - Approve/revoke vet verification; filter by status
- **Adoptions** - View all adoption listings with status tracking
- **Lost & Found** - Monitor lost/found reports with urgency levels
- **Auth** - Password-protected via HTTP-only session cookie

## Quick Start

### 1. Configure environment variables

```
cp .env.local.example .env.local
```

Edit `.env.local` with your values (get from Supabase Dashboard -> Settings -> API).

### 2. Install and run

```
npm install
npm run dev
```

Open http://localhost:3000 - you will be redirected to /login.

### 3. Deploy to Vercel

Add all env vars in Vercel dashboard under Settings -> Environment Variables.

## Tech Stack

- Next.js 14 (App Router)
- Tailwind CSS
- Recharts (dashboard charts)
- Supabase JS client
- Lucide React icons
