# Expo + React Native — Shared Working Rules

Single source of truth for how we build **every** Expo + React Native app in this workspace
(`~/dev/seqix`, `~/dev/pairix`, and every future app). Each project's `CLAUDE.md` imports
this file with `@~/.claude/expo/RULES.md`, so app-specific `CLAUDE.md` files only need to describe
what is unique to that app — everything general lives here.

**When a rule below is genuinely app-specific in practice, the app's own `CLAUDE.md` overrides it.**
Otherwise, treat these as binding defaults.

---

## 1. Expo SDK & version alignment

- **Pin Expo SDK 54.** SDK 54 has full **Expo Go** parity on iOS and Android, which is how we test
  on real devices without a custom dev client. Do not bump the SDK without an explicit decision.
- **Add/upgrade dependencies with `npx expo install <pkg>`, never `npm install <pkg>@x`.** `expo
  install` picks the version aligned with the installed SDK. Hand-picking versions is the #1 source
  of native inconsistencies (mismatched `react-native`, `reanimated`, `worklets`, etc.).
- **Audio: use `expo-audio`, never `expo-av`** (`expo-av` is removed/deprecated).
- Baseline stack: **React 19** + **React Compiler** (`experiments.reactCompiler: true`),
  `react-native` 0.81.x, `expo-router` v6. Keep the whole Expo dependency set on the SDK-54 line.
- **Read the exact versioned docs before writing code:** <https://docs.expo.dev/versions/v54.0.0/>.
  Expo changes fast — do not rely on memory of older APIs. This is what each repo's `AGENTS.md` pins.

## 2. Project structure & tooling

Standard `src/` layout (add folders only when an app needs them):

```
src/
├── app/          # expo-router routes; _layout.tsx root Stack; +html.tsx web shell
├── components/    # presentational + interactive components
├── hooks/         # stateful stores and state machines
├── lib/           # platform integrations; native-only modules get a .web.ts stub
├── constants/     # static registries / config
├── data/          # typed data objects (optional, per app)
└── i18n/          # translations.ts + index.ts
```

- **Path aliases** (`tsconfig.json`): `@/*` → `./src/*`, `@/assets/*` → `./assets/*`.
- **TypeScript `strict`**, `extends "expo/tsconfig.base"`.
- **Web output `static`**; experiments `typedRoutes` + `reactCompiler`.
- **Identity convention:** bundle id `codes.tanis.<app>`, EAS owner `tanis-team`.
- **Isolate native-only modules behind a `.web.ts` stub** so the native module never enters the web
  bundle. Metro resolves `foo.web.ts` for web and `foo.ts` for native automatically (pattern:
  `lib/iap.ts` + `lib/iap.web.ts` in seqix). Anything that `require()`s a native module that has no
  web implementation (IAP, some audio paths) must follow this.

## 3. Multi-device responsive design (CSS-first)

We **always** build multi-device apps. Priority order when designing: **mobile app first → mobile
web → desktop / large screens.** But the goal is a **100% responsive** app that adapts to
everything, driven by `@media` queries — not separate layouts.

- **On web, all responsive rules are real CSS `@media` in `src/app/+html.tsx`**, targeting `#id`
  selectors. Give the element an `id` prop (RNW maps it to the HTML `id`), then style `#id` in the
  `<style>` block. `#id` has specificity 100, beating RNW's generated class rules (010) — no
  `!important` needed — and it's injected before any JS runs, so **zero layout flash**.
- **Never use JavaScript to detect window width and switch styles on web.** That causes hydration
  flashes. RNW 0.21 **silently ignores `@media` inside `StyleSheet.create`** — don't put it there.
- **Never apply inline styles on web for properties CSS handles** — inline styles have specificity
  1000 and override the CSS. Guard native-only inline styles with `Platform.OS !== 'web'`.
- **Native** (iOS/Android) has no CSS layer. Use `useWindowDimensions()` + an `isTablet` flag when a
  breakpoint is needed; keep it `false` on web so it never competes with CSS:
  ```ts
  // Always false on web — CSS in +html.tsx handles responsive sizing there.
  const isTablet = Platform.OS !== 'web' && width >= 600;
  ```
  `width >= 600` covers iPad Mini 6 (744pt) and excludes large phones (430pt).
- **Never hard-code pixel sizes.** Prefer flexbox + percentages + `aspectRatio`, which resolve
  identically at static-prerender, hydration, and on native (`web.output: "static"` prerenders HTML
  in Node where `window` is absent — JS-computed pixel sizes bake a wrong value and then jump).

