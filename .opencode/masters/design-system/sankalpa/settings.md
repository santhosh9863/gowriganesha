# Settings Page

> Covers the settings page with all configuration sections.

---

## Layout Hierarchy

```
AppPageScaffold (showBack: true, title: "Settings")
└── ListView (padding bottom: 32)
    ├── Section: Festival Configuration
    │   ├── Budget Card
    │   └── Festival Info Card
    ├── Section: Application
    │   └── About Card
    ├── Section: Data
    │   └── Export Card (if canExport)
    ├── Section: Account
    │   └── Account Card (if logged in)
    └── Section: Administration
        └── Admin Permissions Card (if canAccessSettings)
```

### Section Headers
- `AppSectionHeader` with title + subtitle
- Padding: `EdgeInsets.fromLTRB(16, sm, 16, xs)`
- Spacing between sections: `SizedBox(height: AppSpacing.xl)` — 20px

---

## AppSettingCard (Shared Wrapper)
| Property | Value |
|----------|-------|
| Width | `double.infinity` |
| Padding | `EdgeInsets.all(16)` (configurable) |
| Horizontal margin | `EdgeInsets.symmetric(horizontal: 16)` |
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline border, `AppShadows.subtle` |

---

## Budget Card
| Property | Value |
|----------|-------|
| Icon container | 40x40, `successBg`, `AppRadius.mediumBorder` |
| Icon | `Icons.account_balance_wallet_rounded`, `AppColors.success`, 20px |
| Title | "Festival Budget", `titleSmall`, `charcoal`, `w600` |
| Subtitle | "Total budget for the festival", `labelSmall`, `warmGray500` |
| Edit button | `TextButton.icon` (edit icon + "Edit"), visible if `canChangeBudget` |
| Amount display | `AmountText`, `displaySmall`, `w700`, `charcoal` |
| Budget context | Check icon + remaining amount (`labelMedium`, `success`/`error` `w600`) + "·" + spent amount (`labelSmall`, `warmGray400`) |

### Edit Budget Sheet
- `showModalBottomSheet`, `isScrollControlled: true`, `top: Radius.circular(20)`
- Title: "Edit Festival Budget", `fontSize: 18`, `w700`
- Close button
- Amount field with `prefixText: "₹ "`
- "Save Budget" FilledButton

---

## Festival Info Card
- Displays: Name, Year, Location, Festival Date, UPI ID, Account Name, QR Code
- Each row: 18px icon (`warmGray400`) + label (`labelSmall`, `warmGray500`) + value (`bodyMedium`, `charcoal`, `w600`)
- Editable fields (admin only): Date (date picker), UPI ID (dialog), Account Name (dialog)
- Edit rows: trailing edit icon (14px, `warmGray400`), tappable with `InkWell`

### QR Upload
- Status: "Uploaded" (`success`) or "Not uploaded" (`warmGray400`)
- Buttons: "Upload" / "Replace" (`TextButton.icon`)
- Preview: 120x120 image, `ClipRRect` with `AppRadius.medium`
- Error fallback: `broken_image_rounded` icon + "Load failed" text

---

## About Card
| Property | Value |
|----------|-------|
| Icon container | 40x40, `infoBg`, `AppRadius.mediumBorder` |
| Icon | `Icons.info_outline_rounded`, `AppColors.info`, 20px |
| Title | `AppConstants.appName`, `titleSmall`, `charcoal`, `w600` |
| Version | "Version 1.0", `labelSmall`, `warmGray500` |
| Footer | "Built with Flutter & Firebase", `bodySmall`, `warmGray500` |

---

## Export Card
| Property | Value |
|----------|-------|
| Icon container | 40x40, `warmGray100`, `AppRadius.mediumBorder` |
| Icon | `Icons.download_rounded`, `warmGray500`, 20px |
| Title | "Export Data", `titleSmall`, `charcoal`, `w600` |
| Subtitle | "Sponsors, collections, expenses & visits", `labelSmall`, `warmGray500` |
| Action | `TextButton` "Export", calls `exportAllData()`, visible if `canExport` |

---

## Account Card
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, `AppShadows.soft` |
| Border | `warningBg` (admin) / `outline` (volunteer) |
| Icon container | 40x40, `warningBg` (admin) / `primaryBg` (volunteer) |
| Icon | `Icons.shield_rounded` / `Icons.person_rounded`, 20px |
| Name | `titleSmall`, `charcoal`, `w600`, `maxLines: 1` |
| Role label | "Admin" / "Volunteer", `labelSmall`, `warning`/`warmGray500`, `w600` |

### Admin Actions
- Logout: `TextButton.icon` (`logout_rounded`, `error`)

### Volunteer Actions
- "Switch to Admin": `TextButton.icon` (`arrow_forward_rounded`, `primary`)
- "Logout": `TextButton.icon` (`logout_rounded`, `error`)
- Switch dialog: password field (obscured), Cancel + Login buttons

---

## Admin Permissions Card (ExpansionTile)
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, `warningBg` border, `AppShadows.soft` |
| Leading icon | 40x40, `warningBg`, `admin_panel_settings_rounded`, `warning`, 20px |
| Title | "Admin Controls", `titleSmall`, `charcoal`, `w600` |
| Subtitle | "Tap to view admin permissions", `labelSmall`, `warmGray500` |
| Sections | Sponsors, Collections, Expenses, Visit, Settings, Data |
| Permission items | Checkmark + permission name |
| Tile padding | `EdgeInsets.symmetric(horizontal: 20, vertical: sm(8))` |
| Children padding | `EdgeInsets.fromLTRB(20, 0, 20, 12)` |

---

## Do's and Don'ts

**Do:**
- Use `AppSectionHeader` for section labels
- Group settings into logical sections with clear separation
- Show edit controls only for admin users
- Provide visual feedback on all save operations (snackbar + provider invalidation)

**Don't:**
- Allow non-admin to edit budget, festival info, or export data
- Hardcode strings — use `AppConstants` for app name, currency symbol
- Leave debug print statements in production code
