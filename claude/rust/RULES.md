# Rust desktop apps (gpui-kit + telaio): shared working rules

Single source of truth for how we build **every** native desktop app in this workspace: Postino
(`~/dev/postino`), Vano (`~/dev/vano`), Nastro (`~/dev/nastro`) and every future one. Each app's
`AGENTS.md` imports this file with `@~/.claude/rust/RULES.md`, so it only needs to describe what is
unique to that app (its domain, its crates, its decisions).

**Postino is the reference implementation.** When this file says "as in Postino", copy the file
or the pattern from `~/dev/postino` and rename. When an app has a good reason to differ, its own
`AGENTS.md` says so and wins.

These apps are unrelated to the Expo mobile apps (`~/.claude/expo/RULES.md`). Do not mix the two
sets of conventions.

---

## 1. Design first, with Claude Design

No code before the design.

1. **Design the app in Claude Design** before creating the repository: the main screens in light
   and dark, the empty and error states, the settings, the icon, and how it moves.
2. **Start from telaio's design system**, not from a blank page. Give Claude Design telaio's
   tokens (`Tokens::DEFAULT_LIGHT`/`DEFAULT_DARK`), its metrics and screenshots of
   `telaio-gallery`, so the app looks like a sibling of the others. Design only what is new: the
   accent (or accents), the domain colors (Postino's HTTP methods, Vano's scan categories), the
   domain widgets and the screens.
3. **The result is a design system document**, `docs/design-system.md`, written from the mockups:
   tokens with their hex values, which telaio tokens the app overrides, type scale, metrics of
   the app's own layout, screens, motion and the rules for using them. Its tokens become the
   app's `telaio_ui::Tokens` (or the defaults) plus a small domain palette in `theme/palette.rs`.
4. **Keep the mockups in the repository only while they are being implemented.** Once the UI
   is built, the code is the source of truth and `docs/design-system.md` its readable summary.
   Remove the mockups and keep them in git history under the tag `design-mockups` (as in Vano).
5. A new standard component or token that more than one app could use goes to telaio, not to the
   app (section 6).

## 2. Stack and pins

- **Rust stable, edition 2024**, pinned with `rust-toolchain.toml` (`channel = "stable"`,
  components `rustfmt` and `clippy`).
- **UI: `gpui-kit`**, at the exact version telaio pins (0.7.0 today), which bundles
  `gpui-component` and `gpui-base` and pins `gpui-pre`. `cargo tree -d --depth 0 | grep gpui` must
  print nothing. Upgrading gpui-kit is a telaio release first, then every app.
- **telaio** (section 6): `telaio-ui` (design system and components), `telaio-app` (application
  shell) and `telaio-update` (in-app updater), git dependencies pinned to one tag.
- **HTTP: `ureq` 3** (blocking, rustls) on gpui's background executor. **No async runtime**, no
  `tokio`.
- **Translations: `rust-i18n` 4** (gpui-component already ships it); language detection comes
  from `telaio-app`.
- **Errors:** `thiserror` in library crates, `anyhow` only in the app crate.
- **Settings:** TOML (`toml`, `serde`), paths from `dirs`.
- **Logging:** the `log` facade and `telaio_app::logging` (section 11).
- `gpui-kit` source is in `~/.cargo/registry/src/*/gpui-kit-<version>`: read it instead of
  relying on memory of the gpui API, which changes quickly.

## 3. Repository layout

A Cargo workspace of small crates with a thin UI crate:

```
<app>/
├── Cargo.toml              workspace: package, dependencies, lints, release profile
├── Cargo.lock              committed
├── rust-toolchain.toml  rustfmt.toml  .editorconfig  .gitignore
├── Makefile                single entry point for every action (section 5)
├── LICENSE  NOTICE         Apache-2.0
├── README.md  AGENTS.md
├── crates/
│   ├── <app>-core/         domain model, no IO
│   ├── <app>-.../          one crate per concern (format, IO, engine, ...), no gpui
│   ├── <app>-cli/          the app's own command line commands, no gpui (section 12)
│   └── <app>-app/          the gpui binary: only UI and glue
│       ├── assets/         icons, bundled data (fonts come from telaio)
│       ├── locales/        rust-i18n YAML, one file per area
│       └── src/
│           ├── main.rs     startup (telaio_app pieces), window
│           ├── state/      UI logic in plain Rust, unit tested without a window
│           ├── theme/      domain colors and app-only metrics on top of telaio
│           └── views/      gpui views; views/components/ for the domain widgets
├── docs/                   architecture, design-system, gpui-notes, i18n, releasing
├── packaging/              linux/ macos/ windows/ aur/ icons/
├── site/                   website and user docs (section 13)
└── .github/workflows/      build, release, website, stats
```

