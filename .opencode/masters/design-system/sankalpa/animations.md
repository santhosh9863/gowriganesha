# Animations

> Central reference for all Sankalpa animation specifications.

---

## Core Defaults

| Property | Value |
|----------|-------|
| Duration | **250-300ms** |
| Curve | **`easeOutCubic`** |
| Philosophy | Prefer implicit `Animated*` widgets over `AnimationController` — `AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`, `AnimatedDefaultTextStyle`, `TweenAnimationBuilder` |
| Exceptions | Custom painters, staggered lists, press-scale buttons, complex orchestration |

---

## Page Transitions

### Current (Placeholder)
| Widget | `NoTransitionPage` |
|--------|-------------------|
| Location | `lib/shared/widgets/page_transitions.dart` |
| Status | Reserved for future `fadeSlide` implementation |

### Dashboard Entry
| Property | Value |
|----------|-------|
| Widget | `FadeTransition` with `AnimationController` |
| Duration | 500ms |
| Trigger | `initState` → `ctrl.forward()` |
| Implementation | `_fadeCtrl` in dashboard `State`, disposed on page exit |

### Notification Center Entry
| Property | Value |
|----------|-------|
| Widget | `FadeTransition` with `AnimationController` |
| Duration | 300ms |
| Curve | `Curves.easeIn` |
| Notes | No slide — fade only, preserves visual continuity |

### Entry Page (Login)
| Property | Value |
|----------|-------|
| Widget | `TweenAnimationBuilder<double>` |
| Duration | 700ms |
| Curve | `Curves.easeOut` |
| Effect | Fade (opacity 0→1) + translate (y 24→0) |
| Target | Card container |

---

## Staggered List Animation

### AppStagger
| Property | Value |
|----------|-------|
| Fade | 0→1 |
| Slide | `Offset(0, 0.08)` → `Offset.zero` |
| Delay | `index * 50ms` |
| Total duration | 300ms (controller from parent) |
| Curve | `Curves.easeOut` |
| Implementation | `FadeTransition` + `SlideTransition` inside `Interval` curve |

### Usage
```dart
// Parent provides controller:
late final AnimationController _staggerCtrl;
// initState: _staggerCtrl = AnimationController(vsync: this, duration: 300ms);
// postFrameCallback: _staggerCtrl.forward();
// Wrapping:
AppStagger(index: index, controller: _staggerCtrl, child: item),
```

---

## Notification Banner

| Property | Value |
|----------|-------|
| Slide | Offset(0, -1) → Offset.zero (from top) |
| Fade | 0→1 |
| Duration | 250ms |
| Curve | `Curves.easeOutCubic` |
| Widget | `SlideTransition` + `FadeTransition` |
| Dismiss | Swipe horizontal (velocity > 200) or close button |
| Auto-dismiss | 5s timer |
| Queue | Manages via `InAppBannerNotifier` — shows next after dismiss |

---

## Bottom Navigation

| Property | Value |
|----------|-------|
| Duration | 280ms |
| Curve | `Curves.easeOutCubic` |
| Icon scale | `AnimatedScale` (1.0 ↔ 1.18) |
| Icon/text opacity | `AnimatedOpacity` |
| Icon/text color | `AnimatedDefaultTextStyle` |
| Background | `AnimatedContainer` |
| Notes | **No `AnimationController`** — all implicit (`Animated*` widgets) |

---

## Bell Icon Badge

| Property | Value |
|----------|-------|
| Pulse duration | 600ms |
| Pulse curve | `Curves.easeInOut` |
| Scale | 1.0 ↔ 1.12 |
| Trigger | Unread count > 0 (repeats reverse) |
| Stop | Unread count = 0 (reset to 1.0) |
| Implementation | `AnimationController` + `Transform.scale` via `AnimatedBuilder` |

---

## Progress Bar (Festival Mission)

| Property | Value |
|----------|-------|
| Widget | `TweenAnimationBuilder<double>` |
| Duration | 700ms |
| Curve | `Curves.easeOut` |
| Animation | `begin: 0` → `end: progress` |

---

## Hero Ring (Dashboard)

| Property | Value |
|----------|-------|
| Widget | `TweenAnimationBuilder<double>` on `CustomPainter` |
| Duration | 1000ms |
| Curve | `Curves.easeOutCubic` |
| Animation | Arc sweep from 0 to progress |
| Text percentage | Separate `TweenAnimationBuilder`, same timing, nested in `Stack` |

---

## Filter/Tab Chips

| Property | Value |
|----------|-------|
| Widget | `AnimatedContainer` |
| Duration | 200ms |
| Curves | Default (linear across color/border) |
| Properties animated | `color` (bg), `border` color |

---

## Button Press Effect

| Property | Value |
|----------|-------|
| Widget | `_PressScale` in `app_button.dart` |
| Duration | 100ms |
| Curve | `Curves.easeInOut` |
| Scale | 1.0 → 0.97 |
| Implementation | `AnimationController` + `Listener(onPointerDown/Up/Cancel)` → `Transform.scale` |
| Trigger | Pointer down (if onPressed != null) |

---

## Chart Skeleton (Dashboard)

| Property | Value |
|----------|-------|
| Duration | 2s repeat reverse |
| Opacity range | 0.04 ↔ 0.10 |
| Implementation | `AnimationController` with manual `addListener` + `setState` |
| Animation | `AppColors.warmGray400.withOpacity(o)` cycling on 10 bars of varying height |

---

## AppSkeleton (Shimmer)

| Property | Value |
|----------|-------|
| Duration | 1500ms |
| Pattern | Repeat (no reverse — sweeps left to right) |
| Effect | `LinearGradient` with 3 stops: dim → bright → dim |
| Sweep | `stops: [ctrl.value - 0.3, ctrl.value, ctrl.value + 0.3]` |
| Colors | `surfaceContainerHighest` with alpha 100/200/100 |

---

## Splash Screen

| Animation | Type | Duration | Delay |
|-----------|------|----------|-------|
| "SANKALPA" title | `AnimatedOpacity` 0→1 | 500ms | Immediate |
| Typewriter text | Character-by-character | 40ms/char | 1000ms |
| "No matter what." | `AnimatedOpacity` 0→1 | 400ms | After typewriter |

---

## Do's and Don'ts

**Do:**
- Use `Animated*` widgets for simple state-driven animations
- Use `TweenAnimationBuilder` for one-shot value transitions (progress bars, rings)
- Use `FadeTransition`/`SlideTransition` with `AnimationController` for entry animations
- Keep durations consistent (250-300ms for interaction, 500-700ms for hero)
- Always use `easeOutCubic` for natural-feeling deceleration

**Don't:**
- Use `AnimationController` where an `Animated*` widget suffices
- Over-animate — each animation should serve a UX purpose
- Use different curves for similar animations (keeps feel inconsistent)
- Animate layout-shifting properties (prefer opacity/scale over size changes)
- Forget to `dispose` controllers in `dispose()`
