---
name: inspekta-ux-eye
description: Senior UI/UX review lens Inspekta applies to every screen during live testing, beyond the given checklist — hierarchy, spacing, typography, colour/contrast, themes, states, forms, feedback, responsiveness, accessibility, copy, performance perception. Use during /qa and when writing the Senior UI/UX Suggestions section.
---

# The senior UI/UX eye

You are a senior product designer who has shipped many SaaS dashboards. On **every screen**
ask the questions below. Anything notable becomes a suggestion `UX-Snn` in the report, with
a screenshot, *even if the checklist never mentioned it*. Use `design:design-critique`,
`design:accessibility-review` and `design:ux-copy` skills (and uizze / `grit-ui-ux` /
`grit-design-review` when installed) for deeper passes.

## 1. First 5 seconds
- Is it obvious what this page is for and what the primary action is?
- One clear primary button per view? Or competing CTAs?

## 2. Visual hierarchy & layout
- Clear H1 → section → detail progression; important numbers prominent
- Consistent spacing scale (4/8px rhythm); no cramped tables or random gaps
- Alignment: left edges line up; cards same padding; grid holds at all widths
- Density appropriate for the user (admin tables dense, onboarding airy)

## 3. Typography
- ≤ 2 font families, a clear type scale, line length 50–80 chars for prose
- Numeric columns right-aligned, tabular figures; truncation with tooltips

## 4. Colour, contrast & theming
- Text contrast ≥ 4.5:1 (3:1 large); placeholder text not used as label
- Semantic colours consistent (red = destructive/error only; green = success)
- Brand colour used with restraint; no colour-only meaning
- **Dark mode**: no pure-white flashes, readable borders, charts & images adapted,
  shadcn tokens used consistently (no hard-coded hex in one component)

## 5. Components & consistency
- Same component looks/behaves the same everywhere (buttons, inputs, modals, badges)
- Icons from one set, same stroke/size; tooltips on icon-only buttons
- Tables: sortable headers indicated, sticky header on long lists, row actions discoverable

## 6. States (the most-missed area)
- **Loading**: skeletons matching final layout, no layout shift, spinners only for short waits
- **Empty**: explains why it's empty + a next action ("Add your first client")
- **Error**: human message, what to do next, retry; never raw JSON/stack traces
- **Success**: confirmation that names the thing ("Client 'Acme' created")
- **Partial / offline / permission-denied** states exist and are designed

## 7. Forms
- Labels always visible; required/optional marked consistently
- Validate on blur/submit, not every keystroke; errors next to the field
- Correct input types (email, tel, number) and autocomplete attributes
- Sensible defaults; long forms grouped/stepped; unsaved-changes warning

## 8. Feedback & interaction
- Every click gives feedback < 100ms (pressed state, spinner, disabled)
- Destructive actions confirm and name what will be deleted; undo where possible
- Toasts don't cover key UI; don't vanish before they can be read

## 9. Navigation & wayfinding
- Current location highlighted; breadcrumbs on deep pages; page titles in tab
- Back button works; filters/search persist in URL

## 10. Responsive
- Mobile 390px: no horizontal scroll, tap targets ≥ 44px, tables adapt (cards/scroll)
- Navigation collapses sensibly; modals fit the viewport

## 11. Accessibility
- Keyboard: tab through a flow, visible focus ring, no traps, Esc closes modals
- Images have alt; icon buttons have aria-label; headings in order; form errors announced

## 12. Content & microcopy
- Plain words, consistent terms (don't mix "client"/"customer"), sentence case
- Dates/currency in the user's locale; no lorem ipsum or "TODO" left in

## 13. Perceived performance
- Time to first meaningful content; heavy images; janky animations; long blocking requests

## 14. Trust & polish
- Favicon, page titles, branded emails/404s, consistent logo, no broken images

## Suggestion format
```
### UX-S04 · Medium · Empty client list gives no next step
**Seen on:** /clients (new account) ![](evidence/X-empty-clients.png)
**Why it matters:** new users land here first; a blank table reads as "broken".
**Suggestion:** illustration + "No clients yet" + primary "Add client" button + link to import CSV.
```
Prioritise: impact on users × effort. Max ~15 suggestions; merge small ones.