- **Dependency direction** written in `AGENTS.md` as a diagram. No cycles, no crate depends on
  the app crate. Every crate except the app is testable with `cargo test`: no window, no GPU, no
  network other than a local test server.
- **No `gpui`, HTTP or engine types in a public API outside their own crate.** Data crossing crates
  is plain owned data from `<app>-core`.
- **The binary is named like the app** (`[[bin]] name = "<app>"`).
- **App id `codes.tanis.<app>`**: Wayland `app_id`, `.desktop` file, macOS bundle id, Windows
  AppUserModelID. Website `<app>.tanis.codes`.

## 4. Configuration files

Copy them from Postino. The shared parts:

```toml
# Cargo.toml
[workspace]
resolver = "3"
members = ["crates/*"]
default-members = ["crates/*"]

[workspace.package]
edition = "2024"
version = "0.1.0"          # the only place the version lives (section 14)
publish = false
license = "Apache-2.0"
authors = ["Estanislao Pérez Nartallo <tanisperez@gmail.com>"]

[workspace.dependencies]
gpui-kit = "0.7.0"
telaio-ui = { git = "https://github.com/tanisperez/telaio", tag = "vX.Y.Z" }
telaio-app = { git = "https://github.com/tanisperez/telaio", tag = "vX.Y.Z" }
telaio-update = { git = "https://github.com/tanisperez/telaio", tag = "vX.Y.Z" }
# every other dependency here once; crates use `dep = { workspace = true }`

[workspace.lints.clippy]
all = "warn"
unwrap_used = "warn"
expect_used = "warn"

[workspace.lints.rust]
unsafe_code = "forbid"     # the one unsafe call apps needed (AttachConsole) lives in telaio-app

[profile.release]
lto = "fat"                # 8% smaller binary than thin, same speed (Postino #34)
codegen-units = 1
strip = true               # panics stay as unwind
```

- `rustfmt.toml`: `edition = "2024"`, `max_width = 100`.
- `.editorconfig`: 4 spaces, LF, UTF-8, trailing whitespace trimmed (not in `*.md`), 2 spaces in
  YAML, tabs in the `Makefile`.
- `.gitignore`: `/target` plus app specifics (`site/docs/`, generated files).
- Every crate has `[lints] workspace = true`.

## 5. Makefile

The only entry point, `make` alone prints `help`. Standard targets, same names in every app:

| Target | Does |
| --- | --- |
| `run` | `cargo run` (debug) |
| `build`, `release` | debug build, optimized build |
| `check` | `cargo check --all-targets` |
| `lint`, `lint-fix` | `cargo clippy --all-targets -- -D warnings`, and with `--fix` |
| `format`, `format-check` | `cargo fmt --all`, with `-- --check` |
| `test` | `cargo test --all-targets` |
| `dist` | release packages for this OS into `target/dist` |
| `install`, `install-latest`, `uninstall` | Linux: install under `~/.local` (`PREFIX=`), from a local build or the latest release |
| `docs`, `site` | build the user docs (fails on broken links, missing images, em dashes), serve the site |
| `screenshots` | regenerate the website screenshots |
| `clean` | `cargo clean` |

