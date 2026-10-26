---
name: BorrowIT — BulSU Campus
description: A warm, photo-first campus equipment borrowing experience.
colors:
  bulsu-maroon: "#791B3A"
  campus-ruby: "#A62D50"
  soft-gold: "#E7B65C"
  gold-wash: "#FFF3D8"
  cool-canvas: "#F1F4F7"
  white-surface: "#FFFFFF"
  soft-field: "#E9EEF2"
  slate-ink: "#26313D"
  muted-slate: "#697583"
  coral-wash: "#F7E9EE"
  availability-green: "#34785E"
typography:
  display:
    fontFamily: "Roboto, sans-serif"
    fontSize: "28sp"
    fontWeight: 800
  title:
    fontFamily: "Roboto, sans-serif"
    fontSize: "22sp"
    fontWeight: 700
  body:
    fontFamily: "Roboto, sans-serif"
    fontSize: "14sp"
    fontWeight: 400
  label:
    fontFamily: "Roboto, sans-serif"
    fontSize: "12sp"
    fontWeight: 500
rounded:
  field: "14dp"
  button: "16dp"
  card: "20dp"
  panel: "26dp"
  pill: "32dp"
spacing:
  xs: "4dp"
  sm: "8dp"
  md: "12dp"
  lg: "16dp"
  xl: "24dp"
components:
  button-primary:
    backgroundColor: "linear-gradient(90deg, {colors.bulsu-maroon}, {colors.campus-ruby})"
    textColor: "{colors.white-surface}"
    rounded: "{rounded.button}"
    height: "52dp"
  input-filled:
    backgroundColor: "{colors.soft-field}"
    textColor: "{colors.slate-ink}"
    rounded: "{rounded.field}"
    padding: "16dp"
  equipment-card:
    backgroundColor: "{colors.white-surface}"
    textColor: "{colors.slate-ink}"
    rounded: "{rounded.card}"
    padding: "12dp"
  equipment-card-selected:
    backgroundColor: "{colors.coral-wash}"
    textColor: "{colors.bulsu-maroon}"
    rounded: "{rounded.card}"
    padding: "12dp"
  navigation-floating:
    backgroundColor: "{colors.white-surface}"
    textColor: "{colors.slate-ink}"
    rounded: "{rounded.pill}"
    height: "72dp"
---

## Overview

**Creative North Star: "BorrowIT, Warmly Campus"**

BorrowIT gives a familiar school borrowing task a brighter campus presence. Rich maroon and ruby carry the brand; soft gold signals selection and small moments of attention; cool gray and white keep real equipment photography in the foreground. Slowly drifting, heavily softened color fields add a quiet sense of life behind the content rather than turning into a competing illustration.

The interface remains a native Android product: Material 3 navigation and controls, readable system-scaled typography, touch-friendly states, and system-aware motion. The two-tone BorrowIT wordmark adds a friendly signature, while availability and requested quantities remain explicit and legible.

**Key Characteristics:**
- University-inspired maroon and ruby are the strongest brand signals.
- Soft gold gives selected navigation, small highlights, and icons a warmer note.
- Real equipment photographs remain the catalog's visual center.
- Cool-gray pages, white rounded cards, and filled fields keep information calm.
- Gentle background movement respects Android's reduced-motion preference.

## Colors

This palette turns a campus maroon into a confident, contemporary action color, balanced with an airy neutral base and a small gold accent.

### Primary
- **BulSU Maroon** (`#791B3A`): Primary Android color role, brand wordmark, and high-priority actions.
- **Campus Ruby** (`#A62D50`): Lighter end of the primary gradient and selected equipment borders.

### Secondary
- **Soft Gold** (`#E7B65C`): Active-state highlights, icons, and small notification accents.
- **Gold Wash** (`#FFF3D8`): A gentle fill behind gold-accented highlights.

### Neutral
- **Cool Canvas** (`#F1F4F7`): Main application background.
- **Gallery White** (`#FFFFFF`): Equipment, authentication, and request cards.
- **Mist Field** (`#E9EEF2`): Resting filled form controls.
- **Slate Ink** (`#26313D`): Primary content and icon color.
- **Muted Slate** (`#697583`): Supporting copy and inactive navigation.
- **Ruby Wash** (`#F7E9EE`): Soft selected equipment surface.
- **Stock Green** (`#34785E`): Text and icon for equipment that is available.

**The Campus Accent Rule.** Maroon owns primary actions; gold is a small highlight, not a second competing primary.

## Typography

**Display Font:** Roboto (Android system sans-serif)  
**Body Font:** Roboto (Android system sans-serif)  
**Label/Mono Font:** Roboto; no separate mono face is used.

