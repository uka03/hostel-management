# CLAUDE.md — Hostel Manager (mobile app)

Mobile app for the residents of a shared rental apartment/hostel (түрээсийн
байр). **The unit everywhere is the person, not the room.**

It has three core features:

1. **Cleaning schedule** (Цэвэрлэгээний хуваарь): residents take turns. One
   person is on duty **every 2 days** and cleans **all of the apartment's public
   areas**.
2. **Shared purchases** (Хамтын худалдан авалт): residents buy common items and
   the cost is split equally **between people**.
3. **Anonymous problem reports** (Асуудал мэдэгдэх): residents report issues and
   **nobody can see who reported them**. Other residents, the manager and admins
   all see the same thing.

## Design source

- Figma file: https://www.figma.com/design/oclZSIxHoVshe0DDXsVt0x (fileKey
  `oclZSIxHoVshe0DDXsVt0x`)
- Screens: English row on top, Mongolian ("Монгол") row below. The Mongolian
  screens are the primary design.
  - MN Home `6:171` · Cleaning `6:304` · Purchases `6:452` · Report form `6:568`
    · Reports feed `6:643`
  - EN Home `3:44` · Cleaning `3:177` · Purchases `3:325` · Report form `3:458`
    · Reports feed `3:533`
  - Components: Status bar `3:2`, Tab bar `3:12`
- ⚠️ The Figma screens still show the **old model**: per-room duties, one task
  per area, weekly strip, "6 өрөөнд хуваана". Follow the rules in this file, not
  the mock, wherever they differ. Use Figma for layout and style only.

## Tech stack

- Flutter (Dart, null-safe)
- State: **provider** (`ChangeNotifier` + `ChangeNotifierProvider` / `Consumer`
  / `context.watch`)
- Networking: one shared **`DioClient`** (Dio) with `network_interceptor.dart`
  for the auth token, logging and errors
- Models: **json_serializable** (`@JsonSerializable()`, `part 'x.g.dart'`)
- Backend: _TBD_ (REST API)
- Localization: `flutter_localizations` + ARB (`lib/l10n/app_mn.arb`,
  `app_en.arb`)

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing models
flutter gen-l10n                                           # after editing .arb files
flutter analyze        # must be clean before finishing a task
flutter test
dart format .
```

## Project structure

```
lib/
  connection/
    model/                 json_serializable models (+ .g.dart)
    dio_client.dart
    network_interceptor.dart
  extensions/              e.g. int.toMnt(), DateTime.mnShort()
  pages/
    home/       components/ pages/ provider/ home_page.dart
    cleaning/   components/ pages/ provider/ cleaning_page.dart
    purchases/  components/ pages/ provider/ purchases_page.dart
    reports/    components/ pages/ provider/ reports_page.dart
    profile/    components/ pages/ provider/ profile_page.dart
  routes/
  shared/
    components/            AppCard, AppBadge, IconBox, PrimaryButton, AppTabBar ...
    provider/              auth / current user
    general_scaffold.dart
    main_scaffold.dart     bottom tab bar shell
  utils/                   colors, text_styles, spacer, toasts, empty_state ...
```

- Put pure business logic (rotation, cost split) in plain Dart files inside the
  feature's `provider/` folder, e.g. `cleaning/provider/rotation.dart` and
  `purchases/provider/split.dart`. Don't put Flutter imports in those files, so
  they are easy to unit-test.
- API calls go only through `DioClient`. Never create a new `Dio()` inside a
  page.

## Design tokens (from Figma) → `utils/colors.dart`, `utils/text_styles.dart`

| Token              | Value                                         |
| ------------------ | --------------------------------------------- |
| primary            | `#3B5BDB` · primarySoft `#EDF2FF`             |
| background         | `#F4F6FB` · card `#FFFFFF` · border `#E4E7EC` |
| text               | `#101828` · muted `#667085`                   |
| success            | `#12B76A` / `#E7F8EF`                         |
| warning            | `#F79009` / `#FEF4E6`                         |
| danger             | `#F04438` / `#FEECEB`                         |
| anonymous (purple) | `#7A5AF8` / `#F1EEFE`                         |
| dark card          | `#1D2939`, inner `#344054`                    |

- Font: Inter (it covers Mongolian Cyrillic, including Ө and Ү). Sizes: title 24
  Bold, section 16 SemiBold, body 14–15, caption 12.
- Radius: cards 16, hero cards 20, buttons and inputs 14, chips/badges are
  pills. Screen padding 20, card padding 16.
