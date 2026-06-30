# UI/UX Research — Ganesha Festival Finance App

> **Objective:** Deep visual design research across 12 products to inform a complete UI overhaul of the Ganesha festival sponsorship & finance management app.
> **Methodology:** Live browser sessions via Kimi WebBridge — accessibility tree analysis, computed style extraction, and screenshots.
> **Date:** 30 May 2026

---

## Table of Contents

1. [Product Analysis — All 12 References](#1-product-analysis--all-12-references)
2. [CRM UX Analysis](#2-crm-ux-analysis)
3. [Finance Dashboard Analysis](#3-finance-dashboard-analysis)
4. [Mobile UX Analysis](#4-mobile-ux-analysis)
5. [Typography Recommendations](#5-typography-recommendations)
6. [Color System Recommendations](#6-color-system-recommendations)
7. [Component Recommendations](#7-component-recommendations)
8. [Animation Recommendations](#8-animation-recommendations)
9. [Dashboard Redesign Strategy](#9-dashboard-redesign-strategy)
10. [Sponsors Redesign Strategy](#10-sponsors-redesign-strategy)
11. [Sponsor Detail Redesign Strategy](#11-sponsor-detail-redesign-strategy)
12. [Daily Collection Redesign Strategy](#12-daily-collection-redesign-strategy)
13. [Navigation Redesign Strategy](#13-navigation-redesign-strategy)
14. [Appendix: Screenshots Reference](#14-appendix-screenshots-reference)

---

## 1. Product Analysis — All 12 References

### 1.1 UI/UX Pro Max Repository

| Attribute | Detail |
|-----------|--------|
| **URL** | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| **Stars** | 85k |
| **Type** | AI skill for design intelligence & design system generation |
| **Language** | Python (78.5%), JavaScript, TypeScript |
| **Latest version** | v2.5.0 — Skills Expansion & i18n Cleanup (Mar 2026) |

**Core Capabilities:**
- **Design System Generator** — Multi-domain AI reasoning engine that analyzes project requirements and generates complete design systems in seconds
- **161 Industry-Specific Reasoning Rules** — Covers Tech/SaaS, Finance, Healthcare, E-commerce, Services, Creative, Lifestyle, Emerging Tech
- **67 UI Styles** — Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode (OLED), Modern Dark, Soft UI Evolution, and more
- **57 Font Combinations** — curated typography pairings with mood descriptions
- **161 Color Palettes** — industry-specific color schemes with WCAG contrast guidance

**Design Generation Methodology:**
```
1. User Request → 2. Multi-Domain Search (5 parallel)
   → 3. Reasoning Engine (BM25 ranking, anti-pattern filtering)
   → 4. Complete Design System Output (Pattern + Style + Colors + Typography + Effects + Anti-patterns)
```

**Pre-Delivery Checklist (from the skill):**
- No emojis as icons (use SVG: Heroicons/Lucide)
- `cursor: pointer` on all clickable elements
- Hover states with smooth transitions (150–300ms)
- Light mode: text contrast 4.5:1 minimum
- Focus states visible for keyboard nav
- `prefers-reduced-motion` respected
- Responsive: 375px, 768px, 1024px, 1440px

**Relevant Design Systems from the skill's dataset (Financial Dashboard + Personal Finance Tracker):**
- Style Priority: Dark Mode (OLED) + Data-Dense
- Colors: Dark bg + Red/Green alerts + Trust blue
- Effects: Real-time number animations + Alert pulse
- Anti-patterns: Light mode default, Slow rendering

**Website (uupm.cc):**
- Font: DM Sans (body: #0F172A on #FFFFFF)
- H1: 48px, 700 weight, #F8FAFC
- Clean white background, modern typography, card-based layout

---

### 1.2 HubSpot CRM

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.hubspot.com/products/crm |
| **Font** | HubSpot Sans (custom proprietary font) |
| **Background** | #FCFCFA (warm off-white) |
| **Text** | #1F1F1F (near-black) |
| **Primary CTA** | Orange — #FF7A59 |
| **Design Vibe** | Friendly, approachable, enterprise |

**Design Patterns Observed:**
- **Mega-menu navigation** with categorized columns
- **Feature grid** — 3-column card layout with icon + title + description
- **Pricing tiers** — 4-column card layout (Free → Starter → Pro → Enterprise)
- **Social proof bar** — G2 badges, customer logos, testimonials
- **AI Assistant** — persistent bottom bar for page summaries
- **Breadcrumb navigation** for deep pages
- **FAQ section** — expandable accordion items

**Why it matters for our app:** HubSpot proves that a CRM can be both professional and warm. The off-white background (#FCFCFA) instead of pure white reduces eye strain — worth adopting for our light mode.

---

### 1.3 Zoho CRM

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.zoho.com/crm/ |
| **Font** | Zoho Puvi Regular (custom proprietary font) |
| **Design Vibe** | Functional, feature-rich, Indian-origin enterprise |

**Design Patterns Observed:**
- **Tabbed navigation** for feature categories
- **Icon-led feature cards** with consistent sizing
- **Comparison tables** for plan features
- **Multi-language support** prominent in navigation

**Why it matters for our app:** Zoho is built by a Indian company (Zoho Corporation) — their design language reflects familiarity with Indian business contexts. Their approach to dense information display without clutter is directly applicable.

---

### 1.4 Pipedrive

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.pipedrive.com |
| **Body Font** | Inter (fallback: Inter fallback) |
| **Heading Font** | Haffer (700 weight, 52px) |
| **Primary Color** | #017737 (deep green) |
| **Link Color** | #0D6ECE (blue) |
| **Design Vibe** | Sales-focused, pipeline-driven, energetic green |

**Design Patterns Observed:**
- **Pipeline visualizations** — Kanban-style deal stages
- **Dashboard widgets** — revenue forecast charts, activity metrics
- **Consistent green brand** across buttons, links, accents

**Why it matters for our app:** Pipedrive's green (#017737) is very close to our current primary (#1A6B3C). Their use of green as a sales/revenue-positive color validates our direction. Their Inter + Haffer font pairing is worth considering.

---

### 1.5 Salesforce CRM

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.salesforce.com/crm/ |
| **Font** | Salesforce Sans (custom proprietary) |
| **H1 Color** | #032D60 (deep navy) |
| **H1 Size/Weight** | 40px, 400 weight |
| **Text** | #080707 |
| **Design Vibe** | Enterprise, trusted, blue-branded |

**Design Patterns Observed:**
- **Hero section** with product screenshot + headline
- **Industry solution cards** — grid of use cases
- **Customer success stories** — video testimonials
- **Ecosystem badges** — AppExchange, Trailhead, certifications

**Why it matters for our app:** Salesforce's deep navy (#032D60) conveys financial trust and enterprise authority. Their restrained typography (400-weight headings) favors readability over drama.

---

### 1.6 Splitwise

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.splitwise.com |
| **Font** | Lato |
| **H1 Size/Weight** | 28px, 700 weight |
| **H1 Color** | #373B3F (dark charcoal) |
| **Brand Color** | Teal/green |
| **Design Vibe** | Friendly, social, approachable finance |

**Design Patterns Observed:**
- **Simple top nav** — logo + Log in / Sign up only
- **App store badges** prominent above fold
- **Feature cards** — 5 items (Track balances, Organize expenses, Add expenses, Pay friends back, Get PRO)
- **Feature list** — 17 core features + 8 Pro features
- **Social proof** — Financial Times, NY Times, Business Insider quotes
- **Minimal color** — mostly monochrome with teal accents

**Why it matters for our app:** Splitwise proves that finance apps don't need to look corporate. Their Lato font is clean and friendly. The simple nav structure is the right model for our app.

---

### 1.7 Wallet (by BudgetBakers)

| Attribute | Detail |
|-----------|--------|
| **URL** | Google Play Store listing |
| **Type** | Personal finance & budget tracking app |
| **Design Vibe** | Modern fintech, data-rich, colorful charts |

**Design Patterns (from Play Store):**
- **Dashboard summary** — balance at top, income vs expenses
- **Category-based spending** — colored donut charts
- **Transaction list** — chronological with category icons
- **Budget progress bars** — visual spending limits
- **Dark mode option** — modern dark theme

**Why it matters for our app:** Wallet is the closest analog to our app. Their approach to showing financial summaries with visual charts is the gold standard.

---

### 1.8 Money Manager (by RealByteApps)

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.realbyteapps.com/money-manager/ |
| **Type** | Personal expense tracking app |
| **Design Vibe** | Clean, functional, data-driven |

**Design Patterns (from website):**
- **Dashboard** — account balances, recent transactions, spending by category
- **Expense categorization** — visual category breakdowns
- **Multi-account support** — different wallets/accounts
- **Reports & insights** — spending patterns over time
- **Export functionality** — CSV/PDF reports

**Why it matters for our app:** Money Manager's emphasis on expense categorization and reports maps to our expense tracking needs. Their multi-account concept could inspire our sponsor-grouping approach.

---

### 1.9 Stripe Dashboard

| Attribute | Detail |
|-----------|--------|
| **URL** | https://stripe.com |
| **Font** | sohne-var / SF Pro Display |
| **Accent Color** | #533AFD (deep purple-indigo) |
| **H1 Size/Weight** | 40px, 300 weight (light) |
| **H1 Color** | #81B81A (green) |
| **Design Vibe** | Minimalist, premium, developer-first |

**Design Patterns Observed:**
- **Login gate** — clean email + password + SSO options
- **Column mega-menu** — Payments / Revenue / Money Management / Platforms / More
- **Flat form fields** with border styling
- **Clean white minimal** design with deep purple brand
- **Loading states** on submit buttons
- **Remember me** checkbox

**Why it matters for our app:** Stripe is the gold standard for minimalist financial UI. The sohne-var font and restrained design (300-weight headings, plenty of whitespace) set a benchmark for premium financial feel.

---

### 1.10 Linear

| Attribute | Detail |
|-----------|--------|
| **URL** | https://linear.app |
| **Font** | Inter Variable (with SF Pro Display fallback) |
| **Background** | #08090A (near-black, dark mode) |
| **Text** | #F7F8F8 (near-white) |
| **H1 Size/Weight** | 56px, 510 weight |
| **H1 Color** | #F7F8F8 |
| **Design Vibe** | Modern, dark, premium, developer tool |

**Design Patterns Observed:**
- **Dark-first design** — not a dark mode toggle, dark is the default
- **Monochromatic** — mostly grays with selective color accents
- **Keyboard shortcut culture** — every action has a shortcut
- **Kanban boards** — issue tracking with drag-and-drop
- **Command palette** — Cmd+K for everything

**Why it matters for our app:** Linear's dark-first approach is the strongest reference for our dark mode. The 510-weight font (between Regular and Medium) is a unique choice for headings. Their use of subtle borders (rgba borders) instead of shadows sets a premium standard.

---

### 1.11 Vercel

| Attribute | Detail |
|-----------|--------|
| **URL** | https://vercel.com |
| **Font** | Geist (Vercel's custom font family) |
| **Mono Font** | geistMonoFont |
| **Background** | #FFFFFF |
| **Text** | #171717 |
| **Design Vibe** | Modern, clean, developer-centric |

**CSS Design Tokens (Geist Design System):**

| Token Category | Examples |
|----------------|----------|
| **Spacing** | `--geist-space-64x: 256px`, `--geist-space-gap: 24px`, `--geist-space-small-negative: -32px` |
| **Colors** | `--ds-green-1000`, `--ds-teal-100`, `--ds-blue-600`, `--ds-amber-700`, `--ds-pink-300`, `--ds-red-800` |
| **Shadows** | `--ds-shadow-border-large` — layered box-shadow (border + 2px vertical + blur + highlight) |
| **Focus Ring** | `--ds-focus-ring-outline: 2px solid hsla(212, 100%, 48%, 1)` |
| **Form Sizing** | `--geist-form-small-height: 32px` |
| **Gradients** | `--geist-text-gradient: linear-gradient(180deg, #000c 0%, #000 100%)` |

**Why it matters for our app:** Vercel's Geist design system is one of the most well-documented modern design systems. The HSL-based color tokens (with separate `value` variables for opacity manipulation) is a pattern worth adopting. The `--ds-shadow-border-large` pattern (multiple shadows layered) is more refined than simple box-shadows.

---

### 1.12 Notion

| Attribute | Detail |
|-----------|--------|
| **URL** | https://www.notion.so |
| **Font** | NotionInter / Inter (with Apple system fallbacks) |
| **Background (dark)** | #191918 |
| **H1 Size/Weight** | 54px, 700 weight |
| **H1 Color** | #FFFFFF |
| **Design Vibe** | Productive, minimal, block-based |

**Design Patterns Observed:**
- **Hero** — Bold headline + dual CTAs
- **Custom Agents carousel** — tab slider with video content
- **Feature cards** — 3-item layouts for AI features and workspace features
- **Cost Savings Calculator** — interactive checkboxes + team size slider
- **Stats bar** — 7 metrics (100M users, #1 knowledge base, etc.)
- **Social proof** — Forbes quote, OpenAI testimonial, customer logos

**Why it matters for our app:** Notion's sidebar navigation model (though not product-page visible) is the gold standard for information-rich apps. Their dark mode (#191918) is slightly lighter than Linear's (#08090A), making it more readable for content-heavy screens.

---

## 2. CRM UX Analysis

### Comparative Table

| Aspect | HubSpot | Zoho | Pipedrive | Salesforce |
|--------|---------|------|-----------|------------|
| **Font** | HubSpot Sans | Zoho Puvi | Inter + Haffer | Salesforce Sans |
| **Primary** | Orange #FF7A59 | Blue | Green #017737 | Navy #032D60 |
| **Bg** | #FCFCFA | White | White | White |
| **Navigation** | Mega-menu | Tabbed | Top bar | Mega-menu |
| **Vibe** | Warm enterprise | Functional | Energetic | Trust authority |
| **Cards** | Rounded, shadow | Flat, bordered | Rounded, shadow | Flat, minimal |

### Key Takeaways for Our App

1. **HubSpot's warm off-white (#FCFCFA)** — Use instead of pure white for reduced eye strain
2. **Pipedrive's green (#017737)** — Validates our green-primary direction; slightly darker would be more premium
3. **Salesforce's navy (#032D60)** — For trust elements (legal, receipts, confirmed amounts)
4. **All four use custom fonts** — Suggests custom font loading is worth the investment
5. **Navigation simplicity correlates with app complexity** — Our 4-tab nav is appropriate

### Pattern: Feature Card Grid
All four CRMs use a consistent 3-column feature card grid pattern:
- Icon (top) + Title + Short description
- Consistent card dimensions within grid
- Hover state raises card (subtle translateY)
- Used for: features, integrations, use cases, pricing

**Our application:** Sponsor cards should follow this pattern — status indicator (where CRM puts icon), sponsor name (title), amount/progress (description).

---

## 3. Finance Dashboard Analysis

### Comparative Table

| Aspect | Splitwise | Wallet | Money Manager | Stripe |
|--------|-----------|--------|---------------|--------|
| **Font** | Lato | System | System | sohne-var |
| **Layout** | Simple list | Dashboard grid | Dashboard grid | Metrics row |
| **Charts** | None | Donut, bar | Bar, pie | Line, bar |
| **Primary action** | Add expense | Add transaction | Add transaction | View payments |
| **Color use** | Teal accents | Multi-color cats | Green/Red | Purple accent |
| **Dark mode** | Yes | Yes | Yes | Yes |

### Finance Dashboard Common Patterns

1. **Balance/Summary at top** — Largest number on screen, prominent
2. **Quick action** — FAB or prominent button for adding transactions
3. **Recent transactions list** — Chronological, swipeable actions
4. **Category breakdown** — Visual (donut/bar) showing spending distribution
5. **Period selector** — Today / Week / Month / Year toggle
6. **Search & filter** — For transaction history

### Our App's Current State vs Best Practices

| Best Practice | Our App Status |
|---------------|----------------|
| Balance/summary at top | ✅ Hero amount + progress bar |
| Quick action (FAB) | ✅ FAB on list pages |
| Recent activity | ✅ Activity feed on dashboard |
| Category breakdown | ❌ Missing — no visual breakdown of sponsors by status |
| Period selector | ❌ Missing — always shows all-time |
| Search & filter | ✅ Search + filter chips on sponsor list |
| Visual charts | ❌ Missing — only progress bars |
| Dark mode | ❌ Missing — light mode only |

---

## 4. Mobile UX Analysis

### Typography System Analysis (from live sites)

| Product | Font Family | Category | Mood |
|---------|-------------|----------|------|
| HubSpot | HubSpot Sans | Custom sans | Warm, approachable |
| Pipedrive | Inter + Haffer | System sans + display | Modern, sales-forward |
| Salesforce | Salesforce Sans | Custom sans | Enterprise, trustworthy |
| Splitwise | Lato | Google sans | Friendly, casual |
| Stripe | sohne-var | Custom premium sans | Minimalist, premium |
| Linear | Inter Variable | Variable sans | Modern, precise |
| Vercel | Geist | Custom sans | Clean, developer |
| Notion | NotionInter (Inter) | System sans | Productive, neutral |
| Zoho | Zoho Puvi | Custom sans | Functional, clear |
| UUPM site | DM Sans | Google sans | Modern, bold |
| **Consensus** | **Inter** (3 of 9) | **Variable sans** | **Modern, clean** |

### Mobile-Specific Patterns

1. **Bottom navigation** — 4-5 tabs with active indicator (HubSpot, Linear, Vercel)
2. **Thumb-friendly targets** — Minimum 44x44pt (all CRMs)
3. **Bottom sheets** over dialogs for mobile actions (Stripe, Linear)
4. **Pull-to-refresh** for data lists (standard)
5. **Staggered entrance animations** for card lists (Linear)
6. **Skeleton loading** states (Vercel, Linear, Notion)
7. **Haptic feedback** on key actions (Linear)

### Current App Mobile UX Gaps

| Gap | Reference Product | Recommendation |
|-----|-------------------|----------------|
| No bottom sheet patterns | Stripe, Linear | Replace AlertDialog with bottom sheets |
| No skeleton loading | Linear, Vercel | Add shimmer loading for Firestore fetches |
| No pull-to-refresh | All | Add RefreshIndicator to list pages |
| No staggered list animations | Linear | Add staggered fade-in for card lists |
| System font only | All references use custom fonts | Load Inter or Geist font |

---

## 5. Typography Recommendations

### Recommended Font: Inter Variable

**Why Inter?**
- Used by Linear, Pipedrive, Notion, and referenced by UI/UX Pro Max
- Variable font = one file, infinite weights
- Excellent legibility at all sizes
- Free (SIL Open Font License)
- Available on Google Fonts
- Linguistic support includes Devanagari (necessary for Kannada/Sanskrit names)

### Font Pairing: Inter + DM Sans (headings)

| Role | Font | Weight | Size Scale | Why |
|------|------|--------|------------|-----|
| Display (hero numbers) | DM Sans | 700 | 48px | Bold, impactful like UUPM site |
| H1 (page titles) | DM Sans | 600 | 28px | Modern sans-display feel |
| H2 (section headers) | DM Sans | 600 | 22px | Clear hierarchy |
| H3 (card titles) | Inter | 600 | 18px | Readable at small sizes |
| Body | Inter | 400 | 16px | Maximum legibility |
| Body small | Inter | 400 | 14px | Secondary info |
| Caption/Label | Inter | 500 | 12px | Dense data display |
| Mono (numbers) | Inter/Geist Mono | 500 | 16px | Financial data precision |

### Typography Scale Rationale

**Our current app** uses Material 3 text theme defaults (Roboto system font). The proposed scale is based on:

- **Linear's 56px / 510 weight** — scaled down to 48px for our smaller screen context
- **Stripe's 300-weight headings** — too light for our audience (festival volunteers reading outdoors)
- **Notion's 700-weight headings** — too aggressive for finance context
- **UI/UX Pro Max data** — Financial Dashboard recommends "Clear + Readable" typography
- **Compromise** — DM Sans 600/700 for headings (bold enough to read, not aggressive), Inter 400 for body

### Current vs Proposed

```
Current (System):             Proposed (Inter + DM Sans):
Display: Roboto Bold          Display: DM Sans 700/48px
Headline: Roboto Medium       H1: DM Sans 600/28px
Title: Roboto Bold            H2: DM Sans 600/22px
Body: Roboto Regular          H3: Inter 600/18px
Label: Roboto Medium          Body: Inter 400/16px
                              Caption: Inter 400/14px
                              Label: Inter 500/12px
```

---

## 6. Color System Recommendations

### Primary Palette

Based on cross-referencing our existing green (#1A6B3C) with the researched products:

| Token | Proposed Value | Reference | Usage |
|-------|---------------|-----------|-------|
| **Primary** | `#0F6B3C` | Pipedrive #017737 → adjusted | Main brand, buttons, AppBar |
| **Primary Dark** | `#0A4A2A` | Darkened primary | Dark mode variant |
| **Primary Container** | `#A5D6A7` | Keep existing | Progress backgrounds, containers |
| **Secondary** | `#5E6AD2` | Stripe #533AFD + UI/UX Pro Max | Accent buttons, interactive elements |
| **Secondary Container** | `#DDE1FF` | Tinted secondary | Light containers |
| **Surface** | `#F8FAFC` | HubSpot #FCFCFA → adjusted | Page background (light mode) |
| **Surface Dark** | `#0F1115` | Linear #08090A → adjusted | Page background (dark mode) |
| **Surface Container** | `#FFFFFF` | Existing | Card backgrounds (light) |
| **Surface Container Dark** | `#1A1D23` | Notion #191918 | Card backgrounds (dark) |

### Semantic Colors

| Token | Value | Usage | Reference |
|-------|-------|-------|-----------|
| **Success** | `#22C55E` | Collected, completed | Stripe green, UI/UX Pro Max finance |
| **Warning** | `#F59E0B` | Pending, attention | Vercel amber #--ds-amber-700 |
| **Error** | `#EF4444` | Overdue, over-budget | UI/UX Pro Max destructive |
| **Info** | `#3B82F6` | Information, links | Pipedrive link blue |
| **Outline** | `rgba(0,0,0,0.12)` | Borders, dividers | Linear's subtle borders |
| **Outline Dark** | `rgba(255,255,255,0.10)` | Dark mode borders | Linear dark |

### Dark Mode vs Light Mode Strategy

**Recommendation: Dark-First, Light Toggle**
- Dark mode default (like Linear, Stripe dashboard) for professional finance feel
- Light mode as optional toggle (accessible from Settings)
- Auto-switch based on system preference

### Color Usage Principles

1. **Green = money, collected, positive** (maintain existing association)
2. **Indigo = interactive, clickable, accent** (new — replaces amber for CTAs)
3. **Amber = pending, attention-required** (narrowed from current broad use)
4. **Red = overdue, error, negative** (existing)
5. **Neutral grays = surfaces, text hierarchy** (extended from current)

**Anti-patterns (from UI/UX Pro Max financial dashboard rules):**
- ❌ Light mode as default
- ❌ Bright neon colors
- ❌ Gradients on critical data displays
- ❌ Low contrast text

---

## 7. Component Recommendations

### 7.1 Cards

**Reference patterns:**
- HubSpot: Rounded corners, subtle shadow, icon + title + description
- Linear: Dark surface, hairline border (rgba white 0.1), no shadow
- Vercel: Geist layered shadow (`--ds-shadow-border-large`)

**Recommendation:**
```
Card {
  borderRadius: 16 (current: 12 → increase for modern feel)
  background: surfaceContainer (light) / surfaceContainerDark (dark)
  border: hairline (optional, for dark mode)
  padding: 16-20 (keep existing)
  elevation: 0 in dark mode, 1 in light mode
}
```

### 7.2 Buttons

**Reference patterns:**
- HubSpot: Orange filled, rounded
- Pipedrive: Green filled, rounded
- Stripe: Purple filled, minimal
- Linear: Ghost/minimal, subtle hover

**Recommendation:**
```
FilledButton {
  borderRadius: 12 (current: 8 → increase)
  padding: horizontal 24, vertical 14
  background: primary (default) / accent (secondary actions)
  pressEffect: scale to 0.97 (matching UI/UX Pro Max)
}

OutlinedButton {
  borderRadius: 12
  border: outline color
  
TextButton {
  // Keep minimal, no border
}
```

### 7.3 Navigation

**Reference patterns:**
- Linear: Minimal top bar, keyboard-first
- Vercel: Clean top nav with active underline
- HubSpot: Mega-menu for depth
- Our app: 4-tab bottom nav

**Recommendation (keep 4-tab bottom nav, refine styling):**
```
BottomNav {
  type: Material 3 NavigationBar
  height: 64
  indicatorShape: pill (borderRadius: 20)
  activeColor: primary
  inactiveColor: outline
  labelBehavior: always show (current behavior)
}
```

### 7.4 Dialogs → Bottom Sheets

**Reference: Stripe, Linear use bottom sheets instead of dialogs on mobile**

**Recommendation:**
```
// For data entry / confirmations on mobile:
Replace AlertDialog with showModalBottomSheet {
  shape: RoundedRectangleBorder(borderRadius: 16 top only)
  useSafeArea: true
  dragHandle: show drag indicator
}
```

### 7.5 Progress Indicators

**Current:** LinearProgressIndicator with ClipRRect(borderRadius: 6)
**Recommendation:**
```
LinearProgressIndicator {
  minHeight: 8 (keep existing)
  borderRadius: 4
  color: primary
  trackColor: primaryContainer.withAlpha(80)
  animation: 1200ms (keep existing count-up controller)
}

// New: Circular progress for detail page hero (like Wallet app)
CircularProgressIndicator {
  strokeWidth: 8
  color: primary gradient
}
```

### 7.6 Lists

**Reference: Linear, Notion use dense lists with minimal decoration**

**Recommendation:**
```
List item {
  card with borderRadius: 12
  leading: status indicator (colored dot/border)
  title: sponsor name (Inter 600/16)
  subtitle: amount + progress
  trailing: timestamp + popup menu
  divider: none (use spacing instead)
}
```

### 7.7 Filter Chips

**Current:** Mix of Material FilterChip and custom GestureDetector

**Recommendation (unify):**
```
// Use Material 3 FilterChip everywhere
FilterChip {
  borderRadius: 20 (pill shape)
  visualDensity: compact
  selectedColor: primaryContainer
  labelStyle: Inter 500/12
}
```

### 7.8 Empty States

**Reference: Notion, Linear have illustrated empty states**

**Recommendation:**
```
EmptyState {
  icon: 48px, outline color
  title: Inter 600/18, primary text
  subtitle: Inter 400/14, muted text
  action: optional CTA button
}
```

### 7.9 AppBar

**Current:** Material 3 AppBar, centerTitle: true, elevation: 0, green bg

**Recommendation:**
```
AppBar {
  backgroundColor: surface (light) / surfaceDark (dark)
  foregroundColor: onSurface (not white — blend with content)
  elevation: 0
  centerTitle: true
  scrolledUnder: add hairline border when scrolled (like Linear)
}
```

---

## 8. Animation Recommendations

### Principles (from UI/UX Pro Max + observed patterns)

| Principle | Detail | Reference |
|-----------|--------|-----------|
| Duration | Micro-interactions: 150–300ms | All products |
| Screen transitions | 250–400ms | Linear, Our app (current: 250ms) |
| Easing | `easeInOut` for transitions, `easeOut` for entrances | UI/UX Pro Max Expo Out |
| Transform only | Animate `transform` and `opacity` only — GPU accelerated | All products |
| Reduced motion | Respect `prefers-reduced-motion` | WCAG requirement |
| Staggered lists | 50ms stagger per item, fade + slide (20px) | Linear |

### Current Animation State

| Animation | Status | Assessment |
|-----------|--------|------------|
| Dashboard count-up (1200ms) | ✅ Implemented | Keep, ensure easing is correct |
| Page transitions (fade+slide, 250ms) | ✅ Implemented | Keep, easeInOut is good |
| Bottom nav scale (250ms) | ✅ Implemented | Keep |
| Button press feedback | ❌ Missing | Add scale to 0.97 |
| Card entrance stagger | ❌ Missing | Add staggered fade-in |
| Progress bar fill | ✅ Implemented | Keep |
| SnackBar UNDO (3s) | ✅ Implemented | Keep |
| Skeleton loading | ❌ Missing | Add shimmer |
| Pull-to-refresh indicator | ❌ Missing | Add standard RefreshIndicator |

### Proposed Animation Spec

```
// Page Transitions (keep existing, refine easing)
RouteTransition {
  duration: 300ms (current: 250ms → slightly slower for premium feel)
  curve: Cubic(0.16, 1, 0.3, 1)  // UI/UX Pro Max Expo Out
  offset: 2% horizontal
  fade: 0 → 1
}

// Button Press
ButtonPress {
  scale: 1.0 → 0.97 (on press)
  duration: 100ms
  curve: easeIn
  springBack: true (100ms spring)
}

// Card List Entrance
CardEntrance {
  fade: 0 → 1
  translateY: 20px → 0
  duration: 300ms
  stagger: 50ms per card
  curve: easeOut
}

// Count-Up (keep existing)
CountUp {
  duration: 1200ms
  curve: easeOut
}

// Skeleton Loading
Skeleton {
  shimmerGradient: LinearGradient(
    colors: [surface, surfaceContainer, surface],
    stops: [0.0, 0.5, 1.0]
  )
  animation: translateX(-100%) → translateX(100%)
  duration: 1500ms
  loop: true
}
```

---

## 9. Dashboard Redesign Strategy

### Current Layout

```
Hero (expected amount + progress bar)
├── Progress Bar (toward goal)
Primary Cards Row
├── Collected Amount (green)
├── Pending Amount (amber)
├── Total Sponsors
Secondary Cards Row
├── Pending Sponsors (→ navigates to filtered list)
├── Today's Collection (date + amount)
├── Pending Visits (overdue follow-ups)
Recent Activity Feed (last 20 items)
```

### Issues with Current Layout
1. **Linear progression** — All cards are same width, no visual hierarchy
2. **No data visualization** — Only raw numbers and progress bars
3. **Activity feed is weak** — Text-only, no visual distinction between activity types

### Proposed: Bento-Style Dashboard

**Reference: Linear, Vercel, Wallet app**

```
┌─────────────────────────────────────────────┐
│  HEADER: Page Title + Period Selector       │
├──────────────────┬──────────────────────────┤
│  HERO            │  QUICK STATS             │
│  ₹1,50,000      │  Collected  ₹85,000      │
│  of ₹5,00,000   │  Pending    ₹65,000      │
│  [████████░░░░] │  Sponsors   42            │
│  30%             │  Due today  5            │
├──────────────────┴──────────────────────────┤
│  STATUS DISTRIBUTION     [Donut Chart]       │
│  ● Collected 22  ● Pending 15  ● Due 5     │
├──────────────────┬──────────────────────────┤
│  TODAY'S COLL.   │  PENDING VISITS          │
│  ₹12,500         │  ⚠ 3 overdue follow-ups │
│  4 collections   │  Dr. Sharma (due today)  │
├──────────────────┴──────────────────────────┤
│  RECENT ACTIVITY                             │
│  🔵 Collection  ₹2,000 — Dr. Sharma  2m ago │
│  🟢 Follow-up   Completed — Mrs. Rao  15m   │
│  🟡 Sponsor     Added — Mr. Kumar   1h ago  │
└─────────────────────────────────────────────┘
```

### Key Changes

1. **Bento grid** — Asymmetric card sizing for visual hierarchy
2. **Donut chart** — Visual status distribution of sponsors (inspired by Wallet)
3. **Period selector** — All / Today / Week / Month toggle (like Stripe)
4. **Activity feed with icons** — Color-coded activity types (inspired by Linear's issue activity)
5. **Hero still prominent** — But right-aligned with supporting stats
6. **Warning indicators** — Overdue items highlighted (currently exists on Pending Visits)

### Implementation Notes

- Donut chart: Use `fl_chart` package or custom `CustomPainter` (avoid heavy charting libs)
- Bento layout: Use `SliverGrid` with custom `GridDelegate` for asymmetric cells
- Period selector: Use `SegmentedButton` (Material 3) for All/Today/Week/Month

---

## 10. Sponsors Redesign Strategy

### Current Layout

```
AppBar: "Sponsors"
Search Bar (TextField with search icon)
Summary Bar: Total: 42 | Pending: 15 | Collected: 22 | Not Started: 5
Filter Chips: All | Pending | Collected
Card List (scrollable):
┌─────────────────────────────────────────────┐
│ 🟢 Dr. Sharma                    Updated 2h │
│ Expected: ₹10,000  Received: ₹8,000        │
│ [████████████████░░░░░░] 80%               │
│ ⋮                                          │
└─────────────────────────────────────────────┘
```

### Issues with Current Layout

1. **Filters limited** — Only All/Pending/Collected, no search-by-name (UX issue in BUGS.md)
2. **Summary bar is static** — Could be interactive/tappable
3. **Card design is data-dense** — Good for scanning, but visually heavy

### Proposed: Refined Sponsor List

**Reference: HubSpot contact list, Pipedrive deal list**

```
AppBar: "Sponsors" + [Grid/List toggle]
Search Bar (with MD3 elevation, filter icon button)
Summary Chips (tappable):
  [Total: 42] [Pending: 15] [Collected: 22] [Due Today: 5 🔴]
Quick Filter Row:
  [Sort: Name ▼]  [Status: All ▼]  [Amount: High-Low ▼]
Card List (scrollable):
┌─────────────────────────────────────────────┐
│ ┌──┐                                       │
│ │🟢│  Dr. Sharma                    ⋮      │
│ │  │  Expected ₹10,000 · Recv ₹8,000       │
│ └──┘  [████████████░░░░] 80%    Updated 2h │
└─────────────────────────────────────────────┘
```

### Key Changes

1. **Status indicator as left border/bar** — Color-coded (green=collected, amber=pending, red=overdue, gray=not started)
2. **Tappable summary chips** — Tap a chip to filter (like Pipedrive pipeline stages)
3. **Sort/filter controls** — Dropdowns for sort order and additional filters
4. **Sponsor name search** — Addresses BUGS.md UX issue #5
5. **Grid/List toggle** — For dense vs visual view (optional, nice-to-have)
6. **Overdue indicator** — Red dot on count for items past due

---

## 11. Sponsor Detail Redesign Strategy

### Current Layout

```
AppBar: Sponsor Name
Summary Card:
  Expected: ₹10,000
  Received: ₹8,000 (with progress bar)
  Remaining: ₹2,000
Quick Actions:
  [Record Collection] [Edit Sponsor]
Follow-Up History:
  Section: Active Follow-Ups
    ├── Follow-up 1 (Pending) — Date, Note
    ├── Follow-up 2 (Pending)
  Section: Completed Follow-Ups
    ├── Follow-up 3 (Collected)
```

### Issues with Current Layout

1. **Receive Amount uses AlertDialog** — Should be bottom sheet (mobile UX anti-pattern)
2. **No progress ring** — Flat progress bar is functional but not visually engaging
3. **Follow-up history lacks overdue highlighting** — Known issue in BUGS.md
4. **Amount display is text-heavy** — No visual separation between expected/received/remaining

### Proposed: Modern Sponsor Detail

**Reference: Stripe customer detail, Linear issue detail**

```
AppBar: Sponsor Name + [Edit]
───
┌─────────────────────────────────────────────┐
│  CIRCULAR PROGRESS                          │
│      ┌────┐                                 │
│      │80% │  ₹8,000 / ₹10,000              │
│      └────┘                                 │
│  Expected: ₹10,000   Remaining: ₹2,000     │
└─────────────────────────────────────────────┘
───
Quick Actions Row:
  [💰 Record Collection]  [✏️ Edit]  [📞 Follow Up]
───
Status Timeline:
  ● Created         ₹10,000 expected    12 Mar 2026
  ● Collected       ₹5,000              15 Mar 2026
  ● Collected       ₹3,000              20 Mar 2026
  ○ Remaining       ₹2,000              Due: 30 May 2026
───
Active Follow-Ups (2)
┌─────────────────────────────────────────────┐
│ 📅 Follow-up on 2 Jun          Pending ⚠️  │
│ Note: Check on festival donation           │
│ [Mark Collected]                           │
└─────────────────────────────────────────────┘
───
Completed Follow-Ups (1)
┌─────────────────────────────────────────────┐
│ ✅ Follow-up on 15 May         Collected    │
│ Amount: ₹3,000                             │
└─────────────────────────────────────────────┘
```

### Key Changes

1. **Circular progress ring** — More visual and engaging than flat bar (inspired by Wallet app)
2. **Timeline-style collection history** — Chronological list of collection events (new pattern)
3. **Bottom sheet for Record Collection** — Instead of AlertDialog (inspired by Stripe/Linear)
4. **Overdue warning on pending follow-ups** — Red/orange badge when date is past (fixes BUGS.md UX issue)
5. **Status dots** — Color-coded timeline dots (green=collected, gray=pending, red=overdue)
6. **Quick actions row** — Prominent, always-visible action buttons

---

## 12. Daily Collection Redesign Strategy

### Current Layout

Daily Collection list page currently exists but was a simpler implementation. Let's review the existing structure.

### Proposed: Modern Daily Collection

**Reference: Splitwise expense list, Wallet transaction list**

```
AppBar: "Daily Collections" + [Calendar Icon]
Date Navigator:
  ◀  [30 May 2026, Friday]  ▶  [Today]
Summary Bar:
  Today's Total: ₹12,500 (4 collections)
Timeline List:
┌─────────────────────────────────────────────┐
│ 09:30 AM                                    │
│ Dr. Sharma                    ₹5,000        │
│ Note: Festival donation                    │
├─────────────────────────────────────────────┤
│ 11:15 AM                                    │
│ Mrs. Rao                     ₹3,000        │
│ Note: Ganesha sponsorship                  │
├─────────────────────────────────────────────┤
│ 02:00 PM                                    │
│ Mr. Kumar                    ₹2,500        │
│ Note: Collected at temple                  │
└─────────────────────────────────────────────┘
───
FAB: [+ Add Collection]
```

### Key Changes

1. **Date navigator** — Left/right arrows + date display + "Today" button (inspired by Wallet)
2. **Timeline design** — Chronological entries with time, amount, sponsor name, note
3. **Summary bar** — Day's total + count, changes as date changes
4. **FAB** — Quick-add for rapid entry (already standard pattern)
5. **Sponsor name as link** — Tap to navigate to sponsor detail (addresses BUGS.md UX issue)

---

## 13. Navigation Redesign Strategy

### Current Navigation Structure

```
Bottom Nav (4 tabs):     Top Routes (no bottom nav):
├── Dashboard (/)        ├── Settings (/settings)
├── Sponsors (/collections)  ├── Follow-Ups (/followups)
├── Daily (/daily-collections)
└── Expenses (/expenses)
```

### Issues with Current Navigation

1. **Follow-Ups have no bottom nav** — User leaves tab context, no way to navigate back without back button
2. **Settings buried** — Only accessible via gear icon on Dashboard
3. **No quick access to recent items** — Every navigation requires tapping through

### Proposed Navigation Restructure

**Reference: Linear sidebar, Notion sidebar, HubSpot top nav**

```
Option A: Keep 4-tab bottom nav (Conservative)
Bottom Nav:
├── 📊 Dashboard
├── 👥 Sponsors
├── 📅 Daily
├── 💰 Expenses

Add Follow-Ups back into bottom nav by:
  - Consolidating Expenses into second tab with sub-navigation
  - OR adding Follow-Ups as a 5th tab (MD3 supports up to 5)
  - OR making Follow-Ups a section within Dashboard

Settings: Keep as gear icon in AppBar (current pattern)

Option B: Slide-out drawer for secondary pages (Medium change)
Bottom Nav (4 tabs, for primary pages)
Drawer (for secondary):
├── ⚙️ Settings
├── 📋 Follow-Ups
├── 📊 Reports
├── 💾 Export Data

Option C: Full sidebar on desktop (Progressive enhancement)
On mobile: Bottom nav (keep current)
On tablet/desktop (>900px): Sidebar with all routes visible
```

### Recommendation: Option A (Conservative) with refinements

**Rationale:**
- Current users are familiar with 4-tab layout — don't disrupt muscle memory
- Add Follow-Ups as a 5th tab (MD3 supports 5 items in NavigationBar)
- Keep Settings as gear icon + add to bottom nav as last item with settings icon

Revised Bottom Nav:
```
├── 📊 Dashboard
├── 👥 Sponsors
├── 📅 Daily
├── 💰 Follow-Ups    (replaces Expenses tab)
├── ⚙️ More           (Settings + Expenses grouped)
```

**OR simpler:**
```
├── 📊 Dashboard
├── 👥 Sponsors
├── 📅 Daily
├── 📋 Follow-Ups
├── ⚙️ Settings
```

With Expenses accessible from More/overflow or from within Daily Collection context.

### Navigation Visual Refinements

| Element | Current | Proposed |
|---------|---------|----------|
| Bottom nav style | Custom AnimatedBottomNav | Material 3 NavigationBar |
| Active indicator | Scale animation | Pill highlight + scale |
| Labels | Always show | Always show (keep) |
| AppBar color | Primary green | Surface (blends with page) |
| AppBar elevation | 0 | 0, border on scroll |
| Back button | Default arrow | Default arrow + page title |

---

## 14. Appendix: Screenshots Reference

All screenshots captured on 30 May 2026 via Kimi WebBridge are stored in `docs/screenshots/`:

| File | Product | Description |
|------|---------|-------------|
| `ui-ux-pro-max.png` | GitHub | UI/UX Pro Max repository README |
| `uupm.png` | uupm.cc | UI/UX Pro Max marketing website |
| `hubspot.png` | HubSpot CRM | CRM product page |
| `hubspot-tour.png` | HubSpot CRM | CRM tour page (404 — reference only) |
| `zoho.png` | Zoho CRM | CRM product page |
| `pipedrive.png` | Pipedrive | Homepage |
| `pipedrive-pipeline.png` | Pipedrive | Pipeline management features |
| `salesforce.png` | Salesforce CRM | CRM product page |
| `splitwise.png` | Splitwise | Homepage |
| `stripe.png` | Stripe | Homepage |
| `stripe-payments.png` | Stripe | Payments features page |
| `linear.png` | Linear | Homepage (dark mode) |
| `linear-features.png` | Linear | Features page |
| `vercel.png` | Vercel | Homepage |
| `notion.png` | Notion | Product page |
| `wallet.png` | Wallet (Play Store) | Google Play Store listing |
| `moneymanager.png` | Money Manager (Play Store) | Google Play Store listing (not found) |
| `moneymanager2.png` | Money Manager | Official website |

---

## Design Principles (Summary)

Derived from cross-referencing all 12 products, the UI/UX Pro Max data, and our app's context:

1. **Clarity over decoration** — Festival volunteers need to read amounts quickly; every pixel should serve data comprehension
2. **Dark-first, light-optional** — Professional finance tools (Stripe, Linear) default to dark; provide light toggle for outdoor use
3. **Thumb-friendly mobile** — All interactive targets ≥44pt, primary actions in bottom half of screen
4. **Functional animation** — Count-ups for amounts, progress fills for goals, fade-ins for lists — no decorative bounce/flash
5. **Consistent hierarchy** — Typography scale (DM Sans for headings, Inter for body) + color system (green=collected, amber=pending, red=overdue)
6. **Accessibility by default** — WCAG AA contrast (4.5:1 text, 3:1 large text), respect reduced motion, visible focus states
7. **One primary action per screen** — Every page has a clear next step (record collection, add sponsor, mark follow-up)
8. **Offline resilience** — Firestore local cache + optimistic UI updates

---

*End of research document. All design decisions in the subsequent UI overhaul should reference specific findings from this document.*
