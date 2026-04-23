# Mereb

E-learning app prototype built with Flutter.

## Prototype scope

This prototype includes:
- Home dashboard with overall learning progress
- Course catalog list
- Course details view with lesson/progress summary
- Simple learner profile page

## Run the app

1. Install Flutter SDK (3.3.0+), then verify:

```bash
flutter --version
```

2. From the repository root, install dependencies:

```bash
flutter pub get
```

3. Start the app on a connected device/emulator:

```bash
flutter run
```

Optional: run directly in the browser:

```bash
flutter run -d chrome
```

## Admin and Teacher Access

To access the Admin or Teacher dashboards, you can sign up with the following reserved email addresses. The system automatically assigns the corresponding roles upon registration.

- **Admin Account**:
  - Email: `admin@mereb.com`
  - Recommended Password: `admin123456`
- **Teacher Account**:
  - Email: `teacher@mereb.com`
  - Recommended Password: `teacher123456`

After signing up with these emails, you will be directed to the respective dashboards.

## Validate

```bash
flutter analyze
flutter test
```
