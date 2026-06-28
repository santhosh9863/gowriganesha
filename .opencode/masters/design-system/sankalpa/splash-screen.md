# Launch Animation

> The landing page (`landing_page.dart`) has been removed. There is no dedicated splash screen.
> The launch experience is now a lightweight `_LaunchAnimation` widget defined at the bottom of `app.dart` — no separate file, no GoRouter route, no page of its own.

---

## Launch Animation

### Purpose
- Premium logo reveal on **cold start only** (process freshly launched)
- Does **not** re-appear on background→resume or recents→reopen
- Plays a minimal animation while Firebase/auth initializes behind the scenes
- Transitions directly into whatever screen the router has resolved (dashboard for authenticated users, entry page for anonymous)

### Lifecycle
- State: in-memory `bool _landingDone` flag in `_GaneshaAppState`
- On cold start: `_landingDone = false` → `MaterialApp.router.builder` wraps content in `_LaunchAnimation`
- Animation runs for 2200ms → calls `_onLandingComplete()` → `setState(() => _landingDone = true)`
- `builder` then returns `child!` directly (animation widget removed from tree)
- Flag persists across app background→resume (in-memory). Naturally clears on process kill.
- Implementation: inline `_LaunchAnimation` widget at end of `lib/app.dart`

### What It Shows
- **Only the official Sankalpa logo** on a warm cream background (`AppColors.surface`)
- A **very subtle golden halo** behind the logo (accent gold @ 10%→3% opacity radial gradient)
- **No text**, no taglines, no "Est. 2026", no loading indicators, no progress bars
- **No animations that bounce, rotate, or flash**

### Animation Timeline (2200ms total)

Uses `AnimationController` with `Interval` curves — designated exception for complex orchestration.

| Phase | Time | Interval | Element | Animation | Curve |
|-------|------|----------|---------|-----------|-------|
| 1 | 0–400ms | 0–0.182 | Logo | `_logoFade` 0→1 | `easeOut` |
| 1 | 0–400ms | 0–0.182 | Logo | `_logoScale` 0.95→1.0 | `easeOutCubic` |
| 2 | 300–700ms | 0.136–0.318 | Golden halo | `_haloOpacity` 0→1 | `easeOut` |
| 3 | 700–1400ms | 0.318–0.636 | Hold | Everything steady | — |
| 4 | 1400–2200ms | 0.636–1.0 | Entire overlay | `_exitFade` 1→0 | `easeOutCubic` |
| 5 | at 2200ms | — | Callback | `onComplete()` → set `_landingDone = true` | — |

### Visual Layout

```
Stack
  ├── [0] widget.child (app content — renders underneath during animation)
  └── [1] FadeTransition (opacity: _exitFade)
       └── Container (color: AppColors.surface)
            └── Center
                 └── Stack (alignment: center)
                      ├── FadeTransition (opacity: _haloOpacity)
                      │    └── Container (150×150, circle)
                      │         └── RadialGradient
                      │              ├── AppColors.accent @ 10%
                      │              ├── AppColors.accent @ 3%
                      │              └── transparent
                      └── ScaleTransition (scale: _logoScale 0.95→1.0)
                           └── FadeTransition (opacity: _logoFade)
                                └── Image.asset (110×110)
                                     └── 'assets/branding/sankalpa_logo.png'
```

### Transition into the App
- The dashboard/entry page renders **underneath** the animation overlay for the full 2200ms
- When `_exitFade` begins at 1400ms, the overlay smoothly dissolves
- The app content is already fully laid out — no flash, no cut, no navigation
- The dashboard's own 500ms `FadeTransition` entry animation has already completed during the hold phase

### Performance Characteristics
- All animations use `FadeTransition`, `ScaleTransition` — GPU-composited, no repaints
- No `setState` during animation frames
- No layout rebuilds — only opacity and scale transforms
- The logo image (1254×1254 PNG) renders at 110×110 — hardware-decoded
- Works at 60/90/120 Hz with no frame drops

---

## Do's and Don'ts

**Do:**
- Let the animation run to completion during cold start (full 2200ms)
- Rely on in-memory flag (no SharedPreferences) for lifecycle management
- Keep the implementation inline in `app.dart` — no separate file needed

**Don't:**
- Show the animation on background→resume — in-memory flag persists
- Add text, taglines, loading messages, or progress bars
- Create a separate page or GoRouter route for the launch experience
- Use bouncing, rotating, or flashy effects
- Block Firebase/auth init — animation plays concurrently
- Reference `landing_page.dart` or `splash_page.dart` — both are orphaned/removed

---

## Entry Page (Login)

> Unchanged. See previous documentation for full specs.