**Character:** Use Material's familiar sans-serif foundation with bold headings and measured body copy. Keep all text in scale-aware Flutter text styles so labels and controls follow Android's font-size setting.

### Hierarchy
- **Display** (800, 28sp): The app's prominent wordmark and top-level page greeting.
- **Title** (700, 22sp): Screen headings and equipment names.
- **Body** (400, 14sp): Form instructions, descriptions, and request details.
- **Label** (500, 12sp): Navigation labels, availability, and compact metadata.

## Layout

Use a cool-gray base behind white, generously rounded content groups. Sign-in and registration use centered, scrollable cards with a clear width limit. The dashboard gives the greeting and quick overview a short introduction, then lets actual equipment photos lead a two-column catalog. Selected quantities remain visible on the card and in a concise continuation summary.

Keep request choices, dates, purpose, optional photo, and review in a scrollable form. On compact Android screens, three labeled Material destinations float inset above the system navigation area. Respect display cutouts, keyboard insets, larger text, and native Back behavior.

## Elevation & Depth

Use white surfaces and the cool-gray canvas as the first depth cue. Cards receive a diffuse, low-opacity shadow with a visible offset. Authentication panels and floating navigation can use a slightly deeper soft shadow. The dashboard, sign-in, and registration background carries only low-opacity, heavily blurred maroon/ruby and gold fields with very slow movement; disable the motion when Android requests reduced animation.

**The Soft-Glow Rule.** Blurred color fields stay behind content and never reduce contrast or replace elevation on a functional surface.

## Shapes

Filled inputs use a gentle 14dp corner radius and no resting stroke; focus receives a 2dp maroon outline. Buttons use 16dp corners, cards use approximately 20–22dp, authentication panels use 26dp, and the floating navigation uses a pill-like 32dp silhouette. A selected equipment card uses a maroon border and a subtle ruby-tinted background.

## Components

### Brand Wordmark
- **Treatment:** “Borrow” is bold maroon; “IT” sits in a compact rounded gold-wash lozenge.
- **Use:** App bar and authentication identity. Keep it typographic rather than adding a fabricated institutional seal.

### Buttons
- **Shape:** Rounded rectangle (16dp).
- **Primary:** A maroon-to-ruby gradient with white, bold action text and a soft, downward shadow.
- **Focus / Disabled:** Retain an obvious focus state and lower emphasis when unavailable; keep loading feedback visible.

### Quantity Stepper
- **Style:** A compact gold-wash control with separate, at-least-48dp decrement and increment targets.
- **Behavior:** Selection opens at one; decrementing to zero removes the item; increment is disabled at current available stock. The selected card and form display the resulting count.

### Cards / Containers
- **Corner Style:** Rounded (20–26dp depending on content).
- **Background:** Gallery White on Cool Canvas; selected equipment uses Ruby Wash.
- **Shadow Strategy:** Diffuse and low contrast; the selected equipment also gets a clear maroon outline.
- **Internal Padding:** Commonly 12–22dp.

### Inputs / Fields
- **Style:** Filled Mist Field with no default outline and a 14dp radius.
- **Focus:** A 2dp BulSU Maroon outline.
- **Error / Disabled:** Preserve Material validation text and distinguish disabled controls from active fields.

### Navigation
- **Style:** Three labeled Material destinations inside a floating white pill, inset from Android system bars.
- **Active State:** Warm gold wash and maroon icon/label; inactive destinations use Muted Slate.
- **Profile Menu:** A rounded floating Android navigation panel with a blurred scrim and the Firebase display name and initials.

### Equipment Index
Keep the current Firestore image URL as the dominant tile media. Availability is readable on the photo; names and category sit below. A selected tile has a maroon outline, a subtle tinted body, and a quantity stepper. Never allow its count to exceed currently available stock.

## Do's and Don'ts

### Do:
- **Do** use actual catalog photographs and real Firestore availability.
- **Do** show each requested quantity in the form, confirmation, request list, and history.
- **Do** preserve old request records that do not include a quantity map.
- **Do** honor Android touch targets, system font scaling, safe areas, and reduced motion.
- **Do** keep dynamic user personalization sourced from Firebase Authentication.

### Don't:
- **Don't** replace equipment photographs with icons or invented product images.
- **Don't** use gold for large primary surfaces or body text.
- **Don't** use white as the full-page background.
- **Don't** animate the background when reduced motion is enabled.
- **Don't** imply that selecting equipment reserves inventory; the existing request-review workflow remains authoritative.
