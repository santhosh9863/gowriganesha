# Bottom Navigation

> Covers the floating glass bottom navigation bar.

---

## Design

### Philosophy
Zomato-inspired floating glass bottom nav. The nav bar floats above content with a frosted glass backdrop, layered soft shadows, and a sliding active pill. It feels physically attached to the app rather than pasted on top.

### Vertical Structure
```
SafeArea (top: false)
└── SankalpaGlass (sigma: 14, opacity: 0.90)
    ├── borderRadius: 28 (custom — larger than hero for premium look)
    ├── border: AppColors.outline
    ├── tint: AppColors.card
    ├── boxShadow: layered [subtle, soft] for depth
    └── padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4)
        └── SizedBox(height: 58)
            └── LayoutBuilder → Stack
                ├── AnimatedAlign (sliding active pill)
                │   └── Container (pill)
                │       ├── width: itemWidth * 0.92
                │       ├── height: 58
                │       ├── color: AppColors.primaryBg
                │       ├── borderRadius: 14 (softer than standard medium)
                │       └── boxShadow: primary @ 8% opacity, 6px blur
                └── Row
                    └── Expanded × 5 NavBarItems (transparent backgrounds)
```

### Outer Margins
| Edge | Token | Value |
|------|-------|-------|
| Horizontal | `AppSpacing.xl` | 20px (was 16px — more breathing room) |
| Bottom | `AppSpacing.xl` | 20px (was 16px — more breathing room) |

---

## Nav Bar Item Spec

### Active State
| Property | Value |
|----------|-------|
| Background | Transparent (pill is a separate animated layer) |
| Icon scale | 1.15× (via `AnimatedScale`, was 1.18 — less aggressive) |
| Icon opacity | 1.0 |
| Icon color | `AppColors.primary` |
| Text color | `AppColors.primary` |
| Text weight | `FontWeight.w600` |

### Inactive State
| Property | Value |
|----------|-------|
| Background | Transparent |
| Icon scale | 0.95× (via `AnimatedScale`, was 1.0 — more contrast) |
| Icon opacity | 0.50 (was 0.55 — slightly more muted) |
| Icon color | `AppColors.warmGray500` |
| Text color | `AppColors.warmGray500` |
| Text weight | `FontWeight.w500` |

### Layout (per item)
| Property | Value |
|----------|-------|
| Height | 58px |
| Icon size | 22px |
| Icon-label gap | 2px |
| Label font size | 10px |
| Label height | 1.2 |

---

## Navigation Items

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Dashboard | `Icons.dashboard_rounded` | `/` |
| 1 | Sponsors | `Icons.handshake_rounded` | `/collections` |
| 2 | Daily | `Icons.account_balance_wallet_rounded` | `/daily-collections` |
| 3 | Expenses | `Icons.receipt_long_rounded` | `/expenses` |
| 4 | Pending Visits | `Icons.follow_the_signs_rounded` | `/followups` |

---

## Animations

| Property | Value |
|----------|-------|
| Duration | 280ms |
| Curve | `Curves.easeOutCubic` |
| Pill position | `AnimatedAlign` (slides smoothly between items) |
| Icon scale | `AnimatedScale` (0.95 ↔ 1.15) |
| Icon opacity | `AnimatedOpacity` |
| Text style | `AnimatedDefaultTextStyle` |

### Implementation
All animations use implicit `Animated*` widgets — no `AnimationController`s in the nav bar. The pill is a single `AnimatedAlign` within a `Stack` that slides to the active item's position. Each item has a transparent background; the pill provides the visual indicator.

### Sliding Pill Mechanics
- `LayoutBuilder` computes available width → `itemWidth = maxWidth / 5`
- `AnimatedAlign` moves pill to `Alignment(-1.0 + (index + 0.5) * (2.0 / 5), 0)`
- Pill width: `itemWidth * 0.92` (slightly narrower than full item for breathing room)
- Pill radius: 14px (between `small`/`medium` — softer than standard 12)
- Pill shadow: green tint at 8% opacity for subtle depth

---

## Tab Transition

When switching tabs via the bottom nav:

| Property | Value |
|----------|-------|
| Effect | `FadeTransition` 0.92→1.0 |
| Duration | 250ms |
| Curve | `Curves.easeOutCubic` |
| Trigger | `_currentTab` changes → `AnimationController.reset()` + `.forward()` |
| Location | `AppScaffold._tabFadeCtrl` wraps `widget.navigationShell` |

The brief fade dip removes the "instant replace" feeling without a full page transition. Navigation state is preserved via `StatefulShellRoute.indexedStack`.

---

## Shadows

The glass container uses layered soft shadows for a gently lifted appearance:

| Layer | Color | Blur | Offset |
|-------|-------|------|--------|
| 1 | `#0A000000` (4% black) | 8px | 0, 2 |
| 2 | `#06000000` (2.4% black) | 20px | 0, 6 |

The active pill has its own subtle shadow:
| Color | Blur | Offset |
|-------|------|--------|
| `primary @ 8%` | 6px | 0, 2 |

No harsh grey borders — the `AppColors.outline` border on the glass provides edge definition while shadows provide lift.

---

## Interaction Rules

- `HitTestBehavior.opaque` on each item ensures generous tap area
- `GestureDetector` with `onTap` callback — no `InkWell` (avoids ripple on glass)
- `AnimatedBottomNav` receives `currentIndex` + `onTap(int)` from `AppScaffold`
- `AppScaffold` calls `navigationShell.goBranch(index, initialLocation: index == currentIndex)`
- `index == currentIndex` preservation ensures stack state for tab re-selection

---

## FAB Relationship

- FAB is managed by `AppPageScaffold` per-page, not by the navigation bar
- `Scaffold.floatingActionButtonLocation: endFloat` keeps FAB above the nav with natural padding
- Nav horizontal margins (20px) and bottom margin (20px) ensure the nav has breathing room even when a FAB is present
- No collision — the Scaffold manages the layering automatically

---

## Safe Area Behavior

- Top: `SafeArea(top: false)` — nav extends into bottom safe area naturally via the `Padding`
- Bottom: `Padding(bottom: 20)` + `SafeArea(bottom: true)` ensures content above system gesture navigation bar

---

## Do's and Don'ts

**Do:**
- Keep the nav floating — never attach it to the bottom edge
- Use `SankalpaGlass` for frosted backdrop with layered shadows
- Animate all state transitions (pill position, icon scale, icon opacity, text style)
- Use `primaryBg` for the active pill (not solid primary)
- Use `AnimatedAlign` for the sliding pill — keeps the pill animation smooth and GPU-composited

**Don't:**
- Use `InkWell` on the glass container — ripples look wrong on frosted surfaces
- Change the item count (5 is fixed)
- Use `AnimationController` for nav animations — stick to `Animated*` widgets
- Use harsh grey borders — shadows should provide depth, not borders
- Make the pill full item width — 92% width leaves breathing space on each side