Plus app specifics (Postino's `sample`, `sample-server`). **Before considering any task done:
`make format`, `make lint`, `make test`, and `make docs` when user docs changed.**

Alternate builds (another profile, a dependency upgrade, a build of `main` to compare) go under a
subdirectory of `target/`, never in `/tmp` (a RAM tmpfs): a full gpui build takes several GB.

## 6. telaio

telaio (`~/dev/telaio`, <https://github.com/tanisperez/telaio>) is the kit every app is built on,
one repository with three crates released together (its README has the API and examples, its
`AGENTS.md` the rules for changing it):

- `telaio-ui`: palette tokens, the gpui-kit theme builder, shared metrics, the Geist fonts and
  the standard components.
- `telaio-app`: the application shell. One `AppIdentity` const (name, slug, app id, version,
  env prefix, repository) configures logging, the command line pieces, language detection,
  number formatting, the config folder, the window bootstrap and the About header.
- `telaio-update`: the in-app updater, configured by one `UpdaterConfig` const (section 15).

- **Startup:** `telaio_app::window::application()` (gpui-kit with `AllAssets`; without it every
  icon renders empty), `telaio_app::window::init(cx, &IDENTITY)`, then
  `telaio_ui::install(cx, &ThemeFamily::new("<App>").tokens(light, dark).fonts(...))`. Open the
  window with `telaio_app::window::options(cx, &IDENTITY, sizes)` (client decorations on Linux,
  the app id), apply the `ThemeChoice`, call `telaio_app::window::follow_system_appearance`, and
  wrap the view in gpui-kit's `Root`, which also renders the dialog, sheet and notification
  layers (never render them again in the view). After a settings change, `telaio_ui::apply` and
  `ThemeChoice::apply` again.
- **Colors only from `cx.palette()`**, never `cx.theme()` and never a literal. Sizes only from
  `telaio_ui::metrics` and the app's `theme::metrics` (which re-exports telaio's with
  `pub use telaio_ui::metrics::*`).
- **Domain colors** live in the app as an extension trait on `telaio_ui::Palette` (Postino's
  `theme::PostinoColors`), reading `palette.dark` to pick the mode.
- **Standard components come from telaio**, re-exported from `views/components/mod.rs`. Only
  domain widgets live in the app. Never fork a telaio component locally: fix or extend it in
  telaio.
- **Strings of telaio's crates** come from their own locales and follow the app's
  `rust_i18n::set_locale`.
- **Shared code goes to telaio, never to a copy.** If two apps would need the same code (a
  component, a token, shell or updater logic), it belongs in telaio.
- **Changing telaio and an app together:** a `[patch."https://github.com/tanisperez/telaio"]`
  entry pointing each telaio crate at `../telaio/crates/<crate>` in the app's root `Cargo.toml`.
  **Never commit it.** Then release telaio (milestone closed, version bump, CI green, tag, GitHub
  release) and bump the tag in the app.
- **About screen** starts with `telaio_app::about::header` (logo, name, version, platform, the
  telaio version with its link, release notes and GitHub buttons), as in Postino's
  `views/settings/about.rs`.

## 7. Code conventions

- No `unwrap()` or `expect()` outside tests, except truly impossible states with a comment saying
  why. Tests may `#[allow]` them at module level.
- Doc comments on every public item. Small modules. Explicit types at public boundaries. No
  macro magic of our own. Readable over clever.
- **UI logic in `state/`**, plain Rust with unit tests: open tabs, dirty state, selections,
  decisions such as "is this a portable copy". Views only render and forward input.
- Library crates depend only on `log`, never on the logger.

## 8. Performance (non-negotiable)

- **An idle window does no work.** gpui re-renders the whole window on any `cx.notify()`, so no
  timers, polling or animations that notify while nothing changes. A spinner or any animation
  exists only while its work is running. Check: with the app idle for 10 s, the main thread CPU
  ticks (fields 14 and 15 of `/proc/<pid>/task/<pid>/stat`) must barely move, and the GPU
  counters (`drm-engine-render` in `/proc/<pid>/fdinfo/*`) must not move. Measure on native
  Wayland: XWayland adds about 12 ticks per 10 s of noise.
- **`render` runs on every frame** (every hover, keystroke, cursor blink). Nothing in a render
  path may cost in proportion to the data size: no parsing, pretty printing, syntax work, full
  text comparison or file IO. Compute derived data when its source changes, cache it under a
  cheap key (an id plus a generation counter) and share big texts as `Arc<str>` or
  `SharedString`.
- Resync an editor (`set_value`) only when that key changes.
- Test with big data, not only small samples, and measure RSS. After upgrading gpui-kit, re-check
  the idle rule.

## 9. Translations

- Languages: **English (source and fallback), Spanish, Galician, Italian.**
- `rust_i18n::i18n!("locales", fallback = "en")` in `main.rs`; strings with `t!("area.key")`.
  `telaio_app::language` (`Language`, `LanguageChoice`, `resolve`, `apply`) detects the OS
  language, overridable by a `language` setting (`auto` by default). The app's `state/locale.rs`
  keeps only its `plural` helper and the tests of its own locale files.
- `locales/*.yml`, `_version: 2`, one entry per key with `en`, `es`, `gl` and `it` together, one
  file per area (`common`, `settings`, ...) so parallel work never edits the same file. Keys
  dotted, area first, lowercase snake case. Shared strings under `common.`. Plurals are two keys,
  `.one` and `.other`.
- Strings cached outside `render` (input placeholders) are re-applied when the language changes.
- **Not translated:** log messages, library errors (shown verbatim in a translated frame),
  protocol literals, keyboard shortcut labels, debug hooks and the `--help`/`--version` output.
- Numbers shown to the user go through `telaio_app::number` (ICU, CLDR data); never in logs or
  inputs.
- **Tests** (in `state/locale.rs`): every key in the four languages with the same `%{}`
  placeholders, no em dash, every literal `t!` key used under `src/` exists. Tests never call
  `rust_i18n::set_locale` (process wide); use `t!("key", locale = "es")`.
- Glossary and decisions in `docs/i18n.md`.

## 10. Settings and files

- `settings.toml` in the OS config folder (`telaio_app::paths::config_dir(&IDENTITY)`), applied
  live, no Save button. Unknown or invalid values fall back to the default. The settings struct
  is the app's own (`telaio_app::logging::LogLevel` is a ready-made field).
- Every file the app writes is listed in `docs/architecture.md` ("Files <App> writes").
- The settings window has an **About** pane: version, platform, telaio version, links to the
  release notes and GitHub, the updater state (section 15) and a privacy line saying what the app
  connects to on its own.

## 11. Logging

`telaio_app::logging`: a small logger behind the `log` facade, so gpui, wgpu and HTTP messages
reach it too. `init(&IDENTITY, level)` at the very start of `main`, after reading the settings.

- File: `$XDG_STATE_HOME/<app>/<app>.log` (`~/.local/state/...`) on Linux,
  `~/Library/Logs/<App>/` on macOS, `%LOCALAPPDATA%\<App>\logs\` on Windows. Rotated at 5 MB,
  10 files at most.
- Level from the `log_level` setting (Info by default), overridden by `<APP>_LOG` at startup.
  Crates other than the app's, `gpui*` and `telaio*` are capped at Warn (Info at Trace): `naga`
  alone writes about 20 MB at Debug on every startup.
- Info for startup and user actions, Warn for failed operations, Debug for internals, Trace for
  per-frame or per-item detail (one line per render of the root view at Trace, so a render
  count that grows while idle shows up).
- **Privacy:** never log user content, secrets or values. Log a redacted form.

## 12. Command line and debug hooks

- The command line is the app's own **`<app>-cli` crate** (no gpui), as Postino's `postino-cli`:
  `main` calls `<app>_cli::run_if_cli(first_arg)` first and opens the window only when it returns
  `None`. Commands print and exit **without opening a window**, in the same binary. Adding a
  command is a module (parse, run, help text, tests) registered in one place; move to `clap`
  with the first real subcommand.
- Every app has `-h`/`--help` and `-V`/`--version`. The shared pieces come from
  `telaio_app::cli`: the `<App> X.Y.Z` line, the help header and footer with a link to the
  command line docs, the exit codes, and on Windows (a GUI subsystem binary) the console attach.
  English only.
- A path argument opens it (file association, section 16). macOS delivers "open with" through
  Apple Events: hook `cx.on_open_urls` too.
- **Debug hooks**, read once at startup and ignored when unset or invalid: `<APP>_OPEN=<state>`
  starts in a given screen (`settings`, `settings-about`, `components`, ...), `<APP>_LOG=<level>`.
  `<APP>_OPEN=components` shows the app's components gallery, domain widgets included; the
  standard components alone, under every sample palette, are in `telaio-gallery`. Document hooks
  in `AGENTS.md`, not in the user docs.

## 13. Documentation

- **README.md**, in this order: title; badges (latest release, build, license, platforms; telaio
  adds gpui-kit and Rust); one paragraph pitch; links to Website, Download and Documentation; a
  hero screenshot as `<picture>` with light and dark WebP; a few feature screenshots with one
  line each; `Install`; `Building from source`; `Documentation`; `Built with` (Rust, gpui-kit,
  telaio, with links); `License`.
- **AGENTS.md** imports this file and covers: project, decisions taken, pending decisions (ask
  before choosing), architecture with the crate diagram, app-specific rules, testing and debug
  hooks, commands.
- **Developer docs in `docs/`:** `architecture.md`, `design-system.md`, `gpui-notes.md` (gpui-kit
  pitfalls met), `i18n.md`, `releasing.md`, plus the app's format or engine documents.
- **User docs** at `<app>.tanis.codes/docs/`, sources in `site/docs-src/pages/` (one HTML page
  per topic, sidebar order in the `NAV` list of `site/docs-src/build.py`, Python standard library
  only); `site/docs/` is generated and git ignored. Reference pages are exhaustive: keyboard
  shortcuts, settings, command line, files and folders, plus the app's formats.
- **Every user-visible change updates the user docs in the same commit or pull request**, written
  from the code (exact defaults, labels from the English locale), and passes `make docs`.
- Writing: no em dash anywhere (code, comments, docs, translations, commits). English for code,
  docs, commits, issues and pull requests.

## 14. Versions, issues and releases

- **One version**, `version` under `[workspace.package]`, SemVer. The app reads it with
  `env!("CARGO_PKG_VERSION")`. Tags are `vX.Y.Z`; the release workflow fails if they differ.
  Pre-releases (`vX.Y.Z-rc.N`) are built and published as GitHub pre-releases, never distributed
  and invisible to the updater; set the full pre-release version in `Cargo.toml` before tagging.
- **Work is tracked with GitHub milestones and issues** (`gh issue list --milestone X.Y.Z`), not
  in a separate document. Complex work goes on a branch.
- **Release steps** (Postino's `docs/releasing.md`): every milestone issue closed and the checks
  green on `main`; bump the version and commit; tag and push (ask before pushing); create the
  release as a **draft** with English Markdown notes (`gh release create vX.Y.Z --draft
  --verify-tag --notes-file notes.md`); the `Release` workflow uploads the assets and publishes
  the draft only when everything is there; for a stable release, run the `Website` workflow by
  hand to rebuild the package repositories.

## 15. Packaging, distribution and the in-app updater

Targets: Linux x86_64 (built on Ubuntu 22.04 for glibc 2.35), Windows x86_64, macOS arm64.

| Asset | Content |
| --- | --- |
| `<app>-X.Y.Z-linux-x86_64.tar.gz` | binary, desktop entry, MIME type and icons in a `/usr`-like layout |
| `<app>_X.Y.Z_amd64.deb`, `<app>-X.Y.Z-1.x86_64.rpm` | built with `nfpm` from one YAML |
| `<App>-X.Y.Z-macos-arm64.dmg` and `.app.tar.gz` | ad-hoc signed app; the tarball is for the updater |
| `<App>-X.Y.Z-windows-x86_64-setup.exe` | Inno Setup, **per-user** install (no admin, no UAC on update) |
| `<App>-X.Y.Z-windows-x86_64-portable.zip` | the same exe, nothing to install |
| `latest.json`, `SHA256SUMS` | updater manifest, checksums |

- **Linux channels:** AUR `<app>-bin`, signed APT and DNF repositories on the website (GitHub
  Pages deployed from Actions, no `gh-pages` branch, one GPG key), direct downloads. Updates come
  from the package manager.
- **macOS and Windows:** direct downloads (Homebrew tap and winget later), updates in-app.
- **Desktop integration:** `.desktop` file and MIME XML on Linux, `Info.plist` document types on
  macOS, `HKCU` file association on Windows. Icons from one SVG master in `packaging/icons/`.
- **Updater** (`telaio-update`, tested against a local `tiny_http` server; the app keeps a
  `const UPDATER: UpdaterConfig`, the gate and its restart confirmation in `state/update.rs`,
  and the UI in `views/update.rs`):
  - compiled in only with `<APP>_UPDATER=github` at build time (`option_env!`), set on the macOS
    app and the Windows builds; otherwise the feature and its setting do not exist;
  - one check 10 s after startup, no timer, no polling; a manual "Check for updates" command;
  - `GET .../releases/latest/download/latest.json`, compared with `semver`; no API, no token;
  - TLS through the OS certificate store (`ureq` platform verifier), for corporate proxies;
  - downloads in the background, verifies the SHA-256, then offers "Update ready, restart";
    nothing installs without a click; unsaved work goes through the normal quit prompt;
  - a portable Windows copy (no `unins000.exe` next to the exe) never downloads or runs the
    installer: it offers to open the release page.
- **Unsigned for now** (Gatekeeper and SmartScreen warnings on first install). Signing and
  notarization are documented as later steps in Postino's `docs/releasing.md`.

## 16. CI workflows

As in Postino's `.github/workflows/`:

- `build.yml`: on every push and pull request, release build on Linux, Windows and macOS
  (Linux needs the Wayland, X11, xkbcommon, fontconfig and Vulkan dev packages).
- `release.yml`: on `v*` tags; checks tag against version, builds and packages per OS, publishes
  `SHA256SUMS` and `latest.json`, then distributes stable releases (website and package repos,
  AUR).
- `website.yml`: builds the site and the user docs, rebuilds the APT and DNF repos, deploys
  Pages. On pushes to `main` that touch `site/`, and by hand after a release.
- `stats.yml`: daily, saves traffic and download counts to an orphan `stats` branch.
- Secrets, created as each channel is set up: `AUR_SSH_KEY`, `GPG_PRIVATE_KEY`,
  `GPG_PASSPHRASE`, `STATS_TOKEN` (later `HOMEBREW_TAP_TOKEN`, `WINGET_TOKEN`).

## 17. Testing

- `cargo test` covers every crate: libraries with fixtures and round trips, HTTP against a local
  `tiny_http` server on `127.0.0.1:0`, UI logic in `state/`. **No test touches the internet.**
- **Check UI changes in the real app, not only in tests:** run it through XWayland
  (`WAYLAND_DISPLAY=` empty) and drive it with `xdotool`, clicking and typing through the
  controls you touched, with screenshots (`spectacle -b -n -a`). Detect the display scale each
  run (`xdotool mousemove 1000 500; xdotool getmouselocation`). Use isolated `XDG_CONFIG_HOME`
  and `XDG_STATE_HOME` so tests do not touch the user's settings. Kill only your own instance by
  PID. Before driving the desktop, check that no other Claude session is doing the same.
- For a refactor that should change nothing visible, compare screenshots of `main` and the
  branch pixel by pixel (`magick compare -metric AE`).

## 18. Starting a new app

1. Design it in Claude Design on top of telaio (section 1) and write `docs/design-system.md`.
2. Pick the name, check it on crates.io and GitHub, create `tanisperez/<app>`, decide the app id
   and the website subdomain.
3. Depend on `telaio-ui`, `telaio-app` and `telaio-update`, and define the app's
   `AppIdentity` and `UpdaterConfig`. Copy from Postino what a crate cannot carry: configuration
   files (section 4), `Makefile`, `LICENSE`, `NOTICE`, workflows, `packaging/`, `site/`, the
   `<app>-cli` crate, `state/settings.rs`, `state/update.rs`, `views/update.rs` and the About
   pane. Rename every `postino`, `Postino`, `POSTINO_` and `codes.tanis.postino`.
4. Write `AGENTS.md` importing this file, and the README in the order of section 13.
5. Create the first milestone and its issues before writing features.
