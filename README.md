# Firefighter Safety Data Hub — Frontend

Client applications for the Firefighter Safety Data Hub, a platform that collects firefighter exposure data and makes it available to researchers.

| Folder | Application | Users | Stack |
|---|---|---|---|
| [`mobile/`](mobile/) | Mobile app | Firefighters | Flutter, Dart (Android and iOS) |
| [`web/`](web/) | Web dashboard | Researchers | React 19, TypeScript, Vite, Tailwind CSS |
| [`docs/`](docs/) | Project documentation | Developers | Markdown, reference material |

Both applications communicate only with the REST API in the companion repository **`firefighter-data-hub-backend`**:

```
mobile/  ──►  <API_HOST>/api/v1/...          firefighters submit data
web/     ──►  <API_HOST>/api/v1/web_api/...  researchers view and export data
```

---

## Contents

1. [Overview](#1-overview)
2. [Repository structure](#2-repository-structure)
3. [Quick start](#3-quick-start)
4. [Connecting to the API](#4-connecting-to-the-api)
5. [Development workflow](#5-development-workflow)
6. [Further documentation](#6-further-documentation)

---

## 1. Overview

### Mobile app

Firefighters use the mobile app to:

- Create an account with a firefighter profile and verify their email
- Give consent for data collection and location tracking
- Record GPS location in the background, with local buffering when offline
- Log fire events and the PPE used, and submit smoke sampler results
- Manage their password and delete their account

Details: [mobile/README.md](mobile/README.md)

### Web dashboard

Researchers use the web dashboard to:

- Register and sign in with a researcher account
- View summary statistics and charts
- Browse the GPS location and fire event tables
- Export the tables to CSV

Details: [web/README.md](web/README.md)

---

## 2. Repository structure

```
.
├── mobile/                 # Flutter application
│   ├── lib/                # Dart source code
│   ├── android/, ios/      # Native platform projects
│   ├── assets/             # App icon and bundled documents
│   └── pubspec.yaml        # Dependencies
├── web/                    # React application
│   ├── src/                # TypeScript source code
│   ├── public/             # Static assets
│   ├── .env.example        # Environment template
│   └── package.json        # Dependencies and scripts
└── docs/
    ├── ARCHITECTURE.md     # How the system fits together
    ├── ROADMAP.md          # Known issues and planned work
    ├── personal information requirement.pdf   # Data collection requirements
    └── ImageTrendFeatures.txt                 # Reference notes on fire reporting tools
```

---

## 3. Quick start

You need a running API, either locally (see the `firefighter-data-hub-backend` README) or a deployed instance.

### Web dashboard

```bash
cd web
cp .env.example .env      # set the API address, see section 4
npm install
npm run dev               # http://localhost:5173
```

### Mobile app

```bash
cd mobile
flutter pub get
flutter run               # choose an emulator or a connected device
```

The app is configured for the deployed API by default. To use a local API, change `mobile/lib/config/app_config.dart` first (see section 4). Android builds also need `android/key.properties` (see [mobile/README.md](mobile/README.md)).

---

## 4. Connecting to the API

| Application | Setting | Local API | Deployed API |
|---|---|---|---|
| Web | `web/.env` | `API_PROXY_TARGET=http://127.0.0.1:8000` and leave `VITE_API_BASE_URL` empty | `VITE_API_BASE_URL=https://<API_HOST>/api/v1/web_api` |
| Mobile | `mobile/lib/config/app_config.dart` | `useAwsBackend = false`, `port = '8000'`, `localLanOverride = ''` | `useAwsBackend = true`, `baseUrl_aws = 'https://<API_HOST>'` |

When the web dashboard is hosted on its own domain, that domain must be listed in the API's `CORS_ORIGINS` setting.

---

## 5. Development workflow

1. Start the API locally or point the apps at a shared development instance.
2. Make changes in `web/` or `mobile/` and run the app.
3. Before committing, run the checks:

   ```bash
   (cd web && npm run lint && npm run build)
   (cd mobile && flutter analyze && flutter test)
   ```

   `npm run lint` currently reports two existing errors (item D7 in [docs/ROADMAP.md](docs/ROADMAP.md)). Do not add new ones.

4. If an API request or response shape changes, update the matching backend endpoint and the backend's `docs/API.md` in the same change.

**Never commit:** `.env` files, Android signing files (`key.properties`, `*.jks`), iOS signing material, or build output. The `.gitignore` files already exclude them.

---

## 6. Further documentation

| Document | Contents |
|---|---|
| [mobile/README.md](mobile/README.md) | Mobile app setup, structure, configuration, release builds |
| [web/README.md](web/README.md) | Web dashboard setup, structure, configuration, deployment |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture, data flow, data model and authentication |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Known issues and planned work |
| Backend `docs/API.md` | Full API reference |
