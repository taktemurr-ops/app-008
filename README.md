# APP-008 — Öğün 360 / Meal 360

A privacy-first, offline meal schedule and nutrition journal for Android and iOS built with Flutter. The application supports Turkish, English and Arabic including RTL layout and international digit entry.

## Working product scope

- Add, search, star and remove custom foods; record kcal, protein, carbs and fat per 100 grams.
- Build meals in breakfast/lunch/dinner/snack slots with date and portion, and mark planned vs eaten.
- Browse arbitrary dates and copy a previous day's plan with new record identifiers.
- Observe daily targets and consumed macro progress; review the past seven days.
- Aggregate outstanding meal ingredients into a daily shopping checklist.
- Set nutrition targets and make a user-initiated local JSON export/import, with explicit destructive confirmations.
- Keep private journals encrypted using OS-backed secure storage, with no login, cloud upload or network requests.
- Unit, storage and widget tests plus GitHub CI analyzing and producing a debug Android APK.

## Local development

```sh
flutter create --platforms=android,ios --project-name ogun_360 .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

**Release gate:** The debug APK is for development testing, not a Play Store/App Store release. Before publication, perform real-device testing, vendor-backed Android/iOS signing, privacy and accessibility audits, legal/store review, real monetization credentials where applicable, and production builds. No in-app sales or advertising are enabled by this code. See docs/release-gates.md.
