# APP-008 acceptance and release gates

## Implemented features

Local food catalog, macro data, portions, daily planner, 4 slots, consumed toggles, past-day plan copy, daily grocery checklist, weekly nutrition insights, targets, secure on-device journal, JSON backup/import, confirmed deletion, multilingual UI (tr/en/ar), Android CI, tests.

## Build and release verification

- [ ] `flutter analyze` clean in CI
- [ ] `flutter test` clean in CI
- [ ] Debug Android APK compiles in CI; downloadable workflow artifact
- [ ] Signed production Android AAB, Play Console data-safety forms and store listing
- [ ] Signed production iOS IPA / TestFlight build on macOS and App Store listing
- [ ] Physical Android and iOS device smoke test, notifications, storage/uninstall/reinstall checks
- [ ] Screen-reader, keyboard access, high font scaling and RTL visual review
- [ ] External privacy/legal compliance review; confirm store privacy disclosures
- [ ] Product catalog acceptance and optional advertising / IAP production credentials

A CI-green debug candidate is not a complete published app. Mark final only after all release gates pass.