## 4. Safe areas (mandatory on every screen)

- Every screen must respect device safe areas via **`react-native-safe-area-context`**. This is
  essential for consistent margins across all views.
- Read `useSafeAreaInsets()` and add the relevant inset to padding, gated behind
  `Platform.OS !== 'web'` (insets are zero on web, where CSS handles spacing). `expo-router/entry`
  already wraps the app in a `SafeAreaProvider`.
- This is **not** a violation of "no JS-computed sizing" — clearing the status bar / Dynamic Island
  / notch is an OS-level device-chrome measurement with no CSS/`@media` equivalent on native.
- **Inside a `presentation: 'modal'` screen, do NOT add `insets.top` blindly.** iOS presents the
  modal as a *page sheet* whose card already starts **below** the status bar, yet
  `useSafeAreaInsets()` still returns the **full-screen** `insets.top` (~44–59px). Adding it there
  double-pads and leaves a huge gap above the header. Android draws the modal edge-to-edge, so there
  `insets.top` **is** needed. Gate the **top** inset to Android in modals:
  ```ts
  paddingTop: (Platform.OS === 'android' ? insets.top : 0) + BASE
  ```
  `insets.bottom` **is** legitimate on both platforms inside the sheet (home indicator), so keep it.

## 5. i18n (mandatory)

- **All user-facing text goes through i18n. Never hard-code a display string.**
- Reactive hook `useStrings()` reads a `language` preference (`'auto'` follows the device locale via
  `expo-localization`), so changing the language re-renders the UI. `getStrings(lang)` is the pure
  variant for tests and non-React code. `src/i18n/index.ts` also exports `LANGUAGES` (the picker
  list) and a default static `t`.
- **Always use `useStrings()` in components** — the static `t` won't react to a language change.
- **Keep the language table in the app's `CLAUDE.md` and `README.md` in sync** whenever you add or
  remove a language (one entry in `translations.ts`, one in `LANGUAGES`, update both tables).

## 6. Icons & assets (SVG-first)

- **App icons are authored as SVG** in `assets/`, compiled to PNG per platform with **`make icon`**
  (requires `rsvg-convert`). One SVG source produces every size the platforms need:
  - `icon.svg` → iOS `icon.png` (1024) + `favicon.png` (64)
  - Android adaptive: `icon-android-foreground.svg` / `-background.svg` / `-monochrome.svg` (1024)
  - `splash-icon.png` (512) — transparent, composites over `expo-splash-screen`'s `backgroundColor`
- Any generated per-platform asset (icons, splash, etc.) should be regenerable from an SVG source
  via a Makefile target — never hand-edit the PNGs.
- **Web gotcha:** `@expo/vector-icons` fonts must be injected as `@font-face` in `+html.tsx`
  (pointing at fonts under `public/`). Without the static injection, iOS/Safari renders empty boxes
  because `expo-font`'s runtime injection lands too late.

## 7. Buttons & interactivity (mandatory)

- **No exceptions: every button/pressable in the app ALWAYS has both an `onPress`/onClick handler
  AND a `:hover` effect on web.** Add an `:active` (pressed) state too. A button that does nothing on
  hover (web) or has no press handler is a bug, not a style choice — treat it as incomplete.
- Hover/active styling is web-only CSS in `+html.tsx` on the button's `#id` (applied before JS →
  no flash). Native gets its press feedback from the `Pressable`/touchable itself.
- **Native-first form controls, themed web fallback.** For interactive controls (selects, pickers,
  date/time inputs…), prefer the **platform-native control on iOS/Android** — it inherits the OS
  affordances, wheels/sheets, accessibility and dark mode for free — and use the **native web
  control (`<select>`, `<input>`) styled with CSS** on web (RNW can't reach a form control's chrome
  via style props, so theme it via `#id` in `+html.tsx`). **Don't hand-roll a cross-platform widget
  out of `Pressable`s** to fake one control everywhere: it drifts from each platform's conventions
  and loses native behaviour. Pattern: `LanguagePicker` (seqix) — web `<select>` (`#lang-select`
  CSS), Android inline dropdown, iOS row → bottom-sheet wheel. Same idea as the `.web.ts` split in
  §2: one component, per-platform implementation.

## 8. Code style

- **UTF-8, 4-space indent, LF line endings.** The canonical `.editorconfig`:
  ```ini
  [*]
  indent_style = space
  indent_size = 4
  line_ending = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true

  [*.md]
  trim_trailing_whitespace = false

  [Makefile]
  indent_style = tab
  ```
