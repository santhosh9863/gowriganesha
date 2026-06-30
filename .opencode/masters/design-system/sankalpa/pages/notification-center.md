# Page Override: Notification Center

> This file overrides `MASTER.md` for the Notification Center page only.

---

## Notification Tile Spec

| Property | Value |
|----------|-------|
| Height | 76px fixed |
| Background | `AppColors.card` (white) |
| Border radius | `AppRadius.largeBorder` (16px) |
| Shadow | `AppShadows.subtle` |
| Left accent | 4px bar, color = semantic (success/warning/error/info) |
| Icon | 32px, category-specific Material icon |
| Title | `titleSmall` (13px w500) |
| Body | `bodySmall` (13px w400), `maxLines: 2`, overflow ellipsis |
| Timestamp | `labelMedium` (11px w500), `AppColors.warmGray500` |
| Padding | `EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm)` |

## Filter Chip Spec

| State | Style |
|-------|-------|
| Default | `AppColors.warmGray100` bg, `AppColors.warmGray700` text |
| Selected | `AppColors.primary` bg, white text |
| Border radius | `AppRadius.medium` (12px) |
| Animation | `AnimatedContainer`, 250ms easeOutCubic |
| Typography | `labelLarge` (12px w600) |

## Page Layout

| Section | Spacing |
|---------|---------|
| Header | `EdgeInsets.fromLTRB(20, 16, 20, 0)` |
| Filter bar | `EdgeInsets.symmetric(horizontal: 20)` + bottom padding `12` |
| Archive toggle | Trailing edge of row, `SizedBox(width: 20)` right padding |
| List items | `EdgeInsets.symmetric(horizontal: 16)` with `spacing: 8` |
| Section header | `EdgeInsets.only(left: 20, top: 12, bottom: 8)`, `letterSpacing: 0.3` |

## Entry Animation

- `FadeTransition(opacity: from 0 to 1, duration: 300ms)`
- No slide — fade only for page entry
