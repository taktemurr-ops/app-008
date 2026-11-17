# Privacy and data safety — Öğün 360

Food names, meal dates, consumption flags, nutrition values, goals and shopping checkboxes remain on the user's device and are written through `flutter_secure_storage` (Android Keystore-backed / iOS Keychain-backed). The application implements no account, network transfer, behavioral analytics or third-party tracking.

JSON backup is generated locally only when the user requests it. It is copied to the operating system clipboard, **which is not encrypted by the app** and can be read by other applications. Users should clear the clipboard and protect exported backups. Backups are fully schema-validated before replacing existing data. Clearing all data deletes the secure-storage journal after explicit confirmation. On uninstall, OS backup and keychain retention policies depend on the platform and configuration and require release review.

Nutrition values are entered by users and are not verified clinical information. The app does not diagnose, treat, prescribe diets or supply individualized medical advice.
