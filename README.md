# Litro

![tests](https://github.com/michael-marfil/litro/actions/workflows/test.yml/badge.svg)

**A motorcycle fuel and maintenance tracker for daily riders.** Log a fill-up in about ten
seconds; Litro works out what your bike actually drinks, what it costs you per kilometre,
and when its next service is due.

I built it to track my own Honda Click — the numbers on a spec sheet never match what you
get in Legazpi traffic, and I wanted to know the real one.

<p align="center">
  <img src="docs/dashboard.png" width="30%" alt="Dashboard" />
  <img src="docs/stats.png" width="30%" alt="Stats" />
  <img src="docs/add-entry.png" width="30%" alt="Add entry" />
</p>

---

## What it does

- **Measures real fuel efficiency** between full tanks, not from the manufacturer's claim
- **Any two of {litres, price/L, amount paid}** computes the third while you type
- **Tracks maintenance** — oil, chain, CVT, anything on a schedule, by distance or by time
- **Predicts the due date** from your actual km/day, and reminds you a week ahead
- **Compares stations** by the price you actually paid, cheapest highlighted
- **Charts** efficiency and gas-price trends over time
- **Starts from a preset** — nine common PH models with tank size and service intervals
- **Backs up and restores** your whole history as a file you own
- **Handles multiple bikes**, with every number scoped to the one you're riding
- **Works with no signal.** No account, no server, nothing to sign up for

---

## Why it's built this way

### Offline-first, with no backend

Everything lives in SQLite on the phone. That isn't a shortcut — it's the requirement.
You log a fill-up standing at a pump, which is exactly where signal is worst. No account
means no login screen, no password reset, and no holding anyone else's data.

The trade-off is real and stated: without a cloud, a lost phone is a lost history. Export
is the answer, not a server.

### The efficiency calculation is the actual product

Fuel efficiency can only be measured **between two full tanks** — if both ends are full,
whatever is in the tank cancels out and the fuel burned is everything added in between.

The subtle part is an off-by-one: the petrol bought at the *first* full tank was already in
the tank when the measurement started, so it doesn't count toward the distance travelled
after it. Including it understates efficiency by a third on a short history.

That logic lives in [`lib/domain/`](lib/domain/) as pure functions over
`List<FuelEntry>` — no widgets, no database — and it's the part that's unit-tested. Every
edge case is a named test: a first entry with nothing to measure from, a full tank with no
prior full tank, partial top-ups in between, an odometer that never moved.

### The UI is a function of the database

Every screen reads a Drift `Stream`. Insert a fill-up and the hero number, the lifetime
average, the cost per kilometre, the charts and the recent-fills list all recompute
themselves — there is no refresh call anywhere in the app, and nothing is cached.

Deleting an entry recomputes the tanks around it for the same reason.

### Migrations carry data, they don't reset it

The schema has been through three versions. The v2 → v3 migration created a
`maintenance_items` table **and walked every existing bike**, turning its three oil-change
columns into a real maintenance row. Nobody lost their tracking.

That matters more than usual here: there's no server, so a migration that silently wipes
someone's history is unrecoverable and invisible.

### Restore validates before it destroys

Import is the dangerous half of backup — it replaces everything. So `parse` reads the
entire file, checks the envelope, and refuses anything from a newer format version
*before* a single row is touched. Only then does `apply` run, inside one transaction.

This was not theoretical. An early version looked for a `mantenanceItem` key that the exporter writes as `maintenanceItems` — one missing letter. It silently wiped every maintenance item and reported success. The typo was the bug; the real fix was making a missing key thrown instead of quitely returning an empty list.

### Unit tests didn't catch the prediction bug — real data did

Due dates are estimated from average km/day. Eight units tests passed. Then the app told
me my oil change was due in three days, because my real fill-ups were clustered into two
days and the average came out at 600 km/day.

The fix is two guards: at least three fill-ups, and at least fourteen days of history.
Anything less returns `null`, and the UI shows no estimate rather than a wrong one. Tests
prove the maths; only real data reveals the assumption the maths was built on.

### Nothing invented

A number that can't be computed renders as `—`, never `0.0`. One fill-up genuinely cannot
produce a km/L figure, and a dashboard reading `0.0 km/L` looks broken rather than empty.
Comparison lines hide entirely when the bike has no manufacturer figure to compare against.

---

## Built with

| | |
|---|---|
| **Flutter 3.47 / Dart 3.13** | |
| **[Drift](https://drift.simonbinder.eu/)** | typed SQLite, reactive queries, schema migrations |
| **[fl_chart](https://pub.dev/packages/fl_chart)** | efficiency and price trends |
| **[intl](https://pub.dev/packages/intl)** | `en_PH` peso and date formatting |
| **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** | scheduled reminders that survive a reboot |
| **[share_plus](https://pub.dev/packages/share_plus) / [file_picker](https://pub.dev/packages/file_picker)** | backup out, restore in |
| `CustomPainter` | the arc gauge and the coach-mark spotlight, drawn by hand |

State is plain `setState` and `StreamBuilder`. The database is the single source of truth,
so there is very little UI state to manage — a tab index and a page index.

---

## Running it

```bash
flutter pub get
dart run build_runner build      # generates the Drift code
flutter run
```

Tests:

```bash
flutter test
```

---

## Project layout

```
lib/
  data/        Drift schema, tables, migrations
  domain/      pure calculations — efficiency, maintenance due dates
  screens/     one file per screen or sheet
  theme/       colour tokens and ThemeData
  widgets/     shared presentation widgets
test/          domain and database tests
```

---

## Roadmap

- [ ] GPS-tagged stations on a map, cheapest highlighted
- [ ] Tapping a reminder opens that maintenance item, not just the app
- [ ] Optional cloud backup, so a lost phone isn't a lost history