- Icons: Lucide-style outline (`lucide_icons`).
- Never hardcode a color or text style inside a widget. Always use `utils/`.

## Language & formatting

- **Mongolian (`mn`) is the default locale**; English is secondary. Keep every
  user-facing string in ARB files.
- Mongolian text runs longer than English. Labels must wrap or fit without
  breaking a word in the middle. Test screens at 360 px width.
- Use the short labels already chosen: tab "Зардал", status "Явцад" for in
  progress.
- Money: whole tögrög stored as `int`, never `double`. Display it as `₮48,600`.
- Dates: Asia/Ulaanbaatar time zone. Short form `11/9`; long form
  `11-р сарын 11, Лхагва`.
- Weekdays (mn): Да, Мя, Лх, Пү, Ба, Бя, Ня

## Domain rules

### Cleaning schedule (per person, every 2 days)

- Residents are in a fixed **rotation order**. Each **duty period lasts 2
  days**, and the next person in the order takes the next period.
- The person on duty cleans **all public areas** of the apartment. Each area is
  a checklist item, e.g. kitchen, bathroom/toilet, hallway, taking out the
  trash. The manager configures the list of areas.
- A period starts at 00:00 Asia/Ulaanbaatar time.
  `period_index = days_since_start ~/ 2` and
  `person = order[period_index % order.length]`.
- Status of a duty: `upcoming`, `active`, `done` or `missed`. It is `done` when
  the duty person ticks all areas (a photo is optional). It is `missed` if the
  period ends and it isn't done.
- Swapping: the duty person asks another resident to swap periods, and the swap
  only happens after that resident accepts.
- When a resident joins or leaves, the order changes **from the next period**.
  The current period's duty person is never changed.
- Main UI: who is on duty now, how many days are left in the period, the area
  checklist, when your next turn is, and the upcoming rotation (next ~7
  periods).

### Shared purchases (per person)

- Costs are split **equally between active residents**, not rooms.
- Rounding: `share = amount ~/ people`. The remainder stays with the buyer, so
  the sum of shares always equals the amount exactly.
- Balance for a person = what they paid minus the sum of their shares. Positive
  means they get money back ("Танд буцаж ирэх").
- A resident only shares in purchases made while they were active. Someone who
  moved in later doesn't pay for earlier purchases.
- "Needed items" is a request list. Tapping "Би авна" (I'll buy) claims an item;
  adding the receipt amount turns it into a purchase.
- Purchases are **not** anonymous: the buyer's name is shown.

### Anonymous reports — PRIVACY IS A HARD REQUIREMENT

Anonymity has to hold against **the manager and anyone who can read the
database**, not only against other residents.

- The `reports` table has **no** `user_id` column for the author. No API
  response or model ever contains author identity, and no admin screen shows it.
- Rate limiting and "my reports" use
  `author_hash = HMAC(server_secret, user_id)`. This value is never returned to
  clients, never logged, and never joined back to users.
- "Me too" votes are stored as `HMAC(server_secret, user_id + report_id)` to
  stop double votes. The voter is never stored.
- Photos: strip EXIF and GPS data on the client before upload **and** on the
  server. Re-encode the image.
- Timestamps: show only relative or rounded times (to the hour). In a small
  apartment an exact minute can reveal who sent a report.
- The Dio logging interceptor must **not** log request or response bodies for
  `/reports` endpoints. Don't send analytics events that include a report ID
  together with a user ID.
- Every report shows the author as "Нэргүй оршин суугч" (anonymous resident).
  Only the manager can change a report's status (`open`, `in_progress`,
  `resolved`) and reply. The reply appears on the report.
- **Any change touching reports needs a test proving that author identity cannot
  be recovered from the API response.**

## Roles

- `resident`: a person living in the apartment; uses all three features.
- `manager`: manages residents, the rotation order and the list of cleaning
  areas; changes report status and replies. **Cannot** see who reported.

## Working rules for Claude

- Read the relevant Figma screen for layout, but follow this file's domain rules
  where the mock is outdated.
- Use provider, DioClient and json_serializable, and follow the folder layout
  above. Don't add Riverpod, Bloc, GetX or other HTTP clients.
- Add new strings to **both** `app_mn.arb` and `app_en.arb`.
- Unit-test the 2-day rotation (including joins, leaves and swaps), the cost
  split and rounding, and balances.
- Run `flutter analyze` and `flutter test` before saying a task is done.
- Stop and ask before any change that weakens report anonymity: adding an author
  column, logging, analytics, or exact timestamps.
- Keep commits small, one feature per commit.