- **Prettier** (`.prettierrc`): 4-space indent, single quotes, semicolons, `trailingComma: "all"`,
  `printWidth: 100`. `.prettierignore` excludes `node_modules/`, `dist/`, `.expo/`, `assets/`.
- **ESLint** via `eslint-config-expo` (`expo lint`).

## 9. Testing (test everything testable)

- **Every new feature or behaviour change ships with tests.** Preset: **`jest-expo`** (`make test`).
  Specs live in `__tests__/` next to the code and are excluded from the app `tsc` (Babel
  transpiles them).
- **Prefer extracting logic into pure functions and unit-testing those.** It avoids the flakiness of
  rendering hooks under React 19's strict `act()`. Keep hooks as thin orchestration over pure
  helpers (e.g. `normalizeEntries`/`insertScore`, `normalizeProgress`, `classifyMove`).
- **Native-only paths can't run under jest** (IAP via `expo-iap`, audio playback). Cover the
  underlying logic instead: the web stub, clamp/options/timing/theme helpers, i18n resolution, data
  validation, merge/sort logic.

## 10. Makefile (single entry point for every action)

Every app action is a Makefile target — this is the interface, not raw `npm`/`npx`. Standard set:

| Target | Purpose |
|---|---|
| `install` | `npm install` + `npx playwright install chromium` |
| `run` / `web` | Start the web app |
| `android` / `ios` | Start on emulator / simulator |
| `android-device` | Build a standalone release-signed APK + install on a USB device |
| `lint` / `lint-fix` | ESLint (+ auto-fix) |
| `format` | Prettier over `src/` and `scripts/` |
| `test` / `test-coverage` | Jest (+ coverage) |
| `build` | Export static web build |
| `build-android` / `build-ios` | Release AAB locally / EAS iOS build + submit |
| `icon` / `sounds` | Regenerate assets from source |
| `screenshots` | Visual-QA sweep (see §11) |
| `clean` | Remove build artifacts and cache |

- The Makefile is **tab-indented** (`.editorconfig` enforces this for `Makefile`).
- **Pin `JAVA_HOME` to JDK 21** with `:=` (not `?=`) so an sdkman-exported `JAVA_HOME` can't win:
  `export JAVA_HOME := $(HOME)/.sdkman/candidates/java/21.0.11-zulu`.

## 11. Screenshots QA target

`make screenshots` boots the web build and drives headless Chromium (Playwright) through the app at
every device size, writing PNGs under `screenshots/<device>/`. It starts/stops its own dev server.

**Canonical device matrix (13)** — keep this list in every app's `scripts/screenshot-devices.js`:

| Slug | Device | Viewport |
|---|---|---|
| `desktop` | Desktop | 1440×900 |
| `mobile-browser` | Mobile browser (generic) | 400×850 |
| `iphone-small` | iPhone SE | preset |
| `iphone-large` | iPhone 14 | preset |
| `iphone-largest` | iPhone 14 Pro Max | preset |
| `ipad-mini` | iPad Mini 6 | 744×1133 (the 600px breakpoint justifier) |
| `ipad` | iPad (gen 7) | preset |
| `ipad-pro` | iPad Pro 12.9″ | 1024×1366 (the 1024px breakpoint) |
| `android-small` | Galaxy S9+ | preset |
| `android-medium` | Pixel 5 | preset |
| `android-large` | Pixel 7 | preset |
| `android-tablet-7` | Android tablet 7″ | 600×960 |
| `android-tablet-10` | Galaxy Tab S4 | preset |

The sweep should cover every functional screen/scenario of the app across all 13 devices.

## 12. Heavy-targets policy

**Never run heavy Makefile goals on your own initiative** — only when the user explicitly asks for
it in that turn:

- `screenshots` (minutes-long, regenerates hundreds of PNGs, needs the dev server port free)
- `android-device` / `build-android` (prebuild + Gradle)
- `build-ios` / any EAS build (remote, billable)

**To verify a change, prefer lightweight checks:** `make test`, `make lint`, `npx tsc --noEmit`, or
`make run` + driving a single scenario with an ad-hoc Playwright script.

## 13. Docs & git

- **Keep `README.md` in sync** whenever a change affects how a developer builds, runs, tests, or
  ships the app (a new Makefile target, a new required local tool, a language-table change, a change
  to what `make screenshots` covers). Not every commit — but anything on that scale.
- End commit messages with the `Co-Authored-By: Claude ...` trailer.
