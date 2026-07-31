# Design System

## Overview

This document describes the design system used in Profit Connect Mobile. All UI components should follow these guidelines for consistency.

## 🎨 Color Palette

### Primary Colors
| Name | Hex | Usage |
|------|-----|-------|
| Primary Dark | `#004D40` | Primary actions, headers, active states |
| Primary Medium | `#00695C` | Secondary actions, hover states |
| Primary Light | `#00897B` | Disabled states, backgrounds |

### Accent Colors
| Name | Hex | Usage |
|------|-----|-------|
| Accent Cyan | `#00BCD4` | Links, highlights, secondary CTAs |
| Accent Orange | `#FF9800` | Warnings, pending states |
| Vibrant Purple | `#7C4DFF` | Premium features, special actions |

### Semantic Colors
| Name | Hex | Usage |
|------|-----|-------|
| Success Green | `#4CAF50` | Success messages, completed states |
| Error Red | `#F44336` | Errors, destructive actions |
| Warning Amber | `#FFC107` | Warnings, attention needed |

### Neutral Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background Primary | `#F5F5F5` | Main app background |
| Background Alt | `#FFFFFF` | Cards, sheets, modals |
| Surface White | `#FFFFFF` | Elevated surfaces |
| Surface Grey | `#F5F5F5` | Secondary surfaces |

### Text Colors
| Name | Hex | Usage |
|------|-----|-------|
| Text Primary | `#212121` | Primary text, headings |
| Text Secondary | `#757575` | Body text, descriptions |
| Text Hint | `#BDBDBD` | Placeholders, disabled text |
| Text On Primary | `#FFFFFF` | Text on primary backgrounds |

### Border & Divider
| Name | Hex | Usage |
|------|-----|-------|
| Divider Light | `#E0E0E0` | Light dividers |
| Divider Medium | `#BDBDBD` | Medium dividers |

### Status Colors
| Name | Hex | Usage |
|------|-----|-------|
| Online Green | `#4CAF50` | Online status |
| Offline Grey | `#9E9E9E` | Offline status |
| Logout Red | `#E53935` | Destructive actions |

## 📝 Typography

### Font Family
- **Primary**: System default (Roboto on Android, San Francisco on iOS)
- **Monospace**: System monospace

### Text Styles

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Headline Large | 32sp | Bold | 1.2 | Page titles |
| Headline Medium | 24sp | Bold | 1.3 | Section headers |
| Headline Small | 20sp | Semi-bold | 1.3 | Card titles |
| Title Large | 18sp | Bold | 1.4 | Section titles |
| Title Medium | 16sp | Semi-bold | 1.4 | List items |
| Title Small | 14sp | Semi-bold | 1.4 | Labels |
| Body Large | 16sp | Regular | 1.5 | Body text |
| Body Medium | 14sp | Regular | 1.5 | Secondary text |
| Body Small | 12sp | Regular | 1.5 | Captions |
| Label Large | 14sp | Semi-bold | 1.4 | Buttons |
| Label Medium | 12sp | Semi-bold | 1.4 | Chips, tags |
| Label Small | 10sp | Semi-bold | 1.4 | Small labels |

## 📐 Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| spaceXs | 4dp | Tight spacing |
| spaceSm | 8dp | Default spacing |
| spaceMd | 16dp | Standard spacing |
| spaceLg | 24dp | Section spacing |
| spaceXl | 32dp | Large section spacing |
| spaceXxl | 48dp | Major section spacing |

## 🔘 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| radiusXs | 4dp | Small elements |
| radiusSm | 8dp | Chips, badges |
| radiusMd | 12dp | Buttons, inputs, cards |
| radiusLg | 16dp | Cards, sheets |
| radiusXl | 24dp | Modals, bottom sheets |
| radiusRound | 50dp | Pills, avatars |

## 🌫️ Shadows

| Level | Blur | Offset | Opacity | Usage |
|-------|------|--------|---------|-------|
| XS | 4dp | 0, 1 | 4% | Subtle elevation |
| SM | 8dp | 0, 2 | 6% | Cards, buttons |
| MD | 16dp | 0, 4 | 8% | Elevated cards |
| LG | 24dp | 0, 8 | 12% | Modals, dialogs |

## 🧩 Component Library

