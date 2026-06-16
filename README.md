# 🐱 Pépito Updates

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-3.0+-764ABC?style=for-the-badge)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Cat door monitoring app — know exactly where your cat is, in real time.**

[Documentation](#-architecture) • [Setup](#-setup) • [Scripts](#-available-scripts) • [Testing](#-testing)

</div>

---

## 📖 About

Pépito Updates monitors your cat's comings and goings through the cat door. Built with Flutter and Riverpod for state management, backed by Supabase for database, authentication, and realtime subscriptions.

---

## 🏗️ Architecture

```
┌─────────────────────┐     ┌──────────────┐     ┌─────────────┐
│  Flutter App        │────▶│  Riverpod    │────▶│  Supabase   │
│  (Android / iOS /   │     │  State       │     │  Client     │
│   Web / Desktop)    │     │  Management  │     │             │
└─────────────────────┘     └──────────────┘     └──────┬──────┘
                                                       │
                                              ┌────────▼──────┐
                                              │  PostgreSQL   │
                                              │  Database     │
                                              └────────┬──────┘
                                                       │
                                              ┌────────▼──────┐
                                              │  Edge         │
                                              │  Functions    │
                                              │  (API Proxy)  │
                                              └────────┬──────┘
                                                       │
                                              ┌────────▼──────┐
                                              │  External     │
                                              │  Cat Door API │
                                              └───────────────┘
```

### Core Technologies

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Flutter + Dart | Cross-platform UI |
| **Backend** | Supabase | Database, auth, realtime |
| **State** | Riverpod 3.x | Reactive state management |
| **Charts** | FL Chart | Data visualization |
| **Realtime** | Supabase Realtime + SSE | Live updates |
| **API Proxy** | Edge Functions (Deno) | Secures external API calls |

### Platform Styles

The app supports multiple visual styles:
- **Fluent Design** — Windows-native look via `fluent_ui`
- **Material Expressive** — Web-optimized Material theme
- **Liquid Glass** — Frosted glass aesthetic

---

## 🚀 Setup

### Prerequisites

- Flutter SDK 3.8+
- Dart 3.0+
- A Supabase project (free tier works)
- Git

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/xNekom/PepitoUpdates.git
cd PepitoUpdates

# 2. Install dependencies
flutter pub get

# 3. Create .env from template
cp .env.example .env
# Edit .env with your Supabase credentials (see Environment Variables below)

# 4. Run the app
flutter run --dart-define-from-file=.env
```

### Environment Variables

Credentials are passed via `--dart-define` at build time — **never hardcoded**.

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous key |
| `ENVIRONMENT` | `dev`, `qa`, `uat`, or `pro` (default: `dev`) |

Example:

```bash
flutter run --dart-define=SUPABASE_URL=https://yourproject.supabase.co \
           --dart-define=SUPABASE_ANON_KEY=your-anon-key \
           --dart-define=ENVIRONMENT=dev
```

Or using a `.env` file:

```bash
flutter run --dart-define-from-file=.env
```

---

## 📜 Available Scripts

| Script | Purpose |
|--------|---------|
| `switch_env.bat` / `switch_env.ps1` | Switch between dev/qa/uat/pro environments |
| `run_with_proxy.bat` | Start local proxy server + Flutter (CORS workaround) |
| `check_env.bat` / `check_env.ps1` | Verify environment variables are set |
| `check_setup.bat` | Verify project setup completeness |
| `check_supabase.bat` | Test Supabase connection |
| `check_automation.bat` | Check Edge Function automation status |
| `deploy_edge_functions.bat` | Deploy Edge Functions to Supabase |

---

## 🧪 Testing

```bash
flutter test
```

---

## 🔍 Linting

```bash
flutter analyze
```

Runs the Dart analyzer across the project. All PRs must pass with **zero issues**.

---

## 📁 Project Structure

```
lib/
├── config/            # Environment, API, Supabase configuration
├── models/            # Data models (PepitoActivity, User, AuthToken)
├── providers/         # Riverpod providers + notifiers
├── services/          # API, Supabase, SSE, localization services
├── screens/           # UI screens (Home, Statistics, Settings, Activities)
├── widgets/           # Reusable widgets (adaptive, cards, dialogs)
├── utils/             # Helpers (date, logger, theme, platform)
├── theme/             # Theme definitions per platform style
├── middleware/        # App middleware
├── generated/         # Code generation output
├── l10n/              # Localization (ARB files)
├── main.dart          # Entry point
└── .env.example       # Environment variable template
```

---

## 🔄 CI/CD

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **auto-test.yml** | PR to `main`/`develop`, push to `main` | `flutter analyze` + `flutter test` |
| **deploy-pages.yml** | Manual dispatch | Build + deploy Flutter web to GitHub Pages |
| **deploy-to-vercel.yml** | Push to `main`, manual | Build + deploy Flutter web to Vercel |

Credentials are injected via GitHub Secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `VERCEL_TOKEN`).

---

## 🔐 Security

- All credentials are passed via `--dart-define` — **never committed to the repository**
- `.env` is in `.gitignore`
- Edge Functions proxy external API calls, keeping API keys server-side
- Environment-specific configs prevent accidental production access in dev

---

## 📄 License

MIT — see [`LICENSE`](LICENSE) for details.
