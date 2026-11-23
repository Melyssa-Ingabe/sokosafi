# SokoSafi

A surplus-food marketplace for Kigali — connecting customers with discounted near-expiry items from bakeries, restaurants, groceries, and cafes. Built with Flutter and Firebase as a group capstone project.

**Deadline: 23 Nov 2026, 11:59 pm**

---

## Team — Group 20

| Member  | Area                        | Branches                                        |
| ------- | --------------------------- | ----------------------------------------------- |
| Melyssa | Auth & app foundation       | `feature/setup`, `feature/auth`                 |
| Annie   | Business setup & listings   | `feature/business-setup`, `feature/listings`    |
| Kevine  | Business operations         | `feature/business-dashboard`, `feature/business-orders` |
| Nelly   | Customer discovery          | `feature/discovery`, `feature/security-rules`   |
| Prince  | Checkout, orders & settings | `feature/orders`, `feature/settings`            |

---

## Tech Stack

| Layer          | Technology                                    |
| -------------- | --------------------------------------------- |
| Framework      | Flutter (iOS-first, Android supported)        |
| State          | BLoC / Cubit (`flutter_bloc`)                 |
| Backend        | Firebase — Firestore, Auth, Storage           |
| Auth           | Email/password + Google Sign-In               |
| Navigation     | `go_router`                                   |
| Fonts          | Geist via `google_fonts`                      |
| Icons          | HugeIcons (`strokeRounded` only)              |
| Persistence    | `shared_preferences`                          |
| Testing        | `bloc_test`, `fake_cloud_firestore`, `mocktail` |

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Xcode (iOS) or Android Studio (Android)
- A Firebase project with Firestore, Auth, and Storage enabled
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective platform directories

### Install

```bash
flutter pub get
```

### Run

```bash
# iOS Simulator
flutter run -d ios

# Android emulator
flutter run -d android
```

### Analyze & Format

```bash
dart format .
flutter analyze
```

Both must pass with zero warnings before opening a PR.

### Test

```bash
flutter test
flutter test --coverage
```

---

## Project Structure

```
lib/
  main.dart
  router/
    app_router.dart       # go_router config, all named routes
    app_routes.dart       # Route path constants
  core/
    theme/                # AppColors, AppTextStyles, AppTheme
    constants/            # AppSpacing, AnimationConstants
    utils/                # Formatters, validators
    widgets/              # Shared widgets (MenuGroup, MenuTile, etc.)
  features/
    auth/                 # Melyssa — splash, login, register, forgot password
    business_setup/       # Annie — business onboarding (3 steps)
    listings/             # Annie — add/edit/my listings
    business_dashboard/   # Kevine — dashboard, analytics
    business_orders/      # Kevine — order management, pickup confirmation
    reviews/              # Kevine — customer reviews
    discovery/            # Nelly — feed, search, saved merchants
    orders/               # Prince — checkout, order confirmation, my orders
    profile/              # Prince — profile screen, stats
    settings/             # Prince — app settings (SharedPreferences)
test/
  features/
    orders/               # CheckoutCubit + FirestoreOrdersRepository tests
    settings/             # SettingsCubit tests
```

Each feature follows the same layout:

```
<feature>/
  data/
    models/
    repositories/
  domain/
    entities/
  presentation/
    screens/
    widgets/
    bloc/   (or cubit/)
```

---

## Firestore Collections

| Collection              | Key fields                                                        | Owner                    |
| ----------------------- | ----------------------------------------------------------------- | ------------------------ |
| `users`                 | name, email, phone, role, foodPreferences, photoUrl               | Melyssa (create), Prince (profile) |
| `businesses`            | name, type, address, lat/lng, acceptingOrders, pickupStart/End    | Annie (setup), Kevine (settings) |
| `listings`              | title, category, originalPrice, discountPrice, quantity, pickupBy | Annie                    |
| `orders`                | quantity, total, pickupCode, paymentMethod, status, createdAt     | Prince (create/cancel), Kevine (collected) |
| `reviews`               | rating (1–5), comment, createdAt                                  | Kevine                   |
| `users/{uid}/savedMerchants` | savedAt                                                      | Nelly                    |

Field changes must be reported to Annie on the same day (she owns the ERD).

---

## State Management

**`setState()` is banned for app state.** Use Cubit for simple state, Bloc (with events) for complex flows. Widgets only read state and dispatch events — no business logic or Firestore calls inside widget files.

---

## SharedPreferences (Prince)

Four preferences persisted across restarts, managed by `SettingsCubit`:

| Key                 | Type    | Default               |
| ------------------- | ------- | --------------------- |
| `dark_mode`         | bool    | false                 |
| `notifications`     | bool    | true                  |
| `search_distance`   | double  | 5.0 km                |
| `payment_method`    | String  | MTN Mobile Money      |

---

## Design Tokens

**Colors** — `AppColors.*` only. Never raw hex in widgets.

| Token         | Hex       | Use                    |
| ------------- | --------- | ---------------------- |
| primary       | `#006A35` | CTAs, filled buttons   |
| accent        | `#3D9C5D` | Selected chips         |
| background    | `#F8FAF8` | Scaffold               |
| surface       | `#FFFFFF` | Cards, sheets          |
| error         | `#BA1A1A` | Destructive actions    |

**Typography** — `AppTextStyles.*` or `Theme.of(context).textTheme.*`. Font: Geist.

**Spacing** — 4 px grid: xs=4, sm=8, md=12, lg=16, xl=24, xxl=32. Page horizontal padding = 16.

---

## Git Workflow

- `main` is protected — all merges go through a reviewed PR.
- Each member works on their own branches (see table above).
- Conventional Commits: `feat(scope): subject`, `fix(scope): subject`, etc.
- Commit small and often. No large last-minute dumps.
- Another member must leave a real review comment before merging.

```bash
# Check contribution balance before opening a PR
git shortlog -sn --all
```

---

## Definition of Done (per screen)

- Matches the Figma design
- No overflow on small, large, or landscape screens
- BLoC/Cubit handles all state — no logic in widget files
- Reads/writes real Firestore data
- Shows loading, empty, and error states
- Unit tests written and passing
- `flutter analyze` passes with zero warnings
- Merged through a reviewed PR
- Logged in the contribution tracker

---

## Figma

[View design](https://www.figma.com/design/OqIFzvlR32PJjdVAnJjzMY/Sokosafi)