### Buttons

#### Primary (Elevated)
- Background: Primary Dark
- Text: White
- Padding: 24dp horizontal, 12dp vertical
- Radius: 12dp
- States: Default, Pressed, Disabled, Loading

#### Secondary (Outlined)
- Border: Primary Dark (1.5dp)
- Text: Primary Dark
- Padding: 24dp horizontal, 12dp vertical
- Radius: 12dp

#### Tertiary (Text)
- Text: Primary Dark
- Padding: 16dp horizontal, 8dp vertical
- No background

#### Destructive
- Background: Error Red
- Text: White

### Input Fields

#### Default
- Background: Field Background (#F5F5F5)
- Border: Field Border (#E0E0E0)
- Radius: 12dp
- Padding: 16dp horizontal, 14dp vertical
- Placeholder: Text Hint

#### Focused
- Border: Primary Dark (2dp)

#### Error
- Border: Error Red
- Helper text: Error Red

### Cards

#### Default
- Background: Surface White
- Shadow: Shadow SM
- Radius: 12dp
- Padding: 16dp

#### Elevated
- Shadow: Shadow MD

#### Outlined
- Border: Divider Light (1dp)
- No shadow

### Chips

#### Filter Chip
- Selected: Chip Selected bg, Primary Dark text
- Unselected: White bg, Primary Dark border, Primary Dark text
- Radius: 20dp (pill)

#### Input Chip
- With avatar/icon
- Deletable option

#### Choice Chip
- Single selection

### Avatars

| Size | Usage |
|------|-------|
| 20dp | Small (list items) |
| 28dp | Medium (headers) |
| 36dp | Large (profile) |
| 48dp | XL (profile page) |
| 60dp | XXL (hero) |

### Lists

#### Standard List Item
- Height: 56dp min
- Padding: 16dp horizontal
- Divider: Divider Light, inset 16dp

#### Two-line List Item
- Height: 72dp min
- Title: Body Medium
- Subtitle: Body Small

#### Three-line List Item
- Height: 88dp min
- Title: Body Medium
- Subtitle: Body Small x2

## 🌓 Dark Mode

### Color Adjustments

| Light | Dark |
|-------|------|
| Background Primary `#F5F5F5` | `#121212` |
| Surface White `#FFFFFF` | `#1E1E1E` |
| Text Primary `#212121` | `#FFFFFF` |
| Text Secondary `#757575` | `#B0B0B0` |
| Divider Light `#E0E0E0` | `#333333` |
| Field Background `#F5F5F5` | `#2C2C2C` |
| Chip Unselected `#F5F5F5` | `#2C2C2C` |

## ♿ Accessibility

### Contrast Ratios
- **AA**: 4.5:1 for normal text, 3:1 for large text
- **AAA**: 7:1 for normal text, 4.5:1 for large text

### Touch Targets
- Minimum: 48x48dp
- Recommended: 56x56dp

### Focus Indicators
- Visible focus ring for keyboard navigation
- Color: Primary Dark
- Width: 2dp

## 📱 Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 600dp | Single column |
| Tablet | 600-900dp | Two column |
| Desktop | > 900dp | Multi-column |

## 🎯 Animation Guidelines

### Durations
| Type | Duration |
|------|----------|
| Micro | 100ms |
| Standard | 200ms |
| Emphasized | 300ms |
| Page Transition | 300ms |

### Easing
- **Standard**: `easeInOutCubic`
- **Decelerate**: `easeOutCubic`
- **Accelerate**: `easeInCubic`

## 📦 Iconography

- **Style**: Material Icons (Outlined/Filled)
- **Sizes**: 16, 20, 24, 28, 32, 36dp
- **Weight**: Match text weight when inline

## 📋 Implementation Checklist

- [ ] Colors defined in `AppTheme`
- [ ] Text styles in `AppTheme`
- [ ] Spacing constants in `AppTheme`
- [ ] Border radius constants in `AppTheme`
- [ ] Shadow constants in `AppTheme`
- [ ] Light theme implemented
- [ ] Dark theme implemented
- [ ] Component themes in `ThemeData`
- [ ] Typography scales with `flutter_screenutil`
- [ ] RTL support tested
- [ ] Accessibility tested
- [ ] Dark mode tested